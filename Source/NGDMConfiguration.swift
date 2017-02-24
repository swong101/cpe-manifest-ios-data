//
//  NGDMConfiguration.swift
//

import Foundation

public enum NGDMMapService {
    case googleMaps
    case appleMaps
}

public struct NGDMConfiguration {
    
    /// The TalentAPIUtil to be used to fetch talent details from a third party API, if any
    public static var talentAPIUtil: TalentAPIUtil?
    
    // The ProductAPIUtil to be used to fetch shopping experience product details from a third party API, if any
    public static var productAPIUtil: ProductAPIUtil?
    
    /// The map service to be used to display any interactive maps in the UI
    public static var mapService = NGDMMapService.appleMaps
    public static var googleMapsAPIKey: String?
    
}
