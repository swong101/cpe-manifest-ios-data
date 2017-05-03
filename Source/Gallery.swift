//
//  Gallery.swift
//

import Foundation
import SWXMLHash

open class Gallery: MetadataDriven, Trackable {

    /// Supported subtypes
    private struct Constants {
        static let SubTypeTurntable = "Turntable"
    }

    /// Supported XML attribute keys
    private struct Attributes {
        static let GalleryID = "GalleryID"
    }

    /// Supported XML element tags
    private struct Elements {
        static let GalleryType = "Type"
        static let SubType = "SubType"
        static let PictureGroupID = "PictureGroupID"
        static let GalleryName = "GalleryName"
    }

    /// Unique identifier
    public var id: String
    public var type: String?
    public var subTypes: [String]?
    public var pictureGroupID: String?
    public var names: [String]?

    private var _pictureGroup: PictureGroup?
    open var pictureGroup: PictureGroup? {
        return (_pictureGroup ?? CPEXMLSuite.current?.manifest.pictureGroupWithID(pictureGroupID))
    }

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

    /// Tracking identifier
    open var analyticsID: String {
        return id
    }

    public init?(imageURLs: [URL]) {
        id = UUID().uuidString
        _pictureGroup = PictureGroup(imageURLs: imageURLs)

        super.init()
    }

    public init?(pictures: [Picture]) {
        id = UUID().uuidString
        _pictureGroup = PictureGroup(pictures: pictures)

        super.init()
    }

    public init?(pictureGroup: PictureGroup) {
        id = UUID().uuidString
        _pictureGroup = pictureGroup

        super.init()
    }

    override init?(indexer: XMLIndexer) throws {
        // GalleryID
        guard let id: String = indexer.value(ofAttribute: Attributes.GalleryID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.GalleryID, element: indexer.element)
        }

        self.id = id

        // Type
        guard let type: String = try indexer[Elements.GalleryType].value() else {
            throw ManifestError.missingRequiredChildElement(name: Elements.GalleryType, element: indexer.element)
        }

        self.type = type

        // SubType
        subTypes = try indexer[Elements.SubType].value()

        // PictureGroupID
        guard let pictureGroupID: String = try indexer[Elements.PictureGroupID].value() else {
            throw ManifestError.missingRequiredChildElement(name: Elements.PictureGroupID, element: indexer.element)
        }

        self.pictureGroupID = pictureGroupID

        // GalleryName
        names = try indexer[Elements.GalleryName].value()

        try super.init(indexer: indexer)
    }

    public func picture(atIndex index: Int) -> Picture? {
        return pictureGroup?.picture(atIndex: index)
    }

}
