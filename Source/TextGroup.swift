//
//  TextGroup.swift
//

import Foundation
import SWXMLHash

open class TextGroup {

    private struct Attributes {
        static let TextGroupID = "TextGroupID"
        static let Language = "language"
    }

    private struct Elements {
        static let TextObjectID = "TextObjectID"
    }

    var id: String
    var language: String?
    var textObjectIDs: [String]

    // Computed values
    open var textObject: TextObject? {
        return CPEXMLSuite.current?.manifest.textObjectWithID(textObjectIDs.first)
    }

    init(indexer: XMLIndexer) throws {
        // TextGroupID
        guard let id = indexer.stringValue(forAttribute: Attributes.TextGroupID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.TextGroupID, element: indexer.element)
        }

        self.id = id

        // Language
        language = indexer.stringValue(forAttribute: Attributes.Language)

        // TextObjectID
        guard indexer.hasElement(Elements.TextObjectID) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.TextObjectID, element: indexer.element)
        }

        textObjectIDs = indexer[Elements.TextObjectID].flatMap({ $0.stringValue })
    }

}
