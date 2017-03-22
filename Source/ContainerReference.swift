//
//  ContainerReference.swift
//

import Foundation
import SWXMLHash

class ContainerReference {

    private struct Attributes {
        static let Priority = "priority"
    }

    private struct Elements {
        static let ContainerLocation = "ContainerLocation"
        static let ParentContainer = "ParentContainer"
        static let ContainerIdentifier = "ContainerIdentifier"
        static let Length = "Length"
        static let Hash = "Hash"
    }

    private var locations: [URL]?
    private var parentContainer: ContainerReference?
    private var identifiers: [ContentIdentifier]?
    private var length: UInt?
    private var hashes: [Hash]?

    // Computed values
    var url: URL? {
        return locations?.first
    }

    init(indexer: XMLIndexer) throws {
        // ContainerLocation
        if indexer.hasElement(Elements.ContainerLocation) {
            var locations = [URL?](repeating: nil, count: indexer[Elements.ContainerLocation].all.count)
            for indexer in indexer[Elements.ContainerLocation] {
                if let url = indexer.urlValue {
                    var index = 0
                    if let priority = indexer.intValue(forAttribute: Attributes.Priority) {
                        index = min(priority - 1, 0)
                    }

                    locations.insert(url, at: index)
                }
            }

            self.locations = locations.flatMap { $0 }
        }

        // ParentContainer
        if indexer.hasElement(Elements.ParentContainer) {
            parentContainer = try ContainerReference(indexer: indexer[Elements.ParentContainer])
        }

        // ContainerIdentifier
        if indexer.hasElement(Elements.ContainerIdentifier) {
            identifiers = try indexer[Elements.ContainerIdentifier].map({ try ContentIdentifier(indexer: $0) })
        }

        // Length
        length = indexer.uintValue(forElement: Elements.Length)

        // Hash
        if indexer.hasElement(Elements.Hash) {
            hashes = try indexer[Elements.Hash].map({ try Hash(indexer: $0) })
        }
    }

}
