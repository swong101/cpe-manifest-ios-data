//
//  MainExperience.swift
//

import Foundation

// Wrapper class for `NGEExperienceType` Manifest object associated with the main Experience
public class MainExperience: Experience {

    private var featureMetadata: Metadata? {
        return audioVisual?.metadata
    }

    /// Ordered list of Talents with type Actor associated with the feature film
    public var actors: [Person]? {
        return featureMetadata?.people?.filter({ $0.isActor })
    }

    public var hasActors: Bool {
        return ((actors?.count ?? 0) > 0)
    }

    public var interstitialVideoURL: URL? {
        if let playableSequence = audioVisual?.playableSequence, playableSequence.presentations.count > 1 {
            return playableSequence.presentations.first!.videoURL
        }

        return nil
    }

    public var commentaryAudioURL: URL? {
        if let audio = audioVisual?.presentation?.audio, audio.type == .commentary {
            return audio.url
        }

        return nil
    }

    // MARK: Helper Methods
    /**
        Find the value of any custom identifier associated with this Experience

        - Parameters:
            - namespace: The namespace of the custom identifier used in the Manifest

        - Returns: The value of the custom identifier if it exists
    */
    public func customIdentifier(_ namespace: String) -> String? {
        return featureMetadata?.customIdentifier(namespace)
    }

    /**
        Loads talent based on a series of fallbacks, starting with the Baseline API
    */
    public func loadTalent() {
        if let talentAPIUtil = NGDMConfiguration.talentAPIUtil {
            let loadTalentImages = { [weak self] in
                if let people = self?.featureMetadata?.people {
                    for person in people {
                        if person.images == nil, let id = person.apiID {
                            talentAPIUtil.getTalentImages(id, completion: { (images) in
                                person.images = images
                            })
                        }
                    }
                }
            }

            if featureMetadata?.people == nil {
                talentAPIUtil.prefetchCredits({ [weak self] (people) in
                    self?.featureMetadata?.people = people
                    loadTalentImages()
                })
            }

            loadTalentImages()
        }
    }

}
