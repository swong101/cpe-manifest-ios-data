//
//  CPEStyleSet.swift
//

import Foundation
import SWXMLHash

public enum DeviceTargetClass: String {
    case computer = "Computer"
    case tv = "TV"
    case mobile = "Mobile"
}

public enum DeviceTargetSubClass: String {
    case tablet = "Tablet"
    case phone = "Phone"
}

open class CPEStyleSet {

    private struct Attributes {
        static let NodeStyleID = "NodeStyleID"
    }

    private struct Elements {
        static let ExperienceStyleMap = "ExperienceStyleMap"
        static let ExperienceID = "ExperienceID"
        static let NodeStyleRef = "NodeStyleRef"
        static let Orientation = "Orientation"
        static let DeviceTarget = "DeviceTarget"
        static let Class = "Class"
        static let SubClass = "SubClass"
        static let NodeStyle = "NodeStyle"
        static let Theme = "Theme"
    }

    // Inventory
    open var experienceToNodeStyleMapping: [String: [String]] // ExperienceID: [NodeStyleID]
    open var nodeStyles: [String: NodeStyle]
    open var themes: [String: Theme]

    init(indexer: XMLIndexer) throws {
        // ExperienceStyleMap
        guard indexer.hasElement(Elements.ExperienceStyleMap) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.ExperienceStyleMap, element: indexer.element)
        }

        experienceToNodeStyleMapping = [String: [String]]()

        // NodeStyle
        guard indexer.hasElement(Elements.NodeStyle) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.NodeStyle, element: indexer.element)
        }

        nodeStyles = [String: NodeStyle]()
        for indexer in indexer[Elements.NodeStyle] {
            let nodeStyle = try NodeStyle(indexer: indexer)
            nodeStyles[nodeStyle.id] = nodeStyle
        }

        // Theme
        guard indexer.hasElement(Elements.Theme) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Theme, element: indexer.element)
        }

        themes = [String: Theme]()
        for indexer in indexer[Elements.Theme] {
            let theme = try Theme(indexer: indexer)
            themes[theme.id] = theme
        }

        // ExperienceStyleMap (continued)
        for indexer in indexer[Elements.ExperienceStyleMap] {
            // ExperienceID
            guard let experienceID = indexer.stringValue(forElement: Elements.ExperienceID) else {
                throw ManifestError.missingRequiredChildElement(name: Elements.ExperienceID, element: indexer.element)
            }

            // NodeStyleRef
            guard indexer.hasElement(Elements.NodeStyleRef) else {
                throw ManifestError.missingRequiredChildElement(name: Elements.NodeStyleRef, element: indexer.element)
            }

            for nodeStyleRefIndexer in indexer[Elements.NodeStyleRef] {
                // NodeStyleID
                guard let nodeStyleID = nodeStyleRefIndexer.stringValue(forAttribute: Attributes.NodeStyleID), let nodeStyle = nodeStyles[nodeStyleID] else {
                    throw ManifestError.missingRequiredAttribute(Attributes.NodeStyleID, element: nodeStyleRefIndexer.element)
                }

                if let orientation = nodeStyleRefIndexer.stringValue(forElement: Elements.Orientation) {
                    nodeStyle.supportsLandscape = nodeStyle.supportsLandscape || (orientation == "Landscape")
                    nodeStyle.supportsPortrait = nodeStyle.supportsPortrait || (orientation == "Portrait")
                } else {
                    nodeStyle.supportsLandscape = true
                    nodeStyle.supportsPortrait = true
                }

                // DeviceTarget
                if nodeStyleRefIndexer.hasElement(Elements.DeviceTarget) {
                    for deviceIndexer in nodeStyleRefIndexer[Elements.DeviceTarget] {
                        // Class
                        guard let deviceTargetClassString = deviceIndexer.stringValue(forElement: Elements.Class) else {
                            throw ManifestError.missingRequiredChildElement(name: Elements.Class, element: deviceIndexer.element)
                        }

                        if DeviceTargetClass(rawValue: deviceTargetClassString) == .mobile {
                            // SubClass
                            guard let deviceTargetSubClassString = deviceIndexer.stringValue(forElement: Elements.SubClass) else {
                                throw ManifestError.missingRequiredChildElement(name: Elements.SubClass, element: deviceIndexer.element)
                            }

                            let deviceTargetSubClass = DeviceTargetSubClass(rawValue: deviceTargetSubClassString)
                            nodeStyle.supportsTablet = nodeStyle.supportsTablet || (deviceTargetSubClass == .tablet)
                            nodeStyle.supportsPhone = nodeStyle.supportsPhone || (deviceTargetSubClass == .phone)
                        }
                    }
                } else {
                    nodeStyle.supportsTablet = true
                    nodeStyle.supportsPhone = true
                }

                if experienceToNodeStyleMapping[experienceID] == nil {
                    experienceToNodeStyleMapping[experienceID] = [String]()
                }

                experienceToNodeStyleMapping[experienceID]!.append(nodeStyleID)
            }
        }
    }

    open func nodeStylesForExperienceID(_ id: String?) -> [NodeStyle]? {
        if let id = id, let nodeStyleIDs = experienceToNodeStyleMapping[id] {
            return nodeStyleIDs.flatMap({ nodeStyleWithID($0) })
        }

        return nil
    }

    open func nodeStyleWithID(_ id: String?) -> NodeStyle? {
        return (id != nil ? nodeStyles[id!] : nil)
    }

    open func themeWithID(_ id: String?) -> Theme? {
        return (id != nil ? themes[id!] : nil)
    }

}
