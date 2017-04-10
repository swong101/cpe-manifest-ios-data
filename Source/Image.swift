//
//  Image.swift
//

import Foundation
import SWXMLHash

private enum ImageEncoding: String {
    case jpeg = "image/jpeg"
    case jpg = "image/jpg"
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
        guard let id: String = indexer.value(ofAttribute: Attributes.ImageID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.ImageID, element: indexer.element)
        }

        self.id = id

        // Width
        // Height
        guard let width: Int = try indexer[Elements.Width].value() else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Width, element: indexer.element)
        }

        guard let height: Int = try indexer[Elements.Height].value() else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Height, element: indexer.element)
        }

        size = CGSize(width: width, height: height)

        // Encoding
        guard let encodingString: String = try indexer[Elements.Encoding].value() else {
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
