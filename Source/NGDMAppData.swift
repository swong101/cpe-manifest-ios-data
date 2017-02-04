//
//  NGDMAppData.swift
//

import Foundation

// Wrapper class for `NGEExperienceAppType` Manifest object
open class NGDMAppData {
    
    private struct NVPairName {
        static let AppType = "type"
        static let Location = "location"
        static let Text = "text"
        static let Zoom = "zoom"
        static let ZoomLocked = "zoom_locked"
        static let VideoId = "video_id"
        static let GalleryId = "gallery_id"
        static let LocationThumbnail = "location_thumbnail"
        static let VideoThumbnail = "video_thumbnail"
        static let GalleryThumbnail = "gallery_thumbnail"
        static let ExperienceId = "experience_id"
    }
    
    // MARK: Instance Variables
    /// Unique identifier
    var id: String!
    open var analyticsIdentifier: String {
        return id
    }
    
    /// Metadata
    private var _title: String?
    public var title: String? {
        return (experience?.title ?? _title)
    }
    
    public var thumbnailImageURL: URL? {
        if let imageURL = experience?.imageURL {
            return imageURL
        }
        
        if let location = location {
            return URL(string: "http://maps.googleapis.com/maps/api/staticmap" +
                "?center=" + String(location.latitude) + "," + String(location.longitude) +
                "&zoom=" + String(max(Int(zoomLevel) - 4, 1)) +
                "&scale=2&size=480x270&maptype=roadmap&format=png&visual_refresh=true"
            )
        }
        
        return nil
    }
    
    public var description: String? {
        return experience?.description
    }
    
    /// Media
    var experience: NGDMExperience?
    public var location: NGDMLocation?
    public var zoomLevel: Float = 0
    public var zoomLocked = false
    public var mediaCount: Int {
        return (experience?.childExperiences?.count ?? 0)
    }
    
    /// Check if AppData is location-based
    public var isLocation: Bool {
        return (location != nil)
    }
    
    // MARK: Initialization
    /**
        Initializes a new AppData
     
        - Parameters:
            - manifestObject: Raw Manifest data object
     */
    init(manifestObject: NGEAppDataType) {
        id = manifestObject.AppID
        
        for obj in manifestObject.NVPairList {
            if let name = obj.Name {
                switch name {
                case NVPairName.Location:
                    if let obj = (obj.Location ?? obj.LocationSet?.LocationList?.first) {
                        location = NGDMLocation(manifestObject: obj)
                    }
                    
                    break
                    
                case NVPairName.Zoom:
                    zoomLevel = Float(obj.Integer ?? 0)
                    break
                    
                case NVPairName.ZoomLocked:
                    zoomLocked = (obj.Text == "Y")
                    break
                    
                case NVPairName.ExperienceId:
                    if let id = obj.ExperienceID {
                        experience = NGDMExperience.getById(id)
                    }
                    
                    break
                    
                case NVPairName.AppType:
                    _title = obj.Text
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: Helper Methods
    /**
        Finds the Experience media associated with the AppData at the specified index
     
        - Parameters:
            - index: Media index to search
     
        - Returns: Associated Experience if it exists
     */
    public func mediaAtIndex(_ index: Int) -> NGDMExperience? {
        return (index < mediaCount ? experience?.childExperiences?[index] : nil)
    }
    
}
