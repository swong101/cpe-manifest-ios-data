//
//  Theme.swift
//

import Foundation
import SWXMLHash

public struct ThemeButton: XMLIndexerDeserializable {

    private struct Attributes {
        static let Label = "label"
    }

    private struct Elements {
        static let Default = "Default"
        static let BaseImage = "BaseImage"
        static let HighlightImage = "HighlightImage"
        static let DefocusImage = "DefocusImage"
    }

    var label: String
    var baseImageID: String
    var highlightImageID: String
    var defocusImageID: String

    var baseImage: Image? {
        return CPEXMLSuite.current?.manifest.imageWithID(baseImageID)
    }

    var highlightImage: Image? {
        return CPEXMLSuite.current?.manifest.imageWithID(highlightImageID)
    }

    var defocusImage: Image? {
        return CPEXMLSuite.current?.manifest.imageWithID(defocusImageID)
    }
    
    public static func deserialize(_ node: XMLIndexer) throws -> ThemeButton {
        return try ThemeButton(
            label: node.value(ofAttribute: Attributes.Label),
            baseImageID: node[Elements.Default][Elements.BaseImage].value(),
            highlightImageID: node[Elements.Default][Elements.HighlightImage].value(),
            defocusImageID: node[Elements.Default][Elements.DefocusImage].value()
        )
    }

}

open class Theme {

    private struct Attributes {
        static let ThemeID = "ThemeID"
    }

    private struct Elements {
        static let ButtonImageSet = "ButtonImageSet"
        static let Button = "Button"
    }

    var id: String
    private var buttons: [String: ThemeButton]? // Label: ThemeButton

    init(indexer: XMLIndexer) throws {
        // ThemeID
        guard let id: String = indexer.value(ofAttribute: Attributes.ThemeID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.ThemeID, element: indexer.element)
        }

        self.id = id

        // ButtonImageSet
        if indexer.hasElement(Elements.ButtonImageSet) {
            // Button
            guard indexer[Elements.ButtonImageSet].hasElement(Elements.Button) else {
                throw ManifestError.missingRequiredChildElement(name: Elements.Button, element: indexer[Elements.ButtonImageSet].element)
            }

            var buttons = [String: ThemeButton]()
            for indexer in indexer[Elements.ButtonImageSet][Elements.Button] {
                let button: ThemeButton = try indexer.value()
                buttons[button.label] = button
            }

            self.buttons = buttons
        }
    }

    open func baseImageForButton(_ label: String) -> Image? {
        return buttons?[label]?.baseImage
    }

    open func baseImageURLForButton(_ label: String) -> URL? {
        return baseImageForButton(label)?.url
    }

}
