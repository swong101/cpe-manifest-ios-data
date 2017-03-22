//
//  AppGroup.swift
//

import Foundation
import SWXMLHash

public class AppGroup {

    private struct Attributes {
        static let AppGroupID = "AppGroupID"
    }

    var id: String

    init(indexer: XMLIndexer) throws {
        // AppGroupID
        guard let id = indexer.stringValue(forAttribute: Attributes.AppGroupID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.AppGroupID, element: indexer.element)
        }

        self.id = id
    }

}
