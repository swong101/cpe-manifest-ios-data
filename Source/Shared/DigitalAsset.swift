//
//  DigitalAsset.swift
//

import Foundation
import SWXMLHash

/// Encoding details of a digital asset
open class DigitalAssetEncoding {

    /// Supported XML element tags
    private struct Elements {
        static let CodecType = "CodecType"
        static let BitrateMax = "BitrateMax"
        static let BitrateAverage = "BitrateAverage"
        static let VBR = "VBR"
        static let ActualLength = "ActualLength"
    }

    /// Formal reference identification of codec
    public var codecTypes: [String]?

    /// Peak Bitrate (bits/second) averaged over a short period
    public var bitrateMax: Int?

    /// Bitrate averaged over the entire track
    public var bitrateAverage: Int?

    /// Variable BitRate information
    public var vbr: String?

    /// The actual encoded length of the track (in ISO 8601 format)
    public var actualLength: TimeInterval = 0

    /**
        Initializes a new digital asset encoding details wrapper with the provided XML indexer
     
        - Parameter indexer: The root XML node
        - Throws: `ManiefstError.missingRequiredChildElement` if an expected XML element is not present
     */
    public init?(indexer: XMLIndexer) throws {
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

/// Playable digital asset
open class DigitalAsset {

    /// Supported XML element tags
    private struct Elements {
        static let Description = "Description"
        static let Language = "Language"
        static let TrackReference = "TrackReference"
        static let TrackIdentifier = "TrackIdentifier"
        static let Private = "Private"
        static let ContainerReference = "ContainerReference"
    }

    /// Text description of the digital asset
    public var description: String?

    /// Language of text visible in the video
    public var languages: [String]

    /// Track cross-reference to be used in conjunction with container-specific metadata
    public var trackReference: String?

    /// Identifiers, such as EIDR, for this track
    public var trackIdentifiers: [ContentIdentifier]?

    /// Reference to Container with file name
    public var containerReference: ContainerReference?

    /// The remote digital asset's file location
    open var url: URL? {
        return containerReference?.url
    }

    /**
        Initializes a new digital asset with the provided XML indexer
     
        - Parameter indexer: The root XML node
        - Throws: `ManiefstError.missingRequiredChildElement` if an expected XML element is not present
     */
    public init?(indexer: XMLIndexer) throws {
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

        // ContainerReference
        if indexer.hasElement(Elements.ContainerReference) {
            containerReference = try ContainerReference(indexer: indexer[Elements.ContainerReference])
        }
    }

}
