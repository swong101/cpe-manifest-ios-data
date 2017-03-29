//
//  ProductCategory.swift
//

import Foundation

@objc public protocol ProductCategory {

    var id: String { get }
    var name: String { get }
    @objc optional var childCategories: [ProductCategory]? { get }

}
