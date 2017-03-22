//
//  ContentIdentifier.swift
//

import Foundation
import SWXMLHash

struct ContentIdentifier {

    private struct Elements {
        static let Namespace = "Namespace"
        static let Identifier = "Identifier"
        static let Location = "Location"
        static let ReferenceLocation = "ReferenceLocation"
    }

    var namespace: String
    var identifier: String
    var location: URL?

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
