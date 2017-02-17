//
//  NGDMAudioVisual.swift
//

import Foundation

public enum AudioVisualType: String {
    case main = "Main"
    case promotion = "Promotion"
    case bonus = "Bonus"
    case other = "Other"
}

public enum AudioVisualSubtype: String {
    case feature = "Feature"
    case shareableClip = "Shareable Clip"
    case other = "Other"
}

// Wrapper class for `NGEAudiovisualType` Manifest object
open class NGDMAudioVisual {
    
    /// Unique identifier
    var id: String
    
    /// Type of AudioVisual object
    var type = AudioVisualType.other
    var subtype = AudioVisualSubtype.other
    
    /// Metadata associated with this AudioVisual
    var metadata: NGDMMetadata?
    
    /// Image URL to be used for display
    public var imageURL: URL? {
        return metadata?.imageURL
    }
    
    /// Description to be used for display
    public var descriptionText: String? {
        return (metadata?.description ?? metadata?.title)
    }
    
    /// Presentations associated with this AudioVisual
    private var playableSequence: NGDMPlayableSequence?
    private var presentation: NGDMPresentation?
    var presentations: [NGDMPresentation]? {
        if let playableSequence = playableSequence {
            return playableSequence.presentations
        }

        if let presentation = presentation {
            return [presentation]
        }

        return nil
    }
    
    var interstitialVideoURL: URL? {
        if let presentations = playableSequence?.presentations, presentations.count > 1 {
            return presentations.first?.videoURL
        }
        
        return nil
    }
    
    // MARK: Initialization
    /**
        Initializes a new AudioVisual
    
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    init(manifestObject: NGEAudiovisualType) {
        id = (manifestObject.PresentationID ?? manifestObject.PlayableSequenceID ?? manifestObject.ContentID ?? UUID().uuidString)
        
        if let id = manifestObject.ContentID {
            metadata = NGDMMetadata.getById(id)
        }
        
        if let id = manifestObject.PlayableSequenceID {
            playableSequence = NGDMPlayableSequence.getById(id)
        } else if let id = manifestObject.PresentationID {
            presentation = NGDMPresentation.getById(id)
        }
        
        if let type = manifestObject.Type, let audioVisualType = AudioVisualType(rawValue: type) {
            self.type = audioVisualType
        }
        
        if let subtype = manifestObject.SubTypeList?.first, let audioVisualSubtype = AudioVisualSubtype(rawValue: subtype) {
            self.subtype = audioVisualSubtype
        }
    }
    
    
    
    // MARK: Helper Methods
    /**
        Check if AudioVisual is of the specified type
     
        - Parameters:
            - type: Type of AudioVisual
     
        - Returns: `true` if the AudioVisual is of the specified type
     */
    open func isType(_ type: AudioVisualType) -> Bool {
        return (type == self.type)
    }
    
    /**
     Check if AudioVisual is of the specified subtype
     
        - Parameters:
            - type: Subtype of AudioVisual
     
        - Returns: `true` if the AudioVisual is of the specified subtype
     */
    open func isSubtype(_ subtype: AudioVisualSubtype) -> Bool {
        return (subtype == self.subtype)
    }
    
    // MARK: Search Methods
    /**
        Find an `NGDMAudioVisual` object by unique identifier
     
        - Parameters:
            - id: Unique identifier to search for
     
        - Returns: Object associated with identifier if it exists
     */
    static func getById(_ id: String) -> NGDMAudioVisual? {
        return NGDMManifest.sharedInstance.audioVisuals[id]
    }
    
}
