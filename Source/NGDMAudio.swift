//
//  NGDMAudio.swift
//

import Foundation

public enum AudioType: String {
    case primary        = "primary"         // primary audio track. There may be multiple primary tracks, with one for each language
    case narration      = "narration"       // The visually impairment associated service is a complete program mix containing music, effects, dialogue, and additionally a narrative description of the picture content
    case dialogCentric  = "dialogcentric"   // The hearing impaired associated service is a complete program mix containing music, effects, and dialogue with dynamic range compression
    case commentary     = "commentary"      // Commentary on the video
    case other          = "other"           // not one of the above
}

// Wrapper class for `NGEInventoryAudioType` Manifest object
open class NGDMAudio {
    
    /// Unique identifier
    var id: String
    
    /// URL associated with this Audio
    public var url: URL?
    
    /// Type of Audio track
    private var type = AudioType.primary
    
    /// True if this Audio is a commentary track
    public var isCommentary: Bool {
        return isType(.commentary)
    }
    
    // MARK: Initialization
    /**
        Initializes a new Audio
    
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    init(manifestObject: NGEInventoryAudioType) {
        id = manifestObject.AudioTrackID
        
        if let typeString = manifestObject.Type, let type = AudioType(rawValue: typeString) {
            self.type = type
        }
        
        url = ManifestUtils.urlForContainerReference(manifestObject.ContainerReference)
    }
    
    // MARK: Helper Methods
    /**
        Check if Audio is of the specified type
     
        - Parameters:
            - type: Type of Audio
     
        - Returns: `true` if the Audio is of the specified type
     */
    public func isType(_ type: AudioType) -> Bool {
        return (type == self.type)
    }
    
    // MARK: Search Methods
    /**
        Find an `NGDMAudio` object by unique identifier
    
        - Parameters:
            - id: Unique identifier to search for
    
        - Returns: Object associated with identifier if it exists
    */
    static func getById(_ id: String) -> NGDMAudio? {
        return NGDMManifest.sharedInstance.audios[id]
    }
    
}
