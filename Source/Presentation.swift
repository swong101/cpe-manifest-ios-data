//
//  Presentation.swift
//

import Foundation
import SWXMLHash

open class Presentation {

    private struct Attributes {
        static let PresentationID = "PresentationID"
    }

    private struct Elements {
        static let TrackMetadata = "TrackMetadata"
        static let VideoTrackReference = "VideoTrackReference"
        static let VideoTrackID = "VideoTrackID"
        static let AudioTrackReference = "AudioTrackReference"
        static let AudioTrackID = "AudioTrackID"
    }

    var id: String
    var videoIDs: [String]?
    var audioIDs: [String]?

    // Computed values
    open var audio: Audio? {
        return CPEXMLSuite.current?.manifest.audioWithID(audioIDs?.first)
    }

    open var audioURL: URL? {
        return audio?.url
    }

    open var video: Video? {
        return CPEXMLSuite.current?.manifest.videoWithID(videoIDs?.first)
    }

    open var videoURL: URL? {
        return video?.url
    }

    init(indexer: XMLIndexer) throws {
        // PresentationID
        guard let id = indexer.stringValue(forAttribute: Attributes.PresentationID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.PresentationID, element: indexer.element)
        }

        self.id = id

        // TrackMetadata
        guard indexer.hasElement(Elements.TrackMetadata) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.TrackMetadata, element: indexer.element)
        }

        // VideoTrackReference
        videoIDs = indexer[Elements.TrackMetadata][Elements.VideoTrackReference].flatMap({ $0.stringValue(forElement: Elements.VideoTrackID) })

        // AudioTrackReference
        audioIDs = indexer[Elements.TrackMetadata][Elements.AudioTrackReference].flatMap({ $0.stringValue(forElement: Elements.AudioTrackID) })
    }

}
