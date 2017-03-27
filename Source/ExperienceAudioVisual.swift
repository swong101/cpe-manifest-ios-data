//
//  ExperienceAudioVisual.swift
//

import Foundation
import SWXMLHash

public enum ExperienceAudioVisualType: String {
    case main = "Main" // Main title (typically the feature)
    case promotion = "Promotion" // Trailers, teasers, etc.
    case bonus = "Bonus" // Additional material related toward the Main Program, such as, deleted scenes, making-of, etc.
    case other = "Other" // Any other material included

    static func build(rawValue: String?) -> ExperienceAudioVisualType {
        if let rawValue = rawValue, let type = ExperienceAudioVisualType(rawValue: rawValue) {
            return type
        }

        return .other
    }
}

open class ExperienceAudioVisual: MetadataDriven {

    private struct Elements {
        static let AudioVisualType = "Type"
        static let SubType = "SubType"
        static let PresentationID = "PresentationID"
        static let PlayableSequenceID = "PlayableSequenceID"
    }

    var type: ExperienceAudioVisualType
    var subTypes: [String]?
    var presentationID: String?
    private var playableSequenceID: String?

    open lazy var presentation: Presentation? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.presentationWithID(self.presentationID)
    }()

    open lazy var playableSequence: PlayableSequence? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.playableSequenceWithID(self.playableSequenceID)
    }()

    open lazy var isClipShare: Bool = { [unowned self] in
        return (self.subTypes?.contains("Shareable Clip") ?? false)
    }()

    override init?(indexer: XMLIndexer) throws {
        // Type
        type = ExperienceAudioVisualType.build(rawValue: indexer.stringValue(forElement: Elements.AudioVisualType))

        // SubType
        if indexer.hasElement(Elements.SubType) {
            subTypes = indexer[Elements.SubType].flatMap({ $0.stringValue })
        }

        // PresentationID / PlayableSequenceID
        if indexer.hasElement(Elements.PresentationID) {
            presentationID = indexer.stringValue(forElement: Elements.PresentationID)
        } else if indexer.hasElement(Elements.PlayableSequenceID) {
            playableSequenceID = indexer.stringValue(forElement: Elements.PlayableSequenceID)
        }

        // MetadataDriven
        try super.init(indexer: indexer)
    }

}
