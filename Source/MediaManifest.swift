//
//  MediaManifest.swift
//

import Foundation
import SWXMLHash

open class MediaManifest {

    private struct Elements {
        static let MediaManifest = "MediaManifest"

        // Compatibility
        static let Compatibility = "Compatibility"
        static let SpecVersion = "SpecVersion"
        static let Profile = "Profile"

        // Inventory
        static let Inventory = "Inventory"
        static let Audio = "Audio"
        static let Video = "Video"
        static let Image = "Image"
        static let Interactive = "Interactive"
        static let Metadata = "Metadata"
        static let TextObject = "TextObject"

        // Presentations
        static let Presentations = "Presentations"
        static let Presentation = "Presentation"

        // PlayableSequences
        static let PlayableSequences = "PlayableSequences"
        static let PlayableSequence = "PlayableSequence"

        // PictureGroups
        static let PictureGroups = "PictureGroups"
        static let PictureGroup = "PictureGroup"

        // AppGroups
        static let AppGroups = "AppGroups"
        static let AppGroup = "AppGroup"

        // TextGroups
        static let TextGroups = "TextGroups"
        static let TextGroup = "TextGroup"

        // Experiences
        static let Experiences = "Experiences"
        static let Experience = "Experience"

        // TimedEventSequences
        static let TimedEventSequences = "TimedEventSequences"
        static let TimedEventSequence = "TimedEventSequence"
    }

    // Versioning
    var currentSpecVersion = ManifestSpecVersion.unknown
    var currentProfile = ManifestProfile.none

    // Inventory
    open var audios: [String: Audio]?
    open var videos: [String: Video]?
    open var images: [String: Image]?
    open var interactives: [String: Interactive]?
    open var metadatas: [String: Metadata]?
    open var textObjects: [String: TextObject]?
    open var textGroups: [String: TextGroup]?
    open var presentations = [String: Presentation]()
    open var playableSequences: [String: PlayableSequence]?
    open var presentationToAudioVisualMapping: [String: ExperienceAudioVisual]?
    open var pictures: [String: Picture]?
    open var pictureGroups: [String: PictureGroup]?
    open var galleries: [String: Gallery]?
    open var appGroups: [String: AppGroup]?
    open var experienceApps: [String: ExperienceApp]?
    open var experiences = [String: Experience]()
    open var timedEventSequences: [String: TimedEventSequence]?
    open var timedEvents: [TimedEvent]?

    open var mainExperience: Experience!
    open var inMovieExperience: Experience!
    open var outOfMovieExperience: Experience!

    open var title: String {
        return (mainExperience.title ?? "Unknown")
    }

    open var titleTreatmentImageURL: URL? {
        return inMovieExperience.thumbnailImageURL
    }
    
    open var featureVideo: Video {
        return mainExperience.video!
    }
    
    open var interstitialVideo: Video? {
        return nil
    }

    open var backgroundImageURL: URL? {
        return outOfMovieExperience.thumbnailImageURL
    }

    open var people: [Person]? {
        get {
            return mainExperience.metadata?.people
        }
        
        set {
            mainExperience.metadata?.people = newValue
        }
    }

    open var actors: [Person]? {
        return mainExperience.metadata?.actors
    }

    open var numActors: Int {
        return (actors?.count ?? 0)
    }

    open var hasActors: Bool {
        return (numActors > 0)
    }

    init(indexer: XMLIndexer) throws {
        // Compatibility
        guard indexer.hasElement(Elements.Compatibility) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Compatibility, element: indexer.element)
        }

        let compatibilityIndexer = indexer[Elements.Compatibility]

        if let string = compatibilityIndexer.stringValue(forElement: Elements.SpecVersion), let specVersion = ManifestSpecVersion(rawValue: string) {
            currentSpecVersion = specVersion
        } else {
            currentSpecVersion = .unknown
        }

        if let string = compatibilityIndexer.stringValue(forElement: Elements.Profile), let profile = ManifestProfile(rawValue: string) {
            currentProfile = profile
        } else {
            currentProfile = .none
        }

        // Inventory
        guard indexer.hasElement(Elements.Inventory) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Inventory, element: indexer.element)
        }

        try initInventory(indexer: indexer[Elements.Inventory])

        // Presentations / Presentation
        guard indexer.hasElement(Elements.Presentations) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Presentations, element: indexer.element)
        }

        for indexer in indexer[Elements.Presentations][Elements.Presentation] {
            let presentation = try Presentation(indexer: indexer)
            presentations[presentation.id] = presentation
        }

        // PlayableSequences / PlayableSequence
        if indexer.hasElement(Elements.PlayableSequences) {
            var playableSequences = [String: PlayableSequence]()
            for indexer in indexer[Elements.PlayableSequences][Elements.PlayableSequence] {
                let playableSequence = try PlayableSequence(indexer: indexer)
                playableSequences[playableSequence.id] = playableSequence
            }

            self.playableSequences = playableSequences
        }

        // PictureGroups / PictureGroup
        if indexer.hasElement(Elements.PictureGroups) {
            var pictureGroups = [String: PictureGroup]()
            for indexer in indexer[Elements.PictureGroups][Elements.PictureGroup] {
                let pictureGroup = try PictureGroup(indexer: indexer)
                pictureGroups[pictureGroup.id!] = pictureGroup
            }

            self.pictureGroups = pictureGroups
        }

        // AppGroups / AppGroup
        if indexer.hasElement(Elements.AppGroups) {
            var appGroups = [String: AppGroup]()
            for indexer in indexer[Elements.AppGroups][Elements.AppGroup] {
                let appGroup = try AppGroup(indexer: indexer)
                appGroups[appGroup.id] = appGroup
            }

            self.appGroups = appGroups
        }

        // TextGroups / TextGroup
        if indexer.hasElement(Elements.TextGroups) {
            var textGroups = [String: TextGroup]()
            for indexer in indexer[Elements.TextGroups][Elements.TextGroup] {
                let textGroup = try TextGroup(indexer: indexer)
                textGroups[textGroup.id] = textGroup
            }

            self.textGroups = textGroups
        }

        // Experiences / Experience
        guard indexer.hasElement(Elements.Experiences) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Experiences, element: indexer.element)
        }

        for indexer in indexer[Elements.Experiences][Elements.Experience] {
            if let experience = try Experience(indexer: indexer) {
                experiences[experience.id] = experience
            }
        }

        // TimedEventSequences / TimedEventSequence
        if indexer.hasElement(Elements.TimedEventSequences) {
            var timedEventSequences = [String: TimedEventSequence]()
            for indexer in indexer[Elements.TimedEventSequences][Elements.TimedEventSequence] {
                let timedEventSequence = try TimedEventSequence(indexer: indexer)
                timedEventSequences[timedEventSequence.id] = timedEventSequence
            }

            self.timedEventSequences = timedEventSequences
        }
    }

    private func initInventory(indexer: XMLIndexer) throws {
        // Audio
        if indexer.hasElement(Elements.Audio) {
            var audios = [String: Audio]()
            for indexer in indexer[Elements.Audio] {
                if let audio = try Audio(indexer: indexer) {
                    audios[audio.id] = audio
                }
            }

            self.audios = audios
        }

        // Video
        if indexer.hasElement(Elements.Video) {
            var videos = [String: Video]()
            for indexer in indexer[Elements.Video] {
                if let video = try Video(indexer: indexer) {
                    videos[video.id] = video
                }
            }

            self.videos = videos
        }

        // Image
        if indexer.hasElement(Elements.Image) {
            var images = [String: Image]()
            for indexer in indexer[Elements.Image] {
                if let image = try Image(indexer: indexer) {
                    images[image.id] = image
                }
            }

            self.images = images
        }

        // Interactive
        if indexer.hasElement(Elements.Interactive) {
            var interactives = [String: Interactive]()
            for indexer in indexer[Elements.Interactive] {
                if let interactive = try Interactive(indexer: indexer) {
                    interactives[interactive.id] = interactive
                }
            }

            self.interactives = interactives
        }

        // Metadata
        if indexer.hasElement(Elements.Metadata) {
            var metadatas = [String: Metadata]()
            for indexer in indexer[Elements.Metadata] {
                let metadata = try Metadata(indexer: indexer)
                metadatas[metadata.id] = metadata
            }

            self.metadatas = metadatas
        }

        // TextObject
        if indexer.hasElement(Elements.TextObject) {
            var textObjects = [String: TextObject]()
            for indexer in indexer[Elements.TextObject] {
                let textObject = try TextObject(indexer: indexer)
                textObjects[textObject.id] = textObject
            }

            self.textObjects = textObjects
        }
    }

    open func postProcess() throws {
        let experiences = Array(self.experiences.values)
        
        // Process Experiences
        guard let mainExperience = experiences.first(where: { $0.isMainExperience }) else {
            throw ManifestError.missingMainExperience
        }

        self.mainExperience = mainExperience

        guard let childExperiences = self.mainExperience.childExperiences, childExperiences.count == 2 else {
            throw ManifestError.missingSupplementalExperiences
        }

        outOfMovieExperience = childExperiences.first!
        inMovieExperience = childExperiences.last!
        
        // Process Experience children
        var timedEvents = [TimedEvent]()
        var galleries = [String: Gallery]()
        var experienceApps = [String: ExperienceApp]()
        var presentationToAudioVisualMapping = [String: ExperienceAudioVisual]()
        for experience in experiences {
            if let experienceTimedEvents = experience.timedEventSequence?.timedEvents {
                for timedEvent in experienceTimedEvents {
                    timedEvent.experienceID = experience.id
                    timedEvents.append(timedEvent)
                }
            }
            
            if let gallery = experience.gallery {
                galleries[gallery.id] = gallery
            }
            
            if let app = experience.app {
                experienceApps[app.id] = app
            }
            
            if let audioVisual = experience.audioVisual, let presentationID = audioVisual.presentationID {
                presentationToAudioVisualMapping[presentationID] = audioVisual
            }
        }
        
        if timedEvents.count > 0 {
            self.timedEvents = timedEvents
        }
        
        if galleries.count > 0 {
            self.galleries = galleries
        }
        
        if experienceApps.count > 0 {
            self.experienceApps = experienceApps
        }
        
        if presentationToAudioVisualMapping.count > 0 {
            self.presentationToAudioVisualMapping = presentationToAudioVisualMapping
        }
        
        // Process Pictures
        if let pictureGroups = pictureGroups {
            var pictures = [String: Picture]()
            for pictureGroup in Array(pictureGroups.values) {
                for picture in pictureGroup.pictures {
                    pictures[picture.id] = picture
                }
            }
            
            self.pictures = pictures
        }
        
        // Pre-load talent images
        if let talentAPIUtil = NGDMConfiguration.talentAPIUtil {
            let loadTalentImages = { [weak self] in
                if let people = self?.people {
                    for person in people {
                        if person.images == nil, let id = person.apiID {
                            talentAPIUtil.getTalentImages(id, completion: { (images) in
                                person.images = images
                            })
                        }
                    }
                }
            }
            
            if people == nil {
                talentAPIUtil.prefetchCredits({ [weak self] (people) in
                    self?.people = people
                    loadTalentImages()
                })
            } else {
                loadTalentImages()
            }
        }
    }

    open func audioWithID(_ id: String?) -> Audio? {
        return (id != nil ? audios?[id!] : nil)
    }

    open func videoWithID(_ id: String?) -> Video? {
        return (id != nil ? videos?[id!] : nil)
    }

    open func imageWithID(_ id: String?) -> Image? {
        return (id != nil ? images?[id!] : nil)
    }

    open func pictureWithID(_ id: String?) -> Picture? {
        return (id != nil ? pictures?[id!] : nil)
    }

    open func pictureGroupWithID(_ id: String?) -> PictureGroup? {
        return (id != nil ? pictureGroups?[id!] : nil)
    }

    open func galleryWithID(_ id: String?) -> Gallery? {
        return (id != nil ? galleries?[id!] : nil)
    }

    open func interactiveWithID(_ id: String?) -> Interactive? {
        return (id != nil ? interactives?[id!] : nil)
    }

    open func metadataWithID(_ id: String?) -> Metadata? {
        return (id != nil ? metadatas?[id!] : nil)
    }

    open func playableSequenceWithID(_ id: String?) -> PlayableSequence? {
        return (id != nil ? playableSequences?[id!] : nil)
    }

    open func presentationWithID(_ id: String?) -> Presentation? {
        return (id != nil ? presentations[id!] : nil)
    }

    open func textGroupWithID(_ id: String?) -> TextGroup? {
        return (id != nil ? textGroups?[id!] : nil)
    }

    open func textObjectWithID(_ id: String?) -> TextObject? {
        return (id != nil ? textObjects?[id!] : nil)
    }

    open func appGroupWithID(_ id: String?) -> AppGroup? {
        return (id != nil ? appGroups?[id!] : nil)
    }

    open func experienceWithID(_ id: String?) -> Experience? {
        return (id != nil ? experiences[id!] : nil)
    }
    
    open func timedEventSequenceWithID(_ id: String?) -> TimedEventSequence? {
        return (id != nil ? timedEventSequences?[id!] : nil)
    }

    open func personWithID(_ id: String?) -> Person? {
        return mainExperience.metadata?.personWithID(id)
    }
    
    open func timedEvents(atTimecode timecode: Double, type: TimedEventType = .any) -> [TimedEvent]? {
        return timedEvents?.filter({ $0.isType(type) && timecode >= $0.startTime && timecode <= $0.endTime }).sorted(by: {
            ($0.experience != nil && $1.experience != nil && $0.experience!.sequence < $1.experience!.sequence)
        })
    }
    
    open func closedTimedEvent(toTimecode timecode: Double, type: TimedEventType = .any) -> TimedEvent? {
        return timedEvents?.first(where: { $0.isType(type) && timecode <= $0.endTime })
    }

}
