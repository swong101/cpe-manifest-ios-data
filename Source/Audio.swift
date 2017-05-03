//
//  Audio.swift
//

import Foundation
import SWXMLHash

/**
    Supported audio track types
 
    - primary: Primary audio track
    - commentary: Audio track for film commentary
 */
public enum AudioType: String {
    case primary
    case commentary
}

/**
    Supported audio codecs
 
    - aac: Advanced audio CODEC
    - aacLC: Advanced audio CODEC
    - aacLCMPS: Advanced audio CODEC
    - aacSLS: Advanced audio CODEC
    - mp3: MPEG 1 Layer 3
    - wav: used when specific CODEC (e.g., PCM) is unknown or not listed
 */
public enum AudioCodec: String {
    case aac            = "AAC"
    case aacLC          = "AAC-LC"
    case aacLCMPS       = "AAC-LC+MPS"
    case aacSLS         = "AAC-SLS"
    case mp3            = "MP3"
    case wav            = "WAV"
}

/// Encoding details of an audio asset
open class AudioEncoding: DigitalAssetEncoding {

    /// Supported XML element tags
    private struct Elements {
        static let Codec = "Codec"
        static let SampleRate = "SampleRate"
        static let SampleBitDepth = "SampleBitDepth"
        static let ChannelMapping = "ChannelMapping"
    }

    /// Codec used during encoding
    public var codec: AudioCodec

    /**
        Initializes a new audio encoding details wrapper with the provided XML indexer
     
        - Parameter indexer: The root XML node
        - Throws
     */
    override init?(indexer: XMLIndexer) throws {
        // Codec
        if let codecString: String = try indexer[Elements.Codec].value() {
            guard let codec = AudioCodec(rawValue: codecString) else {
                print("Ignoring unsupported Audio Encoding object with Codec \"\(codecString)\"")
                return nil
            }

            self.codec = codec
        } else {
            codec = .wav
        }

        // DigitalAssetEncoding
        try super.init(indexer: indexer)
    }

}

/// Playable audio asset
open class Audio: DigitalAsset {

    /// Supported XML attribute keys
    private struct Attributes {
        static let AudioTrackID = "AudioTrackID"
        static let Dubbed = "dubbed"
    }

    /// Supported XML element tags
    private struct Elements {
        static let AudioType = "Type"
        static let Encoding = "Encoding"
        static let Language = "Language"
        static let Channels = "Channels"
    }

    /// Unique identifier
    public var id: String

    /// Type of audio
    public var type: AudioType

    /// Audio encoding
    public var encoding: AudioEncoding?

    /// Flag for if this audio is a commentary type
    open var isCommentary: Bool {
        return isType(.commentary)
    }

    /**
        Initializes a new audio asset with the provided XML indexer
     
        - Parameter indexer: The root XML node
        - Throws:
            - `ManifestError.missingRequiredAttribute` if an expected XML attribute is not present
            - `ManiefstError.missingRequiredChildElement` if an expected XML element is not present
     */
    override init?(indexer: XMLIndexer) throws {
        // AudioTrackID
        guard let id: String = indexer.value(ofAttribute: Attributes.AudioTrackID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.AudioTrackID, element: indexer.element)
        }

        self.id = id

        // Type
        if let typeString: String = try indexer[Elements.AudioType].value() {
            guard let type = AudioType(rawValue: typeString) else {
                print("Ignoring unsupported Audio object with Type \"\(typeString)\"")
                return nil
            }

            self.type = type
        } else {
            type = .primary
        }

        // Encoding
        if indexer.hasElement(Elements.Encoding) {
            encoding = try AudioEncoding(indexer: indexer[Elements.Encoding])
        }

        // DigitalAsset
        try super.init(indexer: indexer)
    }

    /**
        Check if `Audio` is of the specified type
     
        - Parameters:
            - type: Type of `Audio`
     
        - Returns: `true` if the `Audio` is of the specified type
     */
    open func isType(_ type: AudioType) -> Bool {
        return (type == self.type)
    }

}
