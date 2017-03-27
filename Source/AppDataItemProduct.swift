//
//  AppDataItemProduct.swift
//

import Foundation
import SWXMLHash

open class AppDataItemProductCategory: ProductCategory {

    public var metadata: Metadata

    public var id: String {
        return metadata.id
    }

    public var name: String {
        return metadata.title
    }

    required public init(metadata: Metadata) {
        self.metadata = metadata
    }

}

open class AppDataItemProduct: AppDataItem, ProductItem {

    public var externalURL: URL?

    public var name: String {
        return (title ?? "")
    }

    public var brand: String? {
        return description
    }

    public lazy var category: AppDataItemProductCategory? = { [unowned self] in
        if let metadata = self.parentMetadata {
            return AppDataItemProductCategory(metadata: metadata)
        }

        return nil
    }()

    public var price: Double?
    public var currencyCode = "USD"
    public var displayPrice: String? {
        if let price = price {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            return formatter.string(from: NSNumber(value: price))
        }

        return nil
    }

    public var productImageURL: URL? {
        return thumbnailImageURL
    }

    public var sceneImagePictureID: String?
    public var sceneImageURL: URL? {
        return CPEXMLSuite.current?.manifest.pictureWithID(sceneImagePictureID)?.imageURL
    }

    public var isExactMatch = false
    public var hasExactMatchData = false
    public var bullseyePoint = CGPoint.zero
    public var shareText: String {
        var shareText = name
        if let externalURLString = externalURL?.absoluteString {
            shareText += " - " + externalURLString
        }

        return shareText
    }

    override init(indexer: XMLIndexer) throws {
        try super.init(indexer: indexer)

        var productImageBullseyeX: Double?
        var productImageBullseyeY: Double?
        var sceneImageBullseyeX: Double?
        var sceneImageBullseyeY: Double?

        for indexer in indexer[Elements.NVPair] {
            // Name
            guard let name = indexer.stringValue(forAttribute: Attributes.Name) else {
                throw ManifestError.missingRequiredAttribute(Attributes.Name, element: indexer.element)
            }

            switch name {
            case AppDataNVPairName.ExternalURL:
                // URL
                guard let externalURL = indexer.urlValue(forElement: Elements.URL) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.URL, element: indexer.element)
                }

                self.externalURL = externalURL
                break

            case AppDataNVPairName.Price:
                // Money
                guard let price = indexer.doubleValue(forElement: Elements.Money) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.Money, element: indexer.element)
                }

                self.price = price
                currencyCode = (indexer[Elements.Money].stringValue(forAttribute: Attributes.Currency) ?? "USD")
                break

            case AppDataNVPairName.ExactMatch:
                isExactMatch = indexer.boolValue(forElement: Elements.Text)
                hasExactMatchData = true
                break

            case AppDataNVPairName.SceneImage:
                sceneImagePictureID = indexer.stringValue(forElement: Elements.PictureID)
                break

            case AppDataNVPairName.ProductImageBullseyeX:
                productImageBullseyeX = indexer.doubleValue(forElement: Elements.Decimal)
                break

            case AppDataNVPairName.ProductImageBullseyeY:
                productImageBullseyeY = indexer.doubleValue(forElement: Elements.Decimal)
                break

            case AppDataNVPairName.SceneImageBullseyeX:
                sceneImageBullseyeX = indexer.doubleValue(forElement: Elements.Decimal)
                break

            case AppDataNVPairName.SceneImageBullseyeY:
                sceneImageBullseyeY = indexer.doubleValue(forElement: Elements.Decimal)
                break

            default:
                break
            }
        }

        if sceneImagePictureID != nil, let x = sceneImageBullseyeX, let y = sceneImageBullseyeY {
            bullseyePoint = CGPoint(x: x, y: y)
        } else if let x = productImageBullseyeX, let y = productImageBullseyeY {
            bullseyePoint = CGPoint(x: x, y: y)
        }
    }

}
