//
//  NGDMAppGroup.swift
//

import Foundation

public enum RuntimeEnvironment: String {
    case cmx                = "CMX"     // Connected Media Experience
    case flash              = "Flash"   // Adobe Flash
    case bdj                = "BD-J"    // Blu-ray Java
    case mheg               = "MHEG"    // MHEG-5, or more formally ISO/IEC 13522-5
    case html5              = "HTML5"   // W3C HTML5
    case defaultEnvironment = "Default" // Represents an application that can be played if nothing else can. This is typically an image
    case other              = "Other"   // May be used when there is not a type convention
}

// Wrapper class for `NGEAppGroupType` Manifest object
open class NGDMAppGroup {
    
    // MARK: Instance Variables
    /// Unique identifier
    var id: String
    open var analyticsIdentifier: String {
        return id
    }
    
    /// URL associated with this AppGroup
    public var url: URL?
    
    /// The execution runtime environment for the interactive content
    public var runtimeEnvironment = RuntimeEnvironment.other
    
    // MARK: Initialization
    /**
        Initializes a new AppGroup
    
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    init(manifestObject: NGEAppGroupType) {
        id = manifestObject.AppGroupID
        
        if let interactiveTrackReference = manifestObject.InteractiveTrackReferenceList?.first {
            if let id = interactiveTrackReference.InteractiveTrackID {
                url = NGDMInteractive.getById(id)?.url
            }
            
            if let runtimeEnvironment = interactiveTrackReference.CompatibilityList?.first?.RuntimeEnvironment {
                self.runtimeEnvironment = (RuntimeEnvironment(rawValue: runtimeEnvironment) ?? .other)
            }
        }
    }
    
    // MARK: Search Methods
    /**
        Find an `NGDMAppGroup` object by unique identifier
    
        - Parameters:
            - id: Unique identifier to search for
    
        - Returns: Object associated with identifier if it exists
    */
    static func getById(_ id: String) -> NGDMAppGroup? {
        return NGDMManifest.sharedInstance.appGroups[id]
    }
    
}
