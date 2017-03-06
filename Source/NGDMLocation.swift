//
//  NGDMLocation.swift
//

// Wrapper class for `NGEAppDataType` and `NGEEventLocationType` Manifest objects
open class NGDMLocation: NGDMAppData {
    
    // MARK: Instance Variables
    /// Metadata
    public var name: String?
    public var address: String?
    
    var icon: NGDMImage?
    public var iconImage: UIImage? {
        if let icon = icon {
            return NGDMManifest.sharedInstance.imageCache[icon.id]
        }
        
        return nil
    }
    
    override public var thumbnailImageURL: URL? {
        if let thumbnailImageURL = super.thumbnailImageURL {
            return thumbnailImageURL
        }
        
        return mapImageURL
    }
    
    public var mapImageURL: URL? {
        if let key = NGDMConfiguration.googleMapsAPIKey {
            let locationString = "\(latitude),\(longitude)"
            let zoomString = String(max(Int(zoomLevel) - 4, 1))
            if let urlString = "http://maps.googleapis.com/maps/api/staticmap?center=\(locationString)&zoom=\(zoomString)&scale=2&size=480x270&maptype=roadmap&format=png&visual_refresh=true&key=\(key)".addingPercentEscapes(using: .utf8) {
                return URL(string: urlString)
            }
        }
        
        return nil
    }
    
    /// Coordinates
    public var latitude: Double = 0
    public var longitude: Double = 0
    
    /// Settings
    public var zoomLevel: Float = 0
    public var zoomLocked = false
    
    // MARK: Initialization
    /**
        Initializes a new NGETimedEventType
    
        - Parameters:
            - manifestObject: Raw Manifest data object
    */
    override init(manifestObject: NGEAppDataType) {
        super.init(manifestObject: manifestObject)
        
        for obj in manifestObject.NVPairList {
            if let name = obj.Name {
                switch name {
                case AppDataNVPairName.Location:
                    if let obj = (obj.Location ?? obj.LocationSet?.LocationList?.first) {
                        if let id = (obj as? NGELocation)?.icon {
                            icon = NGDMImage.getById(id)
                        }
                        
                        address = obj.Address
                        latitude = (obj.EarthCoordinate?.Latitude ?? 0)
                        longitude = (obj.EarthCoordinate?.Longitude ?? 0)
                    }
                    
                    break
                    
                case AppDataNVPairName.Zoom:
                    zoomLevel = Float(obj.Integer ?? 0)
                    break
                    
                case AppDataNVPairName.ZoomLocked:
                    zoomLocked = (obj.Text == "Y")
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
}
