//
//  TalentAPIUtil.swift
//

import Foundation

public protocol TalentAPIUtil {

    static var APIDomain: String { get }
    static var APINamespace: String { get }

    var featureAPIID: String? { get set }

    func prefetchCredits(_ completion: @escaping (_ people: [Person]?) -> Void)
    func getTalentImages(_ id: String, completion: @escaping (_ talentImages: [TalentImage]?) -> Void)
    func getTalentDetails(_ id: String, completion: @escaping (_ biography: String?, _ socialAccounts: [SocialAccount]?, _ films: [Film]) -> Void)

}
