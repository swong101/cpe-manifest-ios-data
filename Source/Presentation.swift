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

    open lazy var audio: Audio? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.audioWithID(self.audioIDs?.first)
    }()

    open var audioURL: URL? {
        return audio?.url
    }

    open lazy var video: Video? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.videoWithID(self.videoIDs?.first)
    }()

    open var videoURL: URL? {
        return video?.url
    }

    init(indexer: XMLIndexer) throws {
        // PresentationID
        guard let id: String = indexer.value(ofAttribute: Attributes.PresentationID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.PresentationID, element: indexer.element)
        }

        self.id = id

        // TrackMetadata
        guard indexer.hasElement(Elements.TrackMetadata) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.TrackMetadata, element: indexer.element)
        }

        // VideoTrackReference
        videoIDs = try indexer[Elements.TrackMetadata][Elements.VideoTrackReference].flatMap({ try $0[Elements.VideoTrackID].value() })

        // AudioTrackReference
        audioIDs = try indexer[Elements.TrackMetadata][Elements.AudioTrackReference].flatMap({ try $0[Elements.AudioTrackID].value() })
    }

}
