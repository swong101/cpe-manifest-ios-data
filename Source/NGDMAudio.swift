//
//  NGDMAudio.swift
//

import Foundation

public enum AudioType: String {
    case primary = "primary"
    case narration = "narration"
    case dialogCentric = "dialogcentric"
    case commentary = "commentary"
    case other = "other"
}

// Wrapper class for `NGEInventoryAudioType` Manifest object
open class NGDMAudio {
    
    /// Unique identifier
    var id: String
    
    /// URL associated with this Audio
    open var url: URL?
    
    /// Type of Audio track
    private var type: AudioType = .primary
    
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
        
        if let containerLocation = manifestObject.ContainerReference?.ContainerLocationList?.first?.value {
            if containerLocation.contains("file://") {
                let tempURL = URL(fileURLWithPath: containerLocation.replacingOccurrences(of: "file://", with: ""))
                url = Bundle.main.url(forResource: tempURL.deletingPathExtension().path, withExtension: tempURL.pathExtension)
            } else {
                url = URL(string: containerLocation)
            }
        }
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
