//
//  NGDMAppData.swift
//

import Foundation

public struct AppDataNVPairName {
    // Global
    static let AppType = "type"
    static let Text = "text"
    static let DisplayOrder = "display_order"
    static let ContentID = "content_id"
    static let ParentContentID = "parent_content_id"
    static let ExperienceID = "experience_id"
    static let VideoID = "video_id"
    static let GalleryID = "gallery_id"
    static let VideoThumbnail = "video_thumbnail"
    static let GalleryThumbnail = "gallery_thumbnail"
    
    // Location
    static let Location = "location"
    static let LocationThumbnail = "location_thumbnail"
    static let Zoom = "zoom"
    static let ZoomLocked = "zoom_locked"
    
    // Product
    static let ExternalURL = "external_url"
    static let Price = "price"
    static let ExactMatch = "exact_match"
    static let ProductImageBullseyeX = "product_image_bullseye_x"
    static let ProductImageBullseyeY = "product_image_bullseye_y"
    static let SceneImage = "scene_image"
    static let SceneImageBullseyeX = "scene_image_bullseye_x"
    static let SceneImageBullseyeY = "scene_image_bullseye_y"
}

// Wrapper class for `NGEAppDataType` Manifest object
open class NGDMAppData {
    
    // MARK: Instance Variables
    /// Unique identifier
    var id: String!
    open var analyticsIdentifier: String {
        return id
    }
    
    /// Metadata
    var metadata: NGDMMetadata?
    var parentMetadata: NGDMMetadata?
    
    public var title: String? {
        return (experience?.title ?? metadata?.title)
    }
    
    public var thumbnailImageURL: URL? {
        return (experience?.imageURL ?? metadata?.imageURL)
    }
    
    public var description: String? {
        return (experience?.description ?? metadata?.description)
    }
    
    public var displayOrder: Int = 0
    
    /// Media
    var experience: NGDMExperience?
    public var mediaCount: Int {
        return (experience?.childExperiences?.count ?? 0)
    }
    
    // MARK: Initialization
    /**
        Initializes a new AppData
     
        - Parameters:
            - manifestObject: Raw Manifest data object
     */
    init(manifestObject: NGEAppDataType) {
        id = manifestObject.AppID
        
        for obj in manifestObject.NVPairList {
            if let name = obj.Name {
                switch name {
                case AppDataNVPairName.ExperienceID:
                    if let id = obj.ExperienceID {
                        experience = NGDMExperience.getById(id)
                    }
                    break
                    
                case AppDataNVPairName.ContentID:
                    if let id = obj.ContentID {
                        metadata = NGDMMetadata.getById(id)
                    }
                    break
                    
                case AppDataNVPairName.ParentContentID:
                    if let id = obj.ContentID {
                        parentMetadata = NGDMMetadata.getById(id)
                    }
                    break
                    
                case AppDataNVPairName.DisplayOrder:
                    if let displayOrder = obj.Integer {
                        self.displayOrder = displayOrder
                    }
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: Helper Methods
    /**
        Finds the Experience media associated with the AppData at the specified index
     
        - Parameters:
            - index: Media index to search
     
        - Returns: Associated Experience if it exists
     */
    public func mediaAtIndex(_ index: Int) -> NGDMExperience? {
        return (index < mediaCount ? experience?.childExperiences?[index] : nil)
    }
    
}
