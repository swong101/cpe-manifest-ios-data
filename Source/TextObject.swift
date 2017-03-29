//
//  TextObject.swift
//

import Foundation
import SWXMLHash

open class TextObject {

    private struct Attributes {
        static let TextObjectID = "TextObjectID"
        static let Language = "language"
        static let Index = "index"
    }

    private struct Elements {
        static let TextString = "TextString"
    }

    var id: String
    private var language: String?
    private var textStrings: [Int: String?]

    init(indexer: XMLIndexer) throws {
        // TextObjectID
        guard let id = indexer.stringValue(forAttribute: Attributes.TextObjectID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.TextObjectID, element: indexer.element)
        }

        self.id = id

        // Language
        language = indexer.stringValue(forAttribute: Attributes.Language)

        // TextString
        guard indexer.hasElement(Elements.TextString) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.TextString, element: indexer.element)
        }

        textStrings = [Int: String?]()
        var i = 1
        for indexer in indexer[Elements.TextString] {
            textStrings[indexer.intValue(forAttribute: Attributes.Index) ?? i] = indexer.stringValue
            i += 1
        }
    }

    // MARK: Helper Methods
    /**
        Find child TextString object by index

        - Parameters:
            - index: The index of the child TextString to look up

        - Returns: Value of the child TextString at the given `index` if it exists
    */
    open func textItem(_ index: Int) -> String? {
        if let string = textStrings[index] {
            return string
        }

        return nil
    }

}
