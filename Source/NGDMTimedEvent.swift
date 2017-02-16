//
//  NGDMTimedEvent.swift
//

import Foundation

public enum TimedEventType {
    case any
    case appGroup
    case audioVisual
    case clipShare
    case gallery
    case location
    case product
    case talent
    case textItem
}

public func ==(lhs: NGDMTimedEvent, rhs: NGDMTimedEvent) -> Bool {
    return (lhs.id == rhs.id && lhs.startTime == rhs.startTime)
}

// Wrapper class for `NGETimedEventType` Manifest object
open class NGDMTimedEvent: Equatable {
    
    // MARK: Instance Variables
    /// Unique identifier
    var id: String!
    open var analyticsIdentifier: String {
        return id
    }
    
    /// Position in full TimedEvent list
    public var sortedIndex: Int {
        if let index = NGDMManifest.sharedInstance.timedEvents.index(of: self) {
            return Int(index)
        }
        
        return -1
    }
    
    /// Timecodes
    public var startTime: Double = -1
    public var endTime: Double = -1
    
    /// Text value associated with this TimedEvent if it exists
    open var descriptionText: String? {
        return (gallery?.title ?? audioVisual?.descriptionText ?? textItem ?? location?.title)
    }
    
    /// Image to be used for display
    private var _imageURL: URL?
    open var imageURL: URL? {
        return (_imageURL ?? gallery?.imageURL ?? audioVisual?.imageURL ?? experienceApp?.imageURL)
    }
    
    /// Video associated with this TimedEvent's AudioVisual/Presentation
    open var videoURL: URL? {
        return audioVisual?.presentations?.last?.videoURL
    }
    
    open var videoID: String? {
        return audioVisual?.presentations?.last?.videoID
    }
    
    open var videoAnalyticsIdentifier: String? {
        return audioVisual?.presentations?.last?.videoAnalyticsIdentifier
    }
    
    /// TimedEvent objects
    var textItem: String?
    public var experience: NGDMExperience?
    public var appGroup: NGDMAppGroup?
    public var gallery: NGDMGallery?
    public var audioVisual: NGDMAudioVisual?
    public var experienceApp: NGDMExperienceApp?
    public var productNamespace: String?
    
    private var _talentID: String?
    public var talent: NGDMTalent? {
        if let id = _talentID {
            return NGDMManifest.sharedInstance.mainExperience?.talents?[id]
        }
        
        return nil
    }
    
    private var appDataID: String?
    public var location: NGDMLocation? {
        if let id = appDataID {
            return NGDMManifest.sharedInstance.locations[id]
        }
        
        return nil
    }
    
    public var product: NGDMProduct? {
        if let id = appDataID {
            return NGDMManifest.sharedInstance.products[id]
        }
        
        return nil
    }
    
    // MARK: Initialization
    /**
        Initializes a new NGETimedEventType
    
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    init(manifestObject: NGETimedEventType) {
        // Timecodes
        if let str = manifestObject.StartTimecode.value {
            startTime = Double(str)!
        }
        
        if let str = manifestObject.EndTimecode.value {
            endTime = Double(str)!
        }
        
        // FIXME: Making assumption that PictureID is in the Initialization property
        if let id = manifestObject.Initialization {
            _imageURL = NGDMPicture.getById(id)?.imageURL
        }
        
        // TimedEvent objects
        if let textGroupId = manifestObject.TextGroupIDList?.first, let textGroupIndex = textGroupId.index, let textGroup = NGDMTextGroup.getById(textGroupId.value!) {
            textItem = textGroup.textItem(textGroupIndex)
        }
        
        if let id = manifestObject.AppGroupID {
            appGroup = NGDMAppGroup.getById(id)
        }
        
        if let id = manifestObject.GalleryID {
            gallery = NGDMGallery.getById(id)
        }
        
        if let id = manifestObject.PresentationID {
            audioVisual = NGDMAudioVisual.getById(id)
        }
        
        if let id = manifestObject.AppGroupID {
            experienceApp = NGDMExperienceApp.getById(id)
        }
        
        productNamespace = manifestObject.ProductID?.Namespace
        
        if let otherID = manifestObject.OtherID {
            if otherID.Namespace == Namespaces.AppDataID {
                appDataID = otherID.Identifier
            } else if otherID.Namespace == Namespaces.PeopleID {
                _talentID = otherID.Identifier
            }
        }
        
        id = (audioVisual?.id ?? gallery?.id ?? appGroup?.id ?? appDataID ?? _talentID ?? UUID().uuidString)
    }
    
    init(startTime: Double, endTime: Double = -1, productNamespace: String? = nil) {
        id = UUID().uuidString
        self.startTime = startTime
        self.endTime = endTime
        self.productNamespace = productNamespace
    }
    
    // MARK: Helper Methods
    /**
        Check if TimedEvent is of the specified type
 
        - Parameters:
            - type: Type of TimedEvent
 
        - Returns: `true` if the TimedEvent is of the specified type
    */
    open func isType(_ type: TimedEventType) -> Bool {
        switch type {
        case .appGroup:
            return (appGroup != nil)
            
        case .audioVisual:
            return (audioVisual != nil && !isType(.clipShare))
            
        case .clipShare:
            if audioVisual != nil && audioVisual!.isSubtype(.shareableClip) {
                return true
            }
            
            // Support legacy method of denoting clipshare experience
            return experience != nil && experience!.id.contains("clipshare")
            
        case .gallery:
            return (gallery != nil)
            
        case .location:
            return (location != nil)
            
        case .product:
            if let productAPIUtil = NGDMConfiguration.productAPIUtil, (productNamespace == type(of: productAPIUtil).APINamespace) {
                return true
            }
            
            return (product != nil)
            
        case .talent:
            return (talent != nil)
            
        case .textItem:
            return (textItem != nil)
            
        case .any:
            return true
        }
    }
    
    /**
        Returns the previous TimedEvent in the full sequence with the specified type
 
        - Parameters:
            - type: Type of TimedEvent
 
        - Returns: Previous TimedEvent, if it exists
    */
    open func previousTimedEventOfType(_ type: TimedEventType) -> NGDMTimedEvent? {
        let currentIndex = sortedIndex
        if currentIndex > 0 {
            for i in (0...currentIndex - 1).reversed() {
                let timedEvent = NGDMManifest.sharedInstance.timedEvents[i]
                if timedEvent.isType(type) {
                    return timedEvent
                }
            }
        }
        
        return nil
    }
    
    /**
        Returns the next TimedEvent in the full sequence with the specified type
     
        - Parameters:
            - type: Type of TimedEvent
     
        - Returns: Next TimedEvent, if it exists
     */
    open func nextTimedEventOfType(_ type: TimedEventType) -> NGDMTimedEvent? {
        let currentIndex = sortedIndex
        let lastIndex = NGDMManifest.sharedInstance.timedEvents.count - 1
        if currentIndex < lastIndex {
            for i in ((currentIndex + 1)...lastIndex) {
                let timedEvent = NGDMManifest.sharedInstance.timedEvents[i]
                if timedEvent.isType(type) {
                    return timedEvent
                }
            }
        }
        
        return nil
    }
    
    public static func findByTimecode(_ timecode: Double, type: TimedEventType = .any) -> [NGDMTimedEvent] {
        let timedEvents = NGDMManifest.sharedInstance.timedEvents.filter({ $0.isType(type) && timecode >= $0.startTime && timecode <= $0.endTime })
        return timedEvents.sorted(by: { ($0.experience?.sequenceNumber ?? 0) < ($1.experience?.sequenceNumber ?? 0) })
    }
    
    public static func findClosestToTimecode(_ timecode: Double, type: TimedEventType = .any) -> NGDMTimedEvent? {
        return NGDMManifest.sharedInstance.timedEvents.first(where: { $0.isType(type) && timecode <= $0.endTime })
    }
    
}
