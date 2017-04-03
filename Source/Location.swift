//
//  Location.swift
//

import Foundation
import SWXMLHash
import CoreLocation

open class Location {

    private struct Attributes {
        static let Icon = "icon"
    }

    private struct Elements {
        static let Name = "Name"
        static let Address = "Address"
        static let EarthCoordinate = "EarthCoordinate"
        static let Latitude = "Latitude"
        static let Longitude = "Longitude"
    }

    public var name: String?
    public var address: String?
    public var latitude: Double = 0
    public var longitude: Double = 0
    public var centerPoint: CLLocationCoordinate2D

    var iconImageID: String?
    open lazy var iconImage: UIImage? = { [unowned self] in
        return CPEXMLSuite.current?.appData?.cachedImageWithID(self.iconImageID)
    }()

    init(indexer: XMLIndexer) throws {
        // Icon
        iconImageID = indexer.value(ofAttribute: Attributes.Icon)

        // Name
        name = try indexer[Elements.Name].value()

        // Address
        address = try indexer[Elements.Address].value()

        // EarthCoordinate
        if indexer.hasElement(Elements.EarthCoordinate) {
            let coordinateIndexer = indexer[Elements.EarthCoordinate]
            latitude = (try coordinateIndexer[Elements.Latitude].value() ?? 0)
            longitude = (try coordinateIndexer[Elements.Longitude].value() ?? 0)
        }

        // Custom
        centerPoint = CLLocationCoordinate2DMake(latitude, longitude)
    }

    open func mapImageURL(forZoomLevel zoomLevel: Int? = nil) -> URL? {
        if CPEXMLSuite.Settings.mapsAPIService == .googleMaps, let key = CPEXMLSuite.Settings.mapsAPIKey {
            var urlString = "http://maps.googleapis.com/maps/api/staticmap?"
            urlString += "center=\(latitude),\(longitude)"

            if let zoomLevel = zoomLevel {
                let zoomString = String(max(zoomLevel - 4, 1))
                urlString += "&zoom=\(zoomString)"
            }

            urlString += "&scale=2&size=480x270&maptype=roadmap&format=png&visual_refresh=true"
            urlString += "&key=\(key)"
            return URL(string: urlString)
        }

        return nil
    }

}
