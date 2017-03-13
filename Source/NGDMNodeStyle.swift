//
//  NGDMNodeStyle.swift
//

import Foundation

public enum DeviceTargetClass: String {
    case computer = "Computer"
    case tv = "TV"
    case mobile = "Mobile"
}

public enum DeviceTargetSubClass: String {
    case tablet = "Tablet"
    case phone = "Phone"
}

public enum BackgroundScaleMethod: String {
    case bestFit = "BestFit"
    case full = "Full"
    case tiled = "Tiled"
}

public enum BackgroundPositionMethod: String {
    case upperLeft = "upperleft"
    case upperRight = "upperright"
    case centered = "centered"
}

open class NGDMNodeStyle {
    
    // MARK: Instance Variables
    /// Unique identifier
    var id: String
    
    /// Properties
    public var supportsLandscape = false
    public var supportsPortrait = false
    public var supportsTablet = false
    public var supportsPhone = false
    
    /// General theme (includes buttons)
    var theme: NGDMTheme!
    
    /// Background properties
    public var backgroundColor = UIColor.black
    public var backgroundScaleMethod = BackgroundScaleMethod.bestFit
    public var backgroundPositionMethod = BackgroundPositionMethod.centered
    
    /// Background image
    private var backgroundImage: NGDMImage?
    open var backgroundImageSize: CGSize {
        return (backgroundImage?.size ?? CGSize.zero)
    }
    
    open var backgroundImageURL: URL? {
        return backgroundImage?.url
    }
    
    /// Background video
    private var backgroundPresentation: NGDMPresentation?
    open var backgroundVideoLoops = false
    open var backgroundVideoLoopTimecode = 0.0
    open var backgroundVideoSize: CGSize {
        return (backgroundPresentation?.videoSize ?? CGSize.zero)
    }
    
    open var backgroundVideoURL: URL? {
        return backgroundPresentation?.videoURL
    }
    
    /// Background audio
    var backgroundAudio: NGDMAudio?
    open var backgroundAudioURL: URL? {
        return backgroundAudio?.url
    }
    
    /// Button overlay
    public var buttonOverlaySize: CGSize?
    public var buttonOverlayBottomLeft: CGPoint?
    
    /// Title treatment overlay
    public var titleOverlaySize: CGSize?
    public var titleOverlayBottomLeft: CGPoint?
    
    // MARK: Initialization
    /**
        Initializes a new NodeStyle
     
        - Parameters:
            - manifestObject: Raw Manifest data object
     */
    init(manifestObject: NGENodeStyleType) {
        id = manifestObject.NodeStyleID
        
        if let backgroundObj = manifestObject.Background {
            backgroundVideoLoops = backgroundObj.looping != nil && backgroundObj.looping!
            
            if let colorString = backgroundObj.Color {
                backgroundColor = UIColor(hexString: colorString)
            }
            
            if let backgroundAdaptationObj = backgroundObj.Adaptation {
                if let rawString = backgroundAdaptationObj.ScaleMethod, let scaleMethod = BackgroundScaleMethod(rawValue: rawString) {
                    backgroundScaleMethod = scaleMethod
                }
                
                if let rawString = backgroundAdaptationObj.PositioningMethod, let positionMethod = BackgroundPositionMethod(rawValue: rawString) {
                    backgroundPositionMethod = positionMethod
                }
            }
            
            if let backgroundVideoObj = backgroundObj.Video {
                if let id = backgroundVideoObj.PresentationID {
                    backgroundPresentation = NGDMPresentation.getById(id)
                }
                
                if let timecodeString = backgroundVideoObj.LoopTimecode?.value {
                    backgroundVideoLoopTimecode = (Double(timecodeString) ?? 0)
                }
            }
            
            if let backgroundImagePictureGroupId = backgroundObj.Image?.PictureGroupID {
                backgroundImage = NGDMManifest.sharedInstance.pictureGroups[backgroundImagePictureGroupId]?.first?.image
            }
            
            if let id = backgroundObj.AudioLoop?.AudioTrackID {
                backgroundAudio = NGDMAudio.getById(id)
            }
            
            if let overlayObjList = backgroundObj.OverlayAreaList {
                for overlayObj in overlayObjList {
                    if let tagName = overlayObj.tag?.lowercased() {
                        let size = CGSize(width: CGFloat(overlayObj.WidthPixels), height: CGFloat(overlayObj.HeightPixels))
                        let point = CGPoint(x: CGFloat(overlayObj.PixelsFromLeft), y: CGFloat(overlayObj.PixelsFromBottom))
                        
                        if tagName == "button" {
                            buttonOverlaySize = size
                            buttonOverlayBottomLeft = point
                        } else if tagName == "title" {
                            titleOverlaySize = size
                            titleOverlayBottomLeft = point
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Helper Methods
    /**
        Finds a button image with the given label

        - Parameters:
            - label: Button label name to search
 
        - Returns: Button image if it exists
    */
    public func getButtonImage(_ label: String) -> NGDMImage? {
        return theme.getButtonImage(label)
    }
    
    // MARK: Search Methods
    /**
        Find an `NGDMNodeStyle` object by unique identifier
     
        - Parameters:
            - id: Unique identifier to search for
     
        - Returns: Object associated with identifier if it exists
     */
    static func getById(_ id: String) -> NGDMNodeStyle? {
        return NGDMManifest.sharedInstance.nodeStyles[id]
    }
    
}
