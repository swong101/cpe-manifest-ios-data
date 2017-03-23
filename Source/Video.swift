//
//  Video.swift
//

import Foundation
import SWXMLHash

/**
    Supported video track types
 
    - primary: Primary video track
 */
public enum VideoType: String {
    case primary
}

/**
    Supported video track codecs
 
    - h264: H.264, MPEG-4 Part 10
 */
public enum VideoCodec: String {
    case h264 = "H.264"
}

/// Encoding details of a video asset
open class VideoEncoding: DigitalAssetEncoding {

    /// Supported XML element tags
    private struct Elements {
        static let Codec = "Codec"
    }

    /// Codec used during encoding
    public var codec: VideoCodec

    /**
        Initializes a new video encoding details wrapper with the provided XML indexer
     
        - Parameter indexer: The root XML node
        - Throws: `ManiefstError.missingRequiredChildElement` if an expected XML element is not present
    */
    override init?(indexer: XMLIndexer) throws {
        // Codec
        guard let codecString = indexer.stringValue(forElement: Elements.Codec) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Codec, element: indexer.element)
        }

        guard let codec = VideoCodec(rawValue: codecString) else {
            print("Ignoring unsupported Video Encoding object with Codec \"\(codecString)\"")
            return nil
        }

        self.codec = codec

        // DigitalAssetEncoding
        try super.init(indexer: indexer)
    }

}

/// Playable video asset
open class Video: DigitalAsset, Trackable {

    /// Supported XML attribute keys
    private struct Attributes {
        static let VideoTrackID = "VideoTrackID"
    }

    /// Supported XML element tags
    private struct Elements {
        static let VideoType = "Type"
        static let Encoding = "Encoding"
        static let Picture = "Picture"
        static let WidthPixels = "WidthPixels"
        static let HeightPixels = "HeightPixels"
    }

    /// Unique identifier
    public var id: String
    
    /// Type of video
    public var type: VideoType
    
    /// Details of the video's encoding process
    public var encoding: VideoEncoding?
    
    /// Size of the video
    public var size: CGSize?

    /// Runtime (in seconds) of the video
    open var runtimeInSeconds: TimeInterval {
        return (encoding?.actualLength ?? 0)
    }

    /// Tracking identifier
    open var analyticsID: String {
        return id
    }
    
    /**
        Initializes a new video asset with the provided XML indexer
     
        - Parameter indexer: The root XML node
        - Throws:
            - `ManifestError.missingRequiredAttribute` if an expected XML attribute is not present
            - `ManiefstError.missingRequiredChildElement` if an expected XML element is not present
     */
    override public init?(indexer: XMLIndexer) throws {
        // AudioTrackID
        guard let id = indexer.stringValue(forAttribute: Attributes.VideoTrackID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.VideoTrackID, element: indexer.element)
        }

        self.id = id

        // Type
        if let string = indexer.stringValue(forElement: Elements.VideoType) {
            guard let type = VideoType(rawValue: string) else {
                print("Ignoring unsupported Video object with Type \"\(string)\"")
                return nil
            }

            self.type = type
        } else {
            type = .primary
        }

        if indexer.hasElement(Elements.Encoding) {
            encoding = try VideoEncoding(indexer: indexer[Elements.Encoding])
        }

        // Picture
        if indexer.hasElement(Elements.Picture) {
            if let width = indexer[Elements.Picture].intValue(forElement: Elements.WidthPixels), let height = indexer[Elements.Picture].intValue(forElement: Elements.HeightPixels) {
                size = CGSize(width: width, height: height)
            }
        }

        // DigitalAsset
        try super.init(indexer: indexer)
    }

}
