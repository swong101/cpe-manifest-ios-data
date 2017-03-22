//
//  Video.swift
//

import Foundation
import SWXMLHash

public enum VideoType: String {
    case primary                // primary video track
}

private enum VideoCodec: String {
    case h264       = "H.264"   // H.264, MPEG-4 Part 10
}

private class VideoEncoding: DigitalAssetEncoding {

    private struct Elements {
        static let Codec = "Codec"
    }

    var codec: VideoCodec

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

open class Video: DigitalAsset, Trackable {

    private struct Attributes {
        static let VideoTrackID = "VideoTrackID"
    }

    private struct Elements {
        static let VideoType = "Type"
        static let Encoding = "Encoding"
        static let Picture = "Picture"
        static let WidthPixels = "WidthPixels"
        static let HeightPixels = "HeightPixels"
    }

    var id: String
    var type: VideoType
    private var encoding: VideoEncoding?
    public var size: CGSize?

    // Computed values
    open var runtimeInSeconds: TimeInterval {
        return (encoding?.actualLength ?? 0)
    }

    // Trackable
    public var analyticsID: String {
        return id
    }

    override init?(indexer: XMLIndexer) throws {
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
