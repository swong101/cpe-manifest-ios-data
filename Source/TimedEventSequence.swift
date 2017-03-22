//
//  TimedEventSequence.swift
//

import Foundation
import SWXMLHash

open class TimedEventSequence {

    private struct Attributes {
        static let TimedSequenceID = "TimedSequenceID"
    }

    private struct Elements {
        static let PresentationID = "PresentationID"
        static let PlayableSequenceID = "PlayableSequenceID"
        static let TimedEvent = "TimedEvent"
    }

    var id: String
    var presentationID: String?
    var playableSequenceID: String?
    var timedEvents: [TimedEvent]

    init(indexer: XMLIndexer) throws {
        // TimedSequenceID
        guard let id = indexer.stringValue(forAttribute: Attributes.TimedSequenceID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.TimedSequenceID, element: indexer.element)
        }

        self.id = id

        // PresentationID / PlayableSequenceID
        if indexer.hasElement(Elements.PresentationID) {
            presentationID = indexer.stringValue(forElement: Elements.PresentationID)
        } else if indexer.hasElement(Elements.PlayableSequenceID) {
            playableSequenceID = indexer.stringValue(forElement: Elements.PlayableSequenceID)
        } else {
            throw ManifestError.missingRequiredChildElement(name: "\(Elements.PresentationID) or \(Elements.PlayableSequenceID)", element: indexer.element)
        }

        // TimedEvent
        guard indexer.hasElement(Elements.TimedEvent) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.TimedEvent, element: indexer.element)
        }

        timedEvents = try indexer[Elements.TimedEvent].flatMap({ try TimedEvent(indexer: $0) })
    }

}
