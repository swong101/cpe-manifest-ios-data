//
//  MetadataDriven.swift
//

import Foundation
import SWXMLHash

open class MetadataDriven {

    private struct Attributes {
        static let ContentID = "ContentID"
    }

    private struct Elements {
        static let ContentID = "ContentID"
    }

    var contentID: String?

    open var metadata: Metadata? {
        return CPEXMLSuite.current?.manifest.metadataWithID(contentID)
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
        contentID = (indexer.stringValue(forAttribute: Attributes.ContentID) ?? indexer.stringValue(forElement: Elements.ContentID))
    }

}
