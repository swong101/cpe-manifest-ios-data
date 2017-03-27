//
//  ExperienceApp.swift
//

import Foundation
import SWXMLHash

open class ExperienceApp: MetadataDriven, Trackable {

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

    open lazy var appGroup: AppGroup? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.appGroupWithID(self.appGroupID)
    }()

    open var url: URL? {
        return appGroup?.url
    }

    open lazy var isProductApp: Bool = { [unowned self] in
        if let names = self.names, let productAPIUtil = CPEXMLSuite.Settings.productAPIUtil {
            return names.contains(type(of: productAPIUtil).APINamespace)
        }

        return false
    }()

    // Trackable
    open var analyticsID: String {
        return id
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
