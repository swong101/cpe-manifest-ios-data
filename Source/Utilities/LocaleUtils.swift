//
//  NSLocale+Utils.swift
//
//

import Foundation

extension Locale {
    
    static var deviceLanguage: String {
        return Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
    }
    
    static var deviceLanguageBackup: String {
        return deviceLanguage[deviceLanguage.startIndex ..< deviceLanguage.characters.index(deviceLanguage.startIndex, offsetBy: 2)]
    }
    
}
