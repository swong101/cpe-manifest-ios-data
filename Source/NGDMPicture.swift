//
//  NGDMPicture.swift
//

import Foundation

// Wrapper class for `NGEPictureType` Manifest object
open class NGDMPicture {
    
    // MARK: Instance Variables
    /// Unique identifier
    var id: String
    
    /// Image URL to be used for full display
    var image: NGDMImage?
    private var _imageURL: URL?
    public var imageURL: URL? {
        return (_imageURL ?? image?.url)
    }
    
    public var imageID: String? {
        return image?.id
    }
    
    /// Image URL to be used for thumbnail display
    private var thumbnailImage: NGDMImage?
    public var thumbnailImageURL: URL? {
        return (thumbnailImage?.url ?? imageURL)
    }
    
    /// Caption associated with this image
    private var captions: [String: String]? // Language: Caption
    public var caption: String? {
        if let caption = captions?[Locale.deviceLanguage()] {
            return caption
        }
        
        return captions?[Locale.deviceLanguageBackup()]
    }
    
    // MARK: Initialization
    /**
        Initializes a new Picture based on Manifest object
    
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    init(manifestObject: NGEPictureType) {
        id = manifestObject.PictureID
        
        if let id = manifestObject.ImageID {
            image = NGDMImage.getById(id)
        }
        
        if let id = manifestObject.ThumbnailImageID {
            thumbnailImage = NGDMImage.getById(id)
        }
        
        captions = [String: String]()
        if let objList = manifestObject.CaptionList {
            for obj in objList {
                let language = obj.language ?? Locale.deviceLanguage()
                if let value = obj.value {
                    captions![language] = value
                }
            }
        }
    }
    
    /**
        Initializes a new Picture based on image URL
     
        - Parameters:
            - imageURL: Image URL to be used for full display
     */
    public init(imageURL: URL) {
        id = UUID().uuidString
        _imageURL = imageURL
    }
    
    // MARK: Search Methods
    /**
        Find an `NGDMPicture` object by unique identifier
     
        - Parameters:
            - id: Unique identifier to search for
     
        - Returns: Object associated with identifier if it exists
     */
    static func getById(_ id: String) -> NGDMPicture? {
        return NGDMManifest.sharedInstance.pictures[id]
    }
    
}
