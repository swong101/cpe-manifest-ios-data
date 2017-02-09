//
//  NGDMExperience.swift
//

import Foundation

public enum ExperienceType {
    case app
    case audioVisual
    case clipShare
    case gallery
    case location
    case shopping
    case talentData
}

public func ==(lhs: NGDMExperience, rhs: NGDMExperience) -> Bool {
    return lhs.id == rhs.id
}

// Wrapper class for `NGEExperienceType` Manifest object
open class NGDMExperience: Equatable {
    
    // MARK: Instance Variables
    /// Appearance object for background images, buttons, etc
    var nodeStyles: [NGDMNodeStyle]?
    
    /// Unique identifier
    public var id: String
    open var analyticsIdentifier: String {
        return id
    }
    
    /// Order within parent experience
    var sequenceNumber = 0
    
    /// All children of this Experience
    private var _childExperiences: [NGDMExperience]?
    private var _childExperienceIds: [String]?
    public var childExperiences: [NGDMExperience]? {
        if _childExperiences == nil, let childExperienceIds = _childExperienceIds {
            _childExperiences = childExperienceIds.flatMap({ NGDMExperience.getById($0) })
        }
        
        _childExperienceIds = nil
        
        return _childExperiences
    }
    
    public var numChildren: Int {
        return (childExperiences?.count ?? 0)
    }
    
    /// Child of this Experience that is a talent data Experience
    private var _childTalentDataExperience: NGDMExperience?
    var childTalentDataExperience: NGDMExperience? {
        if _childTalentDataExperience == nil, let index = childExperiences?.index(where: { $0.isType(.talentData) }) {
            _childTalentDataExperience = childExperiences?[index]
        }
        
        return _childTalentDataExperience
    }
    
    /// Metadata associated with this Experience
    var metadata: NGDMMetadata?
    
    /// Title to be used for display
    public var title: String {
        return (metadata?.title ?? location?.title ?? "")
    }
    
    /// Description to be used for display
    public var description: String {
        return (metadata?.description ?? location?.description ?? "")
    }
    
    /// Image URL to be used for thumbnail displays
    public var imageURL: URL? {
        if let imageURL = metadata?.imageURL {
            return imageURL
        }
        
        // Break recursion if this is one of the main experiences
        if NGDMManifest.sharedInstance.mainExperience == self || NGDMManifest.sharedInstance.outOfMovieExperience == self || NGDMManifest.sharedInstance.inMovieExperience == self {
            return nil
        }
        
        return (audioVisual?.imageURL ?? gallery?.imageURL ?? location?.thumbnailImageURL ?? app?.imageURL ?? childExperiences?.first?.imageURL)
    }
    
    /// AudioVisual associated with this Experience, if it exists
    var audioVisual: NGDMAudioVisual?
    
    /// Presentation associated with this Experience's AudioVisual, if it exists
    var presentation: NGDMPresentation? {
        return audioVisual?.presentations?.last
    }
    
    /// Video URL to be used for video display, if it exists
    public var videoURL: URL? {
        return presentation?.videoURL
    }
    
    public var videoID: String? {
        return presentation?.videoID
    }
    
    public var videoAnalyticsIdentifier: String? {
        return presentation?.videoAnalyticsIdentifier
    }
    
    /// Video runtime length in seconds
    public var videoRuntime: TimeInterval {
        return (presentation?.videoRuntime ?? 0)
    }
    
    /// Gallery associated with this Experience, if it exists
    public var gallery: NGDMGallery?
    
    /// App associated with this Experience, if it exists
    public var app: NGDMExperienceApp?
    
    /// AppData associated with this Experience
    private var appDataID: String?
    public var location: NGDMLocation? {
        if let id = appDataID {
            return NGDMManifest.sharedInstance.locations[id]
        }
        
        return nil
    }
    
    public var locationMediaCount: Int {
        return (location?.mediaCount ?? 0)
    }
    
    // MARK: Initialization
    /**
        Initializes a new Experience
     
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    init(manifestObject: NGEExperienceType) {
        id = manifestObject.ExperienceID ?? UUID().uuidString
        
        if let id = manifestObject.ContentID {
            metadata = NGDMMetadata.getById(id)
        }
        
        if let obj = manifestObject.Audiovisual {
            let audioVisual = NGDMAudioVisual(manifestObject: obj)
            self.audioVisual = audioVisual
            NGDMManifest.sharedInstance.audioVisuals[audioVisual.id] = audioVisual
        }
        
        if let obj = manifestObject.Gallery {
            let gallery = NGDMGallery(manifestObject: obj)
            self.gallery = gallery
            NGDMManifest.sharedInstance.galleries[gallery.id] = gallery
        }
        
        if let obj = manifestObject.App {
            let experienceApp = NGDMExperienceApp(manifestObject: obj)
            app = experienceApp
            appDataID = experienceApp.id
            if NGDMManifest.sharedInstance.experienceApps[experienceApp.id] == nil {
                NGDMManifest.sharedInstance.experienceApps[experienceApp.id] = experienceApp
            }
        }
        
        if let objList = manifestObject.ExperienceChildList , objList.count > 0 {
            var childMap = [Int: String]()
            for obj in objList {
                if let index = obj.SequenceInfo?.Number, let id = obj.ExperienceID {
                    childMap[index] = id
                }
            }
            
            // Sort the children by SequenceInfo.Number
            let sortedChildren = childMap.sorted { $0.0 < $1.0 }
            _childExperienceIds = sortedChildren.map({ return $0.1 })
        }
    }
    
    // MARK: Helper Methods
    /**
        Check if Experience is of the specified type
     
        - Parameters:
            - type: Type of Experience
     
        - Returns: `true` if the Experience is of the specified type
     */
    // FIXME: Hardcoded Experience ID strings are being used to identify Experience types
    public func isType(_ type: ExperienceType) -> Bool {
        switch type {
        case .app:
            return (app != nil)
            
        case .audioVisual:
            return (audioVisual != nil && !isType(.clipShare))
            
        case .clipShare:
            return id.contains("clipshare")
            
        case .gallery:
            return (gallery != nil)
            
        case .location:
            if location != nil {
                return true
            }
            
            if let firstChildExperience = childExperiences?.first {
                return firstChildExperience.isType(.location)
            }
            
            return false
            
        case .shopping:
            return (app?.isProductApp ?? false)
            
        case .talentData:
            return id.contains("castcrew")
        }
    }
    
    /**
        Finds the Experience media associated with the AppData at the specified index
 
        - Parameters:
            - index: Media index to search
 
        - Returns: Associated Experience if it exists
    */
    public func locationMediaAtIndex(_ index: Int) -> NGDMExperience? {
        return location?.mediaAtIndex(index)
    }
    
    /**
        Finds the NodeStyle matching the current orientation and device
 
        - Parameters:
            - interfaceOrientation: Current device orientation
 
        - Returns: Current NodeStyle if it exists
    */
    public func getNodeStyle(_ interfaceOrientation: UIInterfaceOrientation) -> NGDMNodeStyle? {
        let isTablet = (UIDevice.current.userInterfaceIdiom == .pad)
        let isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation)
        
        if let nodeStyles = nodeStyles {
            for nodeStyle in nodeStyles {
                if (isTablet && nodeStyle.supportsTablet) || (!isTablet && nodeStyle.supportsPhone) {
                    if isLandscape && nodeStyle.supportsLandscape {
                        return nodeStyle
                    }
                    
                    if !isLandscape && nodeStyle.supportsPortrait {
                        return nodeStyle
                    }
                }
            }
        }
        
        return nil
    }
    
    /**
        Finds the ExperienceChild at the given index
 
        - Parameters:
            - index: Child experience index to search
 
        - Returns: Child experience, if it exists
    */
    public func childExperience(atIndex index: Int) -> NGDMExperience? {
        if let childExperiences = childExperiences, childExperiences.count > index {
            return childExperiences[index]
        }
        
        return nil
    }
    
    // MARK: Search Methods
    /**
        Find an `NGDMExperience` object by unique identifier

        - Parameters:
            - id: Unique identifier to search for

        - Returns: Object associated with identifier if it exists
    */
    public static func getById(_ id: String) -> NGDMExperience? {
        return NGDMManifest.sharedInstance.experiences[id]
    }
    
}
