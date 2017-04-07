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

    open var textObject: TextObject? {
        return CPEXMLSuite.current?.manifest.textObjectWithID(textObjectIDs.first)
    }

    init(indexer: XMLIndexer) throws {
        // TextGroupID
        guard let id: String = indexer.value(ofAttribute: Attributes.TextGroupID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.TextGroupID, element: indexer.element)
        }

        self.id = id

        // Language
        language = indexer.value(ofAttribute: Attributes.Language)

        // TextObjectID
        guard indexer.hasElement(Elements.TextObjectID) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.TextObjectID, element: indexer.element)
        }

        textObjectIDs = try indexer[Elements.TextObjectID].value()
    }

}
