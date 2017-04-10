//
//  ContentIdentifier.swift
//

import Foundation
import SWXMLHash

/// A custom, namespaced identifier for a piece of content
public struct ContentIdentifier: XMLIndexerDeserializable {

    /// Supported XML element tags
    private struct Elements {
        static let Namespace = "Namespace"
        static let Identifier = "Identifier"
    }

    /// Identifier's namespace
    public var namespace: String

    /// Identifier's value
    public var identifier: String

    public static func deserialize(_ node: XMLIndexer) throws -> ContentIdentifier {
        return try ContentIdentifier(
            namespace: node[Elements.Namespace].value(),
            identifier: node[Elements.Identifier].value()
        )
    }

}
