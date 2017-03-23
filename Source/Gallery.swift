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

    private var _pictureGroup: PictureGroup?
    open lazy var pictureGroup: PictureGroup? = { [unowned self] in
        return (self._pictureGroup ?? CPEXMLSuite.current?.manifest.pictureGroupWithID(self.pictureGroupID))
    }()

    override open var title: String? {
        return (names?.first ?? super.title)
    }

    override open var thumbnailImageURL: URL? {
        return (super.thumbnailImageURL ?? pictureGroup?.thumbnailImageURL)
    }

    open lazy var isTurntable: Bool = { [unowned self] in
        return (self.subTypes?.contains(Constants.SubTypeTurntable) ?? false)
    }()

    open var numPictures: Int {
        return (pictureGroup?.numPictures ?? 0)
    }

    // Trackable
    open var analyticsID: String {
        return id
    }

    public init?(imageURLs: [URL]) {
        id = UUID().uuidString
        _pictureGroup = PictureGroup(imageURLs: imageURLs)

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

    public func picture(atIndex index: Int) -> Picture? {
        if let pictures = pictureGroup?.pictures, pictures.count > index {
            return pictures[index]
        }

        return nil
    }

}
