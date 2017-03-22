//
//  ProductItem.swift
//

import Foundation

@objc public protocol ProductItem {

    var externalID: String { get }
    var externalURL: URL? { get }
    var name: String { get }
    var brand: String? { get }
    @objc optional var category: ProductCategory? { get }
    var displayPrice: String? { get }
    var productImageURL: URL? { get }
    var sceneImageURL: URL? { get }
    var isExactMatch: Bool { get }
    var hasExactMatchData: Bool { get }
    var bullseyePoint: CGPoint { get }
    var shareText: String { get }

}
