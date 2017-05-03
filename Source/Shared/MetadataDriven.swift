//
//  MetadataDriven.swift
//

import Foundation
import SWXMLHash

open class MetadataDriven {

    /// Supported XML attribute keys
    private struct Attributes {
        static let ContentID = "ContentID"
    }

    /// Supported XML element tags
    private struct Elements {
        static let ContentID = "ContentID"
    }

    /// Unique identifier for `Metadata` object
    public var contentID: String?

    private var _metadata: Metadata?
    open var metadata: Metadata? {
        get {
            return (_metadata ?? CPEXMLSuite.current?.manifest.metadataWithID(contentID))
        }

        set {
            _metadata = newValue
        }
    }

    open var title: String? {
        return metadata?.title
    }

    open var description: String? {
        return metadata?.description
    }

    open var thumbnailImageURL: URL? {
        return metadata?.imageURL
    }

    init?() {

    }

    init?(indexer: XMLIndexer) throws {
        // ContentID
        contentID = try (indexer.value(ofAttribute: Attributes.ContentID) ?? indexer[Elements.ContentID].value())
    }

}
