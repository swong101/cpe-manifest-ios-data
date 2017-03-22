//
//  ExperienceApp.swift
//

import Foundation
import SWXMLHash

open class ExperienceApp: MetadataDriven {

    private struct Attributes {
        static let AppID = "AppID"
    }

    private struct Elements {
        static let AppGroupID = "AppGroupID"
        static let AppName = "AppName"
    }

    var appID: String?
    var appGroupID: String
    var names: [String]?

    var id: String {
        return (appID ?? appGroupID)
    }

    override open var title: String? {
        return (names?.first ?? super.title)
    }

    override init?(indexer: XMLIndexer) throws {
        // AppID
        appID = indexer.stringValue(forAttribute: Attributes.AppID)

        // AppGroupID
        guard let appGroupID = indexer.stringValue(forElement: Elements.AppGroupID) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.AppGroupID, element: indexer.element)
        }

        self.appGroupID = appGroupID

        // AppName
        if indexer.hasElement(Elements.AppName) {
            names = indexer[Elements.AppName].flatMap({ $0.stringValue })
        }

        // MetadataDriven
        try super.init(indexer: indexer)
    }

}
