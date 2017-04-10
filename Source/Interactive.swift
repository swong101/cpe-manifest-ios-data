//
//  Interactive.swift
//

import Foundation
import SWXMLHash

private enum InteractiveType: String {
    case standaloneGame     = "standalone game" // Playable game that runs independently of audio or video
    case interactivity      = "interactivity"   // Ability to choose settings, value added material and other options outside of menus. For example, pop-ups.
    case other              = "other"

    static func build(rawValue: String) -> InteractiveType? {
        return (InteractiveType(rawValue: rawValue) ?? InteractiveType(rawValue: rawValue.lowercased()))
    }
}

private enum InteractiveRuntimeEnvironment: String {
    case html5              = "html5"   // W3C HTML5
    case html               = "html"    // W3C HTML5
    case iOS                = "ios"     // iOS
    case defaultEnvironment = "default" // Represents an application that can be played if nothing else can. This is typically an image
    case other              = "other"   // May be used when there is not a type convention

    static func build(rawValue: String) -> InteractiveRuntimeEnvironment? {
        return (InteractiveRuntimeEnvironment(rawValue: rawValue) ?? InteractiveRuntimeEnvironment(rawValue: rawValue.lowercased()))
    }
}

private class InteractiveEncoding: DigitalAssetEncoding {

    private struct Elements {
        static let RuntimeEnvironment = "RuntimeEnvironment"
    }

    var runtimeEnvironment: InteractiveRuntimeEnvironment

    override init?(indexer: XMLIndexer) throws {
        // RuntimeEnvironment
        guard let runtimeEnvironmentString: String = try indexer[Elements.RuntimeEnvironment].value() else {
            throw ManifestError.missingRequiredChildElement(name: Elements.RuntimeEnvironment, element: indexer.element)
        }

        guard let runtimeEnvironment = InteractiveRuntimeEnvironment.build(rawValue: runtimeEnvironmentString) else {
            print("Ignoring unsupported Interactive Encoding object with RuntimeEnvironment \"\(runtimeEnvironmentString)\"")
            return nil
        }

        self.runtimeEnvironment = runtimeEnvironment

        // DigitalAsset
        try super.init(indexer: indexer)
    }

}

open class Interactive: DigitalAsset {

    private struct Attributes {
        static let InteractiveTrackID = "InteractiveTrackID"
    }

    private struct Elements {
        static let InteractiveType = "Type"
        static let Encoding = "Encoding"
    }

    var id: String
    private var type: InteractiveType
    private var encodings: [InteractiveEncoding]

    override init?(indexer: XMLIndexer) throws {
        // InteractiveTrackID
        guard let id: String = indexer.value(ofAttribute: Attributes.InteractiveTrackID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.InteractiveTrackID, element: indexer.element)
        }

        self.id = id

        // Type
        guard let typeString: String = try indexer[Elements.InteractiveType].value() else {
            throw ManifestError.missingRequiredChildElement(name: Elements.InteractiveType, element: indexer.element)
        }

        guard let type = InteractiveType.build(rawValue: typeString) else {
            print("Ignoring unsupported Interactive object with Type \"\(typeString)\"")
            return nil
        }

        self.type = type

        // Encoding
        guard indexer.hasElement(Elements.Encoding) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Encoding, element: indexer.element)
        }

        encodings = try indexer[Elements.Encoding].flatMap({ try InteractiveEncoding(indexer: $0) })

        try super.init(indexer: indexer)
    }

}
