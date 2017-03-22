//
//  Theme.swift
//

import Foundation
import SWXMLHash

public struct ThemeButton {

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

    init(indexer: XMLIndexer) throws {
        // Label
        guard let label = indexer.stringValue(forAttribute: Attributes.Label) else {
            throw ManifestError.missingRequiredAttribute(Attributes.Label, element: indexer.element)
        }

        self.label = label

        // Default
        guard indexer.hasElement(Elements.Default) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Default, element: indexer.element)
        }

        let defaultIndexer = indexer[Elements.Default]

        // BaseImage
        guard let baseImageID = defaultIndexer.stringValue(forElement: Elements.BaseImage) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.BaseImage, element: indexer.element)
        }

        self.baseImageID = baseImageID

        // HighlightImage
        guard let highlightImageID = defaultIndexer.stringValue(forElement: Elements.HighlightImage) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.HighlightImage, element: indexer.element)
        }

        self.highlightImageID = highlightImageID

        // DefocusImage
        guard let defocusImageID = defaultIndexer.stringValue(forElement: Elements.DefocusImage) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.DefocusImage, element: indexer.element)
        }

        self.defocusImageID = defocusImageID
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
        guard let id = indexer.stringValue(forAttribute: Attributes.ThemeID) else {
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
                let button = try ThemeButton(indexer: indexer)
                buttons[button.label] = button
            }

            self.buttons = buttons
        }
    }

    open func baseImageForButton(_ label: String) -> Image? {
        return buttons?[label]?.baseImage
    }

}
