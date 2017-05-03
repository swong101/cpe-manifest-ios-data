//
//  Image.swift
//

import Foundation
import SWXMLHash

/**
    Supported image types
 
    - jpeg: JPEG
    - jpg: JPEG
    - png: PNG
 */
public enum ImageEncoding: String {
    case jpeg = "image/jpeg"
    case jpg = "image/jpg"
    case png = "image/png"
}

/// Displayable image asset
open class Image: DigitalAsset {

    /// Supported XML attribute keys
    private struct Attributes {
        static let ImageID = "ImageID"
    }

    /// Supported XML element tags
    private struct Elements {
        static let Width = "Width"
        static let Height = "Height"
        static let Encoding = "Encoding"
    }

    /// Unique identifier
    public var id: String

    /// Size of the image, in pixels
    public var size: CGSize

    /// Image file/encoding type
    public var encoding: ImageEncoding

    /**
         Initializes a new image asset with the provided XML indexer
         
         - Parameter indexer: The root XML node
         - Throws:
             - `ManifestError.missingRequiredAttribute` if an expected XML attribute is not present
             - `ManiefstError.missingRequiredChildElement` if an expected XML element is not present
     */
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
