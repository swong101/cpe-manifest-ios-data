//
//  Image.swift
//

import Foundation
import SWXMLHash

private enum ImageEncoding: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
}

open class Image: DigitalAsset {

    private struct Attributes {
        static let ImageID = "ImageID"
    }

    private struct Elements {
        static let Width = "Width"
        static let Height = "Height"
        static let Encoding = "Encoding"
    }

    var id: String
    open var size: CGSize
    private var encoding: ImageEncoding

    override init?(indexer: XMLIndexer) throws {
        // ImageID
        guard let id = indexer.stringValue(forAttribute: Attributes.ImageID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.ImageID, element: indexer.element)
        }

        self.id = id

        // Width
        // Height
        guard let width = indexer.intValue(forElement: Elements.Width) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Width, element: indexer.element)
        }

        guard let height = indexer.intValue(forElement: Elements.Height) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Height, element: indexer.element)
        }

        size = CGSize(width: width, height: height)

        // Encoding
        guard let encodingString = indexer.stringValue(forElement: Elements.Encoding) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Encoding, element: indexer.element)
        }

        guard let encoding = ImageEncoding(rawValue: encodingString) else {
            print("Ignoring unsupported Image object with Encoding \"\(encodingString)\"")
            return nil
        }

        self.encoding = encoding

        // DigitalAsset
        try super.init(indexer: indexer)
    }

}
