//
//  XMLIndexerUtils.swift
//

import Foundation
import SWXMLHash

extension XMLIndexer {

    var stringValue: String? {
        return self.element?.text
    }

    var urlValue: URL? {
        if let string = stringValue {
            return URL(string: string)
        }

        return nil
    }

    var intValue: Int? {
        if let string = stringValue {
            return Int(string)
        }

        return nil
    }

    var uintValue: UInt? {
        if let string = stringValue {
            return UInt(string)
        }

        return nil
    }

    var doubleValue: Double? {
        if let string = stringValue {
            return Double(string)
        }

        return nil
    }

    var floatValue: Float? {
        if let string = stringValue {
            return Float(string)
        }

        return nil
    }

    var boolValue: Bool {
        if let stringValue = stringValue {
            return (stringValue.lowercased() == "true" || stringValue.uppercased() == "Y")
        }

        return false
    }

    var hasChildren: Bool {
        return (self.all.count > 0)
    }

    func hasElement(_ element: String) -> Bool {
        return self[element].hasChildren
    }

    func stringValue(forElement element: String) -> String? {
        return self[element].stringValue
    }

    func urlValue(forElement element: String) -> URL? {
        return self[element].urlValue
    }

    func intValue(forElement element: String) -> Int? {
        return self[element].intValue
    }

    func uintValue(forElement element: String) -> UInt? {
        return self[element].uintValue
    }

    func doubleValue(forElement element: String) -> Double? {
        return self[element].doubleValue
    }

    func floatValue(forElement element: String) -> Float? {
        return self[element].floatValue
    }

    func boolValue(forElement element: String) -> Bool {
        return self[element].boolValue
    }

    func stringValue(forAttribute attribute: String) -> String? {
        return element?.attribute(by: attribute)?.text
    }

    func intValue(forAttribute attribute: String) -> Int? {
        if let string = stringValue(forAttribute: attribute) {
            return Int(string)
        }

        return nil
    }

    func boolValue(forAttribute attribute: String) -> Bool {
        if let stringValue = stringValue(forAttribute: attribute) {
            return (stringValue.lowercased() == "true" || stringValue.uppercased() == "Y")
        }

        return false
    }

}
