//
//  PictureGroup.swift
//

import Foundation
import SWXMLHash

open class Picture {

    private struct Elements {
        static let PictureID = "PictureID"
        static let ImageID = "ImageID"
        static let ThumbnailImageID = "ThumbnailImageID"
        static let Caption = "Caption"
        static let Sequence = "Sequence"
    }

    var id: String
    var imageID: String?
    var thumbnailImageID: String?
    var captions: [String]?
    public var sequence: UInt = 0

    var customImageURL: URL?
    open var imageURL: URL? {
        if let imageURL = customImageURL {
            return imageURL
        }

        return CPEXMLSuite.current?.manifest.imageWithID(imageID)?.url
    }

    open var thumbnailImageURL: URL? {
        return (CPEXMLSuite.current?.manifest.imageWithID(thumbnailImageID)?.url ?? imageURL)
    }

    open var caption: String? {
        return captions?.first
    }

    init(imageURL: URL) {
        id = UUID().uuidString
        customImageURL = imageURL
    }

    init(indexer: XMLIndexer) throws {
        // PictureID
        guard let id = indexer.stringValue(forElement: Elements.PictureID) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.PictureID, element: indexer.element)
        }

        self.id = id

        // ImageID
        guard let imageID = indexer.stringValue(forElement: Elements.ImageID) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.ImageID, element: indexer.element)
        }

        self.imageID = imageID

        // ThumbnailImageID
        thumbnailImageID = indexer.stringValue(forElement: Elements.ThumbnailImageID)

        // Caption
        if indexer.hasElement(Elements.Caption) {
            captions = indexer[Elements.Caption].flatMap({ $0.stringValue })
        }

        // Sequence
        sequence = (indexer.uintValue(forElement: Elements.Sequence) ?? 0)
    }

}

public class PictureGroup {

    private struct Attributes {
        static let PictureGroupID = "PictureGroupID"
    }

    private struct Elements {
        static let Picture = "Picture"
    }

    var id: String?
    public var pictures: [Picture]

    open var thumbnailImageURL: URL? {
        return pictures.first?.thumbnailImageURL
    }

    init(imageURLs: [URL]) {
        pictures = imageURLs.map({ Picture(imageURL: $0) })
    }

    init(indexer: XMLIndexer) throws {
        // PictureGroupID
        guard let id = indexer.stringValue(forAttribute: Attributes.PictureGroupID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.PictureGroupID, element: indexer.element)
        }

        self.id = id

        // Picture
        guard indexer.hasElement(Elements.Picture) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Picture, element: indexer.element)
        }

        var pictures = [Picture]()
        for indexer in indexer[Elements.Picture] {
            let picture = try Picture(indexer: indexer)
            pictures.append(picture)
            CPEXMLSuite.current?.manifest.addPicture(picture)
        }

        self.pictures = pictures
    }

}
