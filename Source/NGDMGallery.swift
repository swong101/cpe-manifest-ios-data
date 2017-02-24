//
//  NGDMGallery.swift
//

import Foundation

public enum GallerySubType: String {
    case Gallery = "Gallery"
    case Turntable = "Turntable"
}

// Wrapper class for `NGEGalleryType` Manifest object
open class NGDMGallery {
    
    private struct Constants {
        static let SubTypeTurntable = "Turntable"
    }
    
    // MARK: Instance Variables
    /// Unique identifier
    var id: String
    open var analyticsIdentifier: String {
        return id
    }
    
    /// Metadata
    private var metadata: NGDMMetadata?
    private var galleryName: String?
    
    public var title: String? {
        return (galleryName ?? metadata?.title)
    }
    
    /// Description to be used for display
    public var description: String? {
        return metadata?.description
    }
    
    /// Thumbnail image URL to be used for display
    public var thumbnailImageURL: URL?
    
    /// Pictures associated with this Gallery
    public var pictures: [NGDMPicture]
    
    /// Whether or not this Gallery should be displayed as a turntable
    private var subType = GallerySubType.Gallery
    public var isTurntable: Bool {
        return isSubType(.Turntable)
    }
    
    /// Total number of items in this gallery
    public var totalCount: Int {
        return pictures.count
    }
    
    // MARK: Initialization
    /**
        Initializes a new Gallery based on Manifest object
    
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    init(manifestObject: NGEGalleryType) {
        id = manifestObject.GalleryID ?? UUID().uuidString
        
        if let id = manifestObject.ContentID {
            metadata = NGDMMetadata.getById(id)
        }
        
        if let subTypeString = manifestObject.SubTypeList?.first, let subType = GallerySubType(rawValue: subTypeString) {
            self.subType = subType
        }
        
        if let id = manifestObject.PictureGroupID, let pictures = NGDMManifest.sharedInstance.pictureGroups[id] {
            if subType == .Turntable {
                self.pictures = [NGDMPicture]()
                
                var turntableStrideBy = 1
                if #available(iOS 9.3, *) {
                    turntableStrideBy = 4
                } else {
                    turntableStrideBy = 10
                }
                
                for i in stride(from: 0, to: pictures.count, by: turntableStrideBy) {
                    self.pictures.append(pictures[i])
                }
            } else {
                self.pictures = pictures
            }
        } else {
            pictures = [NGDMPicture]()
        }
        
        galleryName = manifestObject.GalleryNameList?.first?.value
        thumbnailImageURL = (metadata?.imageURL ?? pictures.first?.thumbnailImageURL)
    }
 
    /**
        Initializes a new Gallery based on list of Pictures
     
        - Parameters:
            - pictures: Pictures associated with this Gallery
     */
    public init(pictures: [NGDMPicture]) {
        id = UUID().uuidString
        self.pictures = pictures
    }
    
    // MARK: Helper Methods
    /**
        Check if Gallery is of the specified sub-type
            - Parameters:
                - type: Sub-type of TimedEvent
     
            - Returns: `true` if the Gallery is of the specified sub-type
                - pictures: Pictures associated with this Gallery
    */
    public func isSubType(_ subType: GallerySubType) -> Bool {
        return (self.subType == subType)
    }
    
    /**
        Get the Picture associated with the given page number
 
        - Parameters:
            - page: Page number
 
        - Returns:
            - Picture for the given page number, if one exists
    */
    public func getPictureForPage(_ page: Int) -> NGDMPicture? {
        return (pictures.count > page ? pictures[page] : nil)
    }
    
    /**
        Get the image URL for the Picture associated with the given page number
 
        - Parameters:
            - page: Page number
 
        - Returns:
            - Image URL for the given page number, if one exists
    */
    public func getImageURLForPage(_ page: Int) -> URL? {
        return getPictureForPage(page)?.imageURL
    }
    
    // MARK: Search Methods
    /**
        Find an `NGDMGallery` object by unique identifier
     
        - Parameters:
            - id: Unique identifier to search for
     
        - Returns: Object associated with identifier if it exists
     */
    static func getById(_ id: String) -> NGDMGallery? {
        return NGDMManifest.sharedInstance.galleries[id]
    }
    
}
