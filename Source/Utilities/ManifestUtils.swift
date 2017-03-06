//
//  ManifestUtils.swift
//

import Foundation

class ManifestUtils {
    
    static func urlForContainerReference(_ containerReference: NGEContainerReferenceType?) -> URL? {
        if let urlString = containerReference?.ContainerLocationList?.first?.value?.trim() {
            if urlString.contains("file://") {
                let tempURL = URL(fileURLWithPath: urlString.replacingOccurrences(of: "file://", with: ""))
                return Bundle.main.url(forResource: tempURL.deletingPathExtension().path, withExtension: tempURL.pathExtension)
            }
            
            return URL(string: urlString)
        }
        
        return nil
    }
    
}
