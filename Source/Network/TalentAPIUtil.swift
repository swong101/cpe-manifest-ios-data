//
//  TalentAPIUtil.swift
//

import Foundation

public protocol TalentAPIUtil {
    
    static var APIDomain: String { get }
    static var APINamespace: String { get }
    
    var featureAPIID: String? { get set }
    
    func prefetchCredits(_ completion: @escaping (_ talents: [String: NGDMTalent]?) -> Void)
    func getTalentImages(_ talentID: String, completion: @escaping (_ talentImages: [TalentImage]?) -> Void)
    func getTalentDetails(_ talentID: String, completion: @escaping (_ biography: String?, _ socialAccounts: [TalentSocialAccount]?, _ films: [TalentFilm]) -> Void)
    
}
