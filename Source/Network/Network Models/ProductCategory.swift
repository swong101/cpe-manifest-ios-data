//
//  ProductCategory.swift
//

import Foundation

@objc public protocol ProductCategory {
    
    var id: Int { get set }
    var name: String { get set }
    var childCategories: [ProductCategory]? { get set }
    
}
