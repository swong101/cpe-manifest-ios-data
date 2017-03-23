//
//  AppData.swift
//

import Foundation
import SWXMLHash

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

open class AppDataItem: Trackable {

    internal struct Attributes {
        static let AppID = "AppID"
        static let Name = "Name"
        static let Currency = "currency"
    }

    internal struct Elements {
        static let NVPair = "NVPair"
        static let ExperienceID = "ExperienceID"
        static let ContentID = "ContentID"
        static let LocationSet = "LocationSet"
        static let Location = "Location"
        static let URL = "URL"
        static let Money = "Money"
        static let Text = "Text"
        static let PictureID = "PictureID"
        static let Decimal = "Decimal"
        static let Integer = "Integer"
    }

    var id: String
    var experienceID: String?
    var contentID: String?
    var parentContentID: String?

    lazy var metadata: Metadata? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.metadataWithID(self.contentID)
    }()

    lazy var parentMetadata: Metadata? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.metadataWithID(self.parentContentID)
    }()

    open var title: String? {
        if let title = experience?.title {
            return title
        }

        return metadata?.title
    }

    open var description: String? {
        return (experience?.description ?? metadata?.description)
    }

    open var thumbnailImageURL: URL? {
        return (experience?.thumbnailImageURL ?? metadata?.imageURL)
    }

    open var displayOrder: Int = 0

    open lazy var experience: Experience? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.experienceWithID(self.experienceID)
    }()

    open var mediaCount: Int {
        return (experience?.experienceChildren?.count ?? 0)
    }
    
    // Trackable
    open var analyticsID: String {
        return id
    }

    init(indexer: XMLIndexer) throws {
        // AppID
        guard let id = indexer.stringValue(forAttribute: Attributes.AppID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.AppID, element: indexer.element)
        }

        self.id = id

        // NVPair
        guard indexer.hasElement(Elements.NVPair) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.NVPair, element: indexer.element)
        }

        for indexer in indexer[Elements.NVPair] {
            // Name
            guard let name = indexer.stringValue(forAttribute: Attributes.Name) else {
                throw ManifestError.missingRequiredAttribute(Attributes.Name, element: indexer.element)
            }

            switch name {
            case AppDataNVPairName.ExperienceID:
                // ExperienceID
                guard let experienceID = indexer.stringValue(forElement: Elements.ExperienceID) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.ExperienceID, element: indexer.element)
                }

                self.experienceID = experienceID
                break

            case AppDataNVPairName.ContentID:
                // ContentID
                guard let contentID = indexer.stringValue(forElement: Elements.ContentID) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.ContentID, element: indexer.element)
                }

                self.contentID = contentID
                break

            case AppDataNVPairName.ParentContentID:
                // Content ID
                guard let parentContentID = indexer.stringValue(forElement: Elements.ContentID) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.ContentID, element: indexer.element)
                }

                self.parentContentID = parentContentID
                break

            case AppDataNVPairName.DisplayOrder:
                guard let displayOrder = indexer.intValue(forElement: Elements.Integer) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.Integer, element: indexer.element)
                }

                self.displayOrder = displayOrder
                break

            default:
                break
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
    open func mediaAtIndex(_ index: Int) -> Experience? {
        return (index < mediaCount ? experience?.childExperiences?[index] : nil)
    }

}
