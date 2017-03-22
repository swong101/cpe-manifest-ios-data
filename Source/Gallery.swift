//
//  Gallery.swift
//

import Foundation
import SWXMLHash

open class Gallery: MetadataDriven, Trackable {

    private struct Constants {
        static let SubTypeTurntable = "Turntable"
    }

    private struct Attributes {
        static let GalleryID = "GalleryID"
    }

    private struct Elements {
        static let GalleryType = "Type"
        static let SubType = "SubType"
        static let PictureGroupID = "PictureGroupID"
        static let GalleryName = "GalleryName"
    }

    var id: String
    var type: String?
    var subTypes: [String]?
    var pictureGroupID: String?
    var names: [String]?

    var customPictureGroup: PictureGroup?
    open var pictureGroup: PictureGroup? {
        if let pictureGroup = customPictureGroup {
            return pictureGroup
        }

        return CPEXMLSuite.current?.manifest.pictureGroupWithID(pictureGroupID)
    }

    override open var title: String? {
        return (names?.first ?? super.title)
    }

    override open var thumbnailImageURL: URL? {
        return (super.thumbnailImageURL ?? pictureGroup?.thumbnailImageURL)
    }

    open var isTurntable: Bool {
        if let subTypes = subTypes {
            return subTypes.contains(Constants.SubTypeTurntable)
        }

        return false
    }

    // Trackable
    public var analyticsID: String {
        return id
    }

    init?(imageURLs: [URL]) {
        id = UUID().uuidString
        customPictureGroup = PictureGroup(imageURLs: imageURLs)

        super.init()
    }

    override init?(indexer: XMLIndexer) throws {
        // GalleryID
        guard let id = indexer.stringValue(forAttribute: Attributes.GalleryID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.GalleryID, element: indexer.element)
        }

        self.id = id

        // Type
        guard let type = indexer.stringValue(forElement: Elements.GalleryType) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.GalleryType, element: indexer.element)
        }

        self.type = type

        // SubType
        if indexer.hasElement(Elements.SubType) {
            subTypes = indexer[Elements.SubType].flatMap({ $0.stringValue })
        }

        // PictureGroupID
        guard let pictureGroupID = indexer.stringValue(forElement: Elements.PictureGroupID) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.PictureGroupID, element: indexer.element)
        }

        self.pictureGroupID = pictureGroupID

        // GalleryName
        if indexer.hasElement(Elements.GalleryName) {
            names = indexer[Elements.GalleryName].flatMap({ $0.stringValue })
        }

        try super.init(indexer: indexer)
    }

}
