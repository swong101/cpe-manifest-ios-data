//
//  XMLIndexerUtils.swift
//

import Foundation
import SWXMLHash

extension XMLIndexer {

    func hasElement(_ element: String) -> Bool {
        return (self[element].all.count > 0)
    }

}
