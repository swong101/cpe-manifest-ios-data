//
//  AppDataSet.swift
//

import Foundation
import SWXMLHash

open class AppDataSet {

    private struct Attributes {
        static let Name = "Name"
    }

    private struct Elements {
        static let ManifestAppData = "ManifestAppData"
        static let NVPair = "NVPair"
        static let Text = "Text"
    }

    // Inventory
    open var locations: [String: LocationAppDataItem]?
    open var products: [String: ProductAppDataItem]?
    open var imageCache: [String: UIImage]?

    init(indexer: XMLIndexer) throws {
        // ManifestAppData
        guard indexer.hasElement(Elements.ManifestAppData) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.ManifestAppData, element: indexer.element)
        }

        for indexer in indexer[Elements.ManifestAppData] {
            if try indexer[Elements.NVPair].withAttr(Attributes.Name, "type").stringValue(forElement: Elements.Text) == "PRODUCT" {
                if products == nil {
                    products = [String: ProductAppDataItem]()
                }

                let product = try ProductAppDataItem(indexer: indexer)
                products![product.id] = product
            } else {
                if locations == nil {
                    locations = [String: LocationAppDataItem]()
                }

                let location = try LocationAppDataItem(indexer: indexer)
                locations![location.id] = location
            }
        }
    }

    open func postProcess() {
        if let locations = locations {
            for location in Array(locations.values) {
                if let imageID = location.iconImageID, let url = CPEXMLSuite.current?.manifest.imageWithID(imageID)?.url {
                    _ = UIImageRemoteLoader.loadImage(url, completion: { (image) in
                        CPEXMLSuite.current?.appData?.imageCache?[imageID] = image
                    })
                }
            }
        }
    }

    open func cachedImageWithID(_ id: String?) -> UIImage? {
        return (id != nil ? imageCache?[id!] : nil)
    }

    open func locationWithID(_ id: String?) -> LocationAppDataItem? {
        return (id != nil ? locations?[id!] : nil)
    }

    open func productWithID(_ id: String?) -> ProductAppDataItem? {
        return (id != nil ? products?[id!] : nil)
    }

}
