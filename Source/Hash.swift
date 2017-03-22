//
//  Hash.swift
//

import Foundation
import SWXMLHash

enum HashMethod: String {
    // Message Digest algorithms
    case md2 = "MD2"
    case md4 = "MD4"
    case md5 = "MD5"

    // Secure Hash Algorithm
    case sha0 = "SHA-0"
    case sha1 = "SHA-1"
    case sha2 = "SHA-2"
    case sha3 = "SHA-3"

    // Cyclic Redundancy Check
    case crc16 = "CRC16"
    case crc32 = "CRC32"
    case crc64 = "CRC64"
}

struct Hash {

    private struct Attributes {
        static let Method = "method"
    }

    var value: String
    var method: HashMethod

    init(indexer: XMLIndexer) throws {
        // value
        guard let value = indexer.stringValue else {
            throw ManifestError.missingRequiredValue(element: indexer.element)
        }

        self.value = value

        // Method
        guard let methodString = indexer.stringValue(forAttribute: Attributes.Method) else {
            throw ManifestError.missingRequiredAttribute(Attributes.Method, element: indexer.element)
        }

        guard let method = HashMethod(rawValue: methodString) else {
            throw ManifestError.unsupportedAttribute(Attributes.Method, value: methodString, element: indexer.element)
        }

        self.method = method
    }

}
