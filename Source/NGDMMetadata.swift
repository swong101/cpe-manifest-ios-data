//
//  NGDMMetadata.swift
//

import Foundation

// Wrapper class for `NGEBasicMetadataInfoType` Manifest object
open class NGDMLocalizedInfo {
    
    /// Metadata
    var language: String
    var title: String
    var description: String?
    var imageURL: URL?
    
    // MARK: Initialization
    /**
        Initializes a new LocalizedInfo
     
        - Parameters:
            - manifestObject: Raw Manifest data object
     */
    init(manifestObject: NGEBasicMetadataInfoType) {
        language = manifestObject.language
        title = manifestObject.TitleDisplayUnlimited ?? manifestObject.TitleDisplay60 ?? manifestObject.TitleDisplay19 ?? manifestObject.TitleSort
        description = manifestObject.Summary4000?.value ?? manifestObject.Summary400?.value ?? manifestObject.Summary190.value
        
        if let url = manifestObject.ArtReferenceList?.first?.value {
            if url.contains("file://") {
                let tempURL = URL(fileURLWithPath: url.replacingOccurrences(of: "file://", with: ""))
                imageURL = Bundle.main.url(forResource: tempURL.deletingPathExtension().path, withExtension: tempURL.pathExtension)
            } else {
                imageURL = URL(string: url)
            }
        }
    }
    
}

// Wrapper class for `NGEInventoryMetadataType` Manifest object
open class NGDMMetadata {
    
    // MARK: Static Variables
    /// Static mapping of all Metadatas - ContentID: Metadata
    private static var objectMap = [String: NGDMMetadata]()
    
    // MARK: Instance Variables
    /// Unique identifier
    var id: String
    
    /// Mapping of all LocalizedInfos for this Metadata - Language: LocalizedInfo
    private var defaultLocalizedInfo: NGDMLocalizedInfo?
    private var localizedInfoMap = [String: NGDMLocalizedInfo]()
    private var localizedInfo: NGDMLocalizedInfo? {
        return localizedInfoMap[Locale.deviceLanguage] ?? localizedInfoMap[Locale.deviceLanguageBackup] ?? defaultLocalizedInfo ?? localizedInfoMap["en-US"] ?? localizedInfoMap["en"]
    }
    
    /// Mapping of all content identifiers for this Metadata - Namespace: Identifier
    private var contentIdentifiers: [String: String]?
    
    /// Full title associated with this Metadata
    var title: String? {
        return localizedInfo?.title
    }
    
    /// Full description or summary associated with this Metadata
    var description: String? {
        return localizedInfo?.description
    }
    
    /// Image URL to be used for display
    var imageURL: URL? {
        return localizedInfo?.imageURL
    }
    
    /// Mapping of all Talents for this Metadata - PeopleOtherID: Talent
    var talents: [String: NGDMTalent]?
    
    // MARK: Initialization
    /**
        Initializes a new Metadata
     
        - Parameters:
            - manifestObject: Raw Manifest data object
     */
    init(manifestObject: NGEInventoryMetadataType) {
        id = manifestObject.ContentID
        
        if let objList = manifestObject.BasicMetadata?.LocalizedInfoList {
            for obj in objList {
                let localizedInfo = NGDMLocalizedInfo(manifestObject: obj)
                localizedInfoMap[localizedInfo.language] = localizedInfo
                
                if obj.isDefault != nil && obj.isDefault! {
                    defaultLocalizedInfo = localizedInfo
                }
            }
        }
        
        if let objList = manifestObject.BasicMetadata?.AltIdentifierList {
            contentIdentifiers = [String: String]()
            
            for obj in objList {
                contentIdentifiers![obj.Namespace] = obj.Identifier
            }
        }
        
        if let objList = manifestObject.BasicMetadata?.PeopleList {
            talents = [String: NGDMTalent]()
            
            for obj in objList {
                let talent = NGDMTalent(manifestObject: obj)
                talents![talent.id] = talent
            }
        }
    }
    
    // MARK: Helper Methods
    /**
        Find any custom identifier associated with this Experience
     
        - Parameters:
            - namespace: The namespace of the custom identifier used in the Manifest
     
        - Returns: The value of the custom identifier if it exists
     */
    func customIdentifier(_ namespace: String) -> String? {
        return contentIdentifiers?[namespace]
    }
    
    // MARK: Search Methods
    /**
        Find an `NGDMMetadata` object by unique identifier
     
        - Parameters:
            - id: Unique identifier to search for
     
        - Returns: Object associated with identifier if it exists
     */
    static func getById(_ id: String) -> NGDMMetadata? {
        return NGDMManifest.sharedInstance.metadatas[id]
    }
    
}
