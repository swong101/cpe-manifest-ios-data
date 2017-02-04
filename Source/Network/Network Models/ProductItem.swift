//
//  ProductItem.swift
//

import Foundation

@objc public protocol ProductItem {
    
    var id: String { get set }
    var name: String { get set }
    var brand: String? { get set }
    var price: String? { get set }
    var productImageURL: URL? { get set }
    var sceneImageURL: URL? { get set }
    var exactMatch: Bool { get set }
    var externalURL: URL? { get set }
    var bullseyePoint: CGPoint { get set }
    var shareText: String { get }
    
}
