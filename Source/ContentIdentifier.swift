//
//  ContentIdentifier.swift
//

import Foundation
import SWXMLHash

/// A custom, namespaced identifier for a piece of content
public struct ContentIdentifier {

    /// Supported XML element tags
    private struct Elements {
        static let Namespace = "Namespace"
        static let Identifier = "Identifier"
        static let Location = "Location"
        static let ReferenceLocation = "ReferenceLocation"
    }

    /// Identifier's namespace
    public var namespace: String

    /// Identifier's value
    public var identifier: String

    /// URL associated with the identifier
    public var location: URL?

    /**
        Initializes a new custom identifier with the provided XML indexer
     
        - Parameter indexer: The root XML node
        - Throws: `ManiefstError.missingRequiredChildElement` if an expected XML element is not present
     */
    init(indexer: XMLIndexer) throws {
        // Namespace
        guard let namespace = indexer.stringValue(forElement: Elements.Namespace) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Namespace, element: indexer.element)
        }

        self.namespace = namespace

        // Identifier
        guard let identifier = indexer.stringValue(forElement: Elements.Identifier) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Identifier, element: indexer.element)
        }

        self.identifier = identifier

        // Location
        location = (indexer.urlValue(forElement: Elements.Location) ?? indexer.urlValue(forElement: Elements.ReferenceLocation))
    }

}
