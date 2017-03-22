//
//  DigitalAsset.swift
//

import Foundation
import SWXMLHash

class DigitalAssetEncoding {

    private struct Elements {
        static let CodecType = "CodecType"
        static let BitrateMax = "BitrateMax"
        static let BitrateAverage = "BitrateAverage"
        static let VBR = "VBR"
        static let ActualLength = "ActualLength"
    }

    var codecTypes: [String]?
    var bitrateMax: Int?
    var bitrateAverage: Int?
    var vbr: String?
    var actualLength: TimeInterval = 0

    init?(indexer: XMLIndexer) throws {
        // CodecType
        if indexer[Elements.CodecType].hasChildren {
            codecTypes = indexer[Elements.CodecType].flatMap({ $0.stringValue })
        }

        // BitrateMax
        bitrateMax = indexer.intValue(forElement: Elements.BitrateMax)

        // BitrateAverage
        bitrateAverage = indexer.intValue(forElement: Elements.BitrateAverage)

        // VBR
        vbr = indexer.stringValue(forElement: Elements.VBR)

        // ActualLength
        if let string = indexer.stringValue(forElement: Elements.ActualLength) {
            actualLength = string.iso8601TimeInSeconds()
        }
    }

}

open class DigitalAsset {

    private struct Elements {
        static let Description = "Description"
        static let Language = "Language"
        static let TrackReference = "TrackReference"
        static let TrackIdentifier = "TrackIdentifier"
        static let Private = "Private"
        static let ContainerReference = "ContainerReference"
    }

    var description: String?
    var languages: [String]
    var trackReference: String?
    var trackIdentifiers: [ContentIdentifier]?
    var customData: XMLIndexer?
    var containerReference: ContainerReference?

    /// Computed values
    public var url: URL? {
        return containerReference?.url
    }

    init?(indexer: XMLIndexer) throws {
        // Description
        description = indexer.stringValue(forElement: Elements.Description)

        // Language
        if indexer.hasElement(Elements.Language) {
            languages = indexer[Elements.Language].flatMap({ $0.stringValue })
        } else {
            languages = ["en"]
        }

        // TrackReference
        trackReference = indexer.stringValue(forElement: Elements.TrackReference)

        // TrackIdentifier
        if indexer.hasElement(Elements.TrackIdentifier) {
            trackIdentifiers = try indexer[Elements.TrackIdentifier].map({ try ContentIdentifier(indexer: $0) })
        }

        // Private
        customData = indexer[Elements.Private]

        // ContainerReference
        if indexer.hasElement(Elements.ContainerReference) {
            containerReference = try ContainerReference(indexer: indexer[Elements.ContainerReference])
        }
    }

}
