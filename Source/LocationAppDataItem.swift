//
//  LocationAppDataItem.swift
//

import Foundation
import SWXMLHash
import CoreLocation

open class LocationAppDataItem: AppDataItem {

    var location: Location!
    public var zoomLevel: Int = 0
    public var zoomLocked = false

    open var name: String? {
        return location.name
    }

    open var address: String? {
        return location.address
    }

    open var centerPoint: CLLocationCoordinate2D {
        return location.centerPoint
    }

    override open var thumbnailImageURL: URL? {
        return (super.thumbnailImageURL ?? mapImageURL)
    }

    open var mapImageURL: URL? {
        return location.mapImageURL(forZoomLevel: zoomLevel)
    }

    open var iconImage: UIImage? {
        return location.iconImage
    }

    open var iconImageID: String? {
        return location.iconImageID
    }

    override init(indexer: XMLIndexer) throws {
        try super.init(indexer: indexer)

        for indexer in indexer[Elements.NVPair] {
            // Name
            guard let name = indexer.stringValue(forAttribute: Attributes.Name) else {
                throw ManifestError.missingRequiredAttribute(Attributes.Name, element: indexer.element)
            }

            switch name {
            case AppDataNVPairName.Location:
                // LocationSet
                guard indexer.hasElement(Elements.LocationSet) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.LocationSet, element: indexer.element)
                }

                // Location
                guard indexer[Elements.LocationSet].hasElement(Elements.Location) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.Location, element: indexer[Elements.LocationSet].element)
                }

                location = try Location(indexer: indexer[Elements.LocationSet][Elements.Location])
                break

            case AppDataNVPairName.Zoom:
                guard let zoomLevel = indexer.intValue(forElement: Elements.Integer) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.Integer, element: indexer.element)
                }

                self.zoomLevel = zoomLevel
                break

            case AppDataNVPairName.ZoomLocked:
                self.zoomLocked = indexer.boolValue
                break

            default:
                break
            }
        }
    }

}
