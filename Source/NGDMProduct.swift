//
//  NGDMProduct.swift
//

import Foundation

open class NGDMProductCategory: ProductCategory {
    
    private var metadata: NGDMMetadata
    
    public var id: String {
        return metadata.id
    }
    
    public var name: String {
        return (metadata.title ?? "")
    }
    
    required public init(metadata: NGDMMetadata) {
        self.metadata = metadata
    }
    
}

public func ==(lhs: NGDMProductCategory, rhs: NGDMProductCategory) -> Bool {
    return (lhs.id == rhs.id)
}

// Wrapper class for `NGEAppDataType` Manifest object
open class NGDMProduct: NGDMAppData, ProductItem {
    
    // MARK: Instance Variables
    public var externalID: String {
        return id
    }
    
    public var externalURL: URL?
    
    public var name: String {
        return (title ?? "")
    }
    
    public var brand: String? {
        return description
    }
    
    private var _category: NGDMProductCategory?
    public var category: NGDMProductCategory? {
        if _category == nil, let metadata = parentMetadata {
            _category = NGDMProductCategory(metadata: metadata)
        }
        
        return _category
    }
    
    private var price: Double?
    private var currencyCode = "USD"
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
    
    public var sceneImageURL: URL?
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
    
    // MARK: Initialization
    /**
        Initializes a new NGETimedEventType
    
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    override init(manifestObject: NGEAppDataType) {
        super.init(manifestObject: manifestObject)
        
        var productImageBullseyeX: Double?
        var productImageBullseyeY: Double?
        var sceneImageBullseyeX: Double?
        var sceneImageBullseyeY: Double?
        
        for obj in manifestObject.NVPairList {
            if let name = obj.Name {
                switch name {
                case AppDataNVPairName.ExternalURL:
                    if let urlString = obj.URL {
                        externalURL = URL(string: urlString)
                    }
                    break
                    
                case AppDataNVPairName.Price:
                    if let moneyObj = obj.Money {
                        price = moneyObj.value
                        if let currencyCode = moneyObj.currency {
                            self.currencyCode = currencyCode
                        }
                    }
                    break
                    
                case AppDataNVPairName.ExactMatch:
                    if let exactMatchText = obj.Text?.uppercased() {
                        isExactMatch = (exactMatchText == "Y")
                        hasExactMatchData = true
                    }
                    break
                    
                case AppDataNVPairName.SceneImage:
                    if let id = obj.PictureID {
                        sceneImageURL = NGDMPicture.getById(id)?.imageURL
                    }
                    break
                    
                case AppDataNVPairName.ProductImageBullseyeX:
                    productImageBullseyeX = obj.Decimal
                    break
                    
                case AppDataNVPairName.ProductImageBullseyeY:
                    productImageBullseyeY = obj.Decimal
                    break
                    
                case AppDataNVPairName.SceneImageBullseyeX:
                    sceneImageBullseyeX = obj.Decimal
                    break
                
                case AppDataNVPairName.SceneImageBullseyeY:
                    sceneImageBullseyeY = obj.Decimal
                    break
                    
                default:
                    break
                }
            }
        }
        
        if sceneImageURL != nil, let x = sceneImageBullseyeX, let y = sceneImageBullseyeY {
            bullseyePoint = CGPoint(x: x, y: y)
        } else if let x = productImageBullseyeX, let y = productImageBullseyeY {
            bullseyePoint = CGPoint(x: x, y: y)
        }
        
        if let parentMetadata = parentMetadata {
            
        }
    }
    
}
