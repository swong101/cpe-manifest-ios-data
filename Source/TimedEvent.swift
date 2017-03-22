//
//  TimedEvent.swift
//

import Foundation
import SWXMLHash

public enum TimedEventType {
    case any
    case appGroup
    case gallery
    case video
    case location
    case product
    case person
    case textItem
}

public func == (lhs: TimedEvent, rhs: TimedEvent) -> Bool {
    return (lhs.id == rhs.id && lhs.startTime == rhs.startTime)
}

open class TimedEvent: Equatable {

    private struct Attributes {
        static let Index = "index"
    }

    private struct Elements {
        static let StartTimecode = "StartTimecode"
        static let EndTimecode = "EndTimecode"
        static let PresentationID = "PresentationID"
        static let PictureID = "PictureID"
        static let GalleryID = "GalleryID"
        static let AppGroupID = "AppGroupID"
        static let TextGroupID = "TextGroupID"
        static let ProductID = "ProductID"
        static let OtherID = "OtherID"
    }

    var id: String
    var startTime: Double
    var endTime: Double
    var presentationID: String?
    var pictureID: String?
    var galleryID: String?
    var appGroupID: String?
    var textGroupMappings: [(textGroupID: String, index: Int)]?
    var productID: ContentIdentifier?
    var otherID: ContentIdentifier?

    open var presentation: Presentation? {
        return CPEXMLSuite.current?.manifest.presentationWithID(presentationID)
    }

    open var picture: Picture? {
        return CPEXMLSuite.current?.manifest.pictureWithID(pictureID)
    }

    open var gallery: Gallery? {
        return CPEXMLSuite.current?.manifest.galleryWithID(galleryID)
    }

    open var appGroup: AppGroup? {
        return CPEXMLSuite.current?.manifest.appGroupWithID(appGroupID)
    }

    open var person: Person? {
        if let otherID = otherID, otherID.namespace == Namespaces.PeopleID {
            return CPEXMLSuite.current?.manifest.personWithID(otherID.identifier)
        }

        return nil
    }

    open var location: LocationAppDataItem? {
        if let otherID = otherID, otherID.namespace == Namespaces.AppDataID {
            return CPEXMLSuite.current?.appData?.locationWithID(otherID.identifier)
        }

        return nil
    }

    open var product: ProductAppDataItem? {
        if let otherID = otherID, otherID.namespace == Namespaces.AppDataID {
            return CPEXMLSuite.current?.appData?.productWithID(otherID.identifier)
        }

        return nil
    }

    open var textItem: String? {
        if let textGroupMapping = textGroupMappings?.first {
            return CPEXMLSuite.current?.manifest.textGroupWithID(textGroupMapping.textGroupID)?.textObject?.textItem(textGroupMapping.index)
        }

        return nil
    }

    init(indexer: XMLIndexer) throws {
        // Custom ID
        id = UUID().uuidString

        // StartTimecode
        guard let startTime = indexer.doubleValue(forElement: Elements.StartTimecode) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.StartTimecode, element: indexer.element)
        }

        self.startTime = startTime

        // EndTimecode
        guard let endTime = indexer.doubleValue(forElement: Elements.EndTimecode) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.EndTimecode, element: indexer.element)
        }

        self.endTime = endTime

        // PresentationID / PictureID / GalleryID / AppGroupID / TextGroupID / OtherID
        if indexer.hasElement(Elements.PresentationID) {
            presentationID = indexer.stringValue(forElement: Elements.PresentationID)
        } else if indexer.hasElement(Elements.PictureID) {
            pictureID = indexer.stringValue(forElement: Elements.PictureID)
        } else if indexer.hasElement(Elements.GalleryID) {
            galleryID = indexer.stringValue(forElement: Elements.GalleryID)
        } else if indexer.hasElement(Elements.AppGroupID) {
            appGroupID = indexer.stringValue(forElement: Elements.AppGroupID)
        } else if indexer.hasElement(Elements.TextGroupID) {
            var textGroupMappings = [(String, Int)]()
            for indexer in indexer[Elements.TextGroupID] {
                if let textGroupID = indexer.stringValue, let index = indexer.intValue(forAttribute: Attributes.Index) {
                    textGroupMappings.append((textGroupID, index))
                }
            }

            self.textGroupMappings = textGroupMappings
        } else if indexer.hasElement(Elements.ProductID) {
            productID = try ContentIdentifier(indexer: indexer[Elements.ProductID])
        } else if indexer.hasElement(Elements.OtherID) {
            otherID = try ContentIdentifier(indexer: indexer[Elements.OtherID])
        }
    }

    // MARK: Helper Methods
    /**
        Check if TimedEvent is of the specified type
 
        - Parameters:
            - type: Type of TimedEvent
 
        - Returns: `true` if the TimedEvent is of the specified type
    */
    open func isType(_ type: TimedEventType) -> Bool {
        switch type {
        case .appGroup:
            return (appGroup != nil)

        case .video:
            return (presentation != nil)

        case .gallery:
            return (gallery != nil)

        case .location:
            return (location != nil)

        case .product:
            if let productAPIUtil = NGDMConfiguration.productAPIUtil, let productNamespace = productID?.namespace {
                return (productNamespace == type(of: productAPIUtil).APINamespace)
            }

            return (product != nil)

        case .person:
            return (person != nil)

        case .textItem:
            return (textItem != nil)

        case .any:
            return true
        }
    }

}
