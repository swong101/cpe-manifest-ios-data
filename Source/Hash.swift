//
//  Hash.swift
//

import Foundation
import SWXMLHash

public enum HashMethod: String {
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

public struct Hash {

    private struct Attributes {
        static let Method = "method"
    }

    public var value: String
    public var method: HashMethod

    public init(indexer: XMLIndexer) throws {
        // value
        guard let value: String = try indexer.value() else {
            throw ManifestError.missingRequiredValue(element: indexer.element)
        }

        self.value = value

        // Method
        guard let methodString: String = indexer.value(ofAttribute: Attributes.Method) else {
            throw ManifestError.missingRequiredAttribute(Attributes.Method, element: indexer.element)
        }

        guard let method = HashMethod(rawValue: methodString) else {
            throw ManifestError.unsupportedAttribute(Attributes.Method, value: methodString, element: indexer.element)
        }

        self.method = method
    }

}
