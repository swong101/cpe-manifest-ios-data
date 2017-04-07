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

    open var appGroup: AppGroup? {
        return CPEXMLSuite.current?.manifest.appGroupWithID(appGroupID)
    }

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
        appID = indexer.value(ofAttribute: Attributes.AppID)

        // AppGroupID
        guard let appGroupID: String = try indexer[Elements.AppGroupID].value() else {
            throw ManifestError.missingRequiredChildElement(name: Elements.AppGroupID, element: indexer.element)
        }

        self.appGroupID = appGroupID

        // AppName
        names = try indexer[Elements.AppName].value()

        // MetadataDriven
        try super.init(indexer: indexer)
    }

}
