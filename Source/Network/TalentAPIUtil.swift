//
//  TalentAPIUtil.swift
//

import Foundation

public protocol TalentAPIUtil {

    static var APIDomain: String { get }
    static var APINamespace: String { get }

    var featureAPIID: String? { get set }

    func prefetchPeople(_ completionHandler: @escaping (_ people: [Person]?) -> Void)
    func fetchImages(forPersonID id: String, completionHandler: @escaping (_ pictureGroup: PictureGroup?) -> Void)
    func fetchDetails(forPersonID id: String, completionHandler: @escaping (_ biography: String?, _ socialAccounts: [SocialAccount]?, _ films: [Film]) -> Void)

}
