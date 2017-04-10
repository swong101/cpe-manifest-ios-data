//
//  ProductAPIUtil.swift
//

import Foundation

public protocol ProductAPIUtil {

    static var APIDomain: String { get }
    static var APINamespace: String { get }

    var featureAPIID: String? { get set }
    var productCategories: [ProductCategory]? { get set }

    func getProductFrameTimes(completion: @escaping (_ frameTimes: [Double]?) -> Void) -> URLSessionDataTask?
    func getProductCategories(completion: ((_ productCategories: [ProductCategory]?) -> Void)?) -> URLSessionDataTask?
    func getFrameProducts(_ frameTime: Double, completion: @escaping (_ products: [ProductItem]?) -> Void) -> URLSessionDataTask?
    func getCategoryProducts(_ categoryID: String?, completion: @escaping (_ products: [ProductItem]?) -> Void) -> URLSessionDataTask?
    func getProductDetails(_ productID: String, completion: @escaping (_ product: ProductItem?) -> Void) -> URLSessionDataTask

    func closestFrameTime(_ timeInSeconds: Double) -> Double

}
