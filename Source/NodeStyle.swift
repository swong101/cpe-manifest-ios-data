//
//  NodeStyle.swift
//

import Foundation
import SWXMLHash

public enum BackgroundScaleMethod: String {
    case bestFit = "BestFit"
    case full = "Full"
    case tiled = "Tiled"
}

public enum BackgroundPositioningMethod: String {
    case upperLeft = "upperleft"
    case upperRight = "upperright"
    case centered = "centered"
}

public struct OverlayArea {

    private struct Elements {
        static let WidthPixels = "WidthPixels"
        static let HeightPixels = "HeightPixels"
        static let PixelsFromLeft = "PixelsFromLeft"
        static let PixelsFromBottom = "PixelsFromBottom"
    }

    public var size: CGSize
    public var bottomLeftPoint: CGPoint

    init(indexer: XMLIndexer) throws {
        // WidthPixels
        guard let width = indexer.intValue(forElement: Elements.WidthPixels) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.WidthPixels, element: indexer.element)
        }

        // HeightPixels
        guard let height = indexer.intValue(forElement: Elements.HeightPixels) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.HeightPixels, element: indexer.element)
        }

        // PixelsFromLeft
        guard let pixelsFromLeft = indexer.intValue(forElement: Elements.PixelsFromLeft) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.PixelsFromLeft, element: indexer.element)
        }

        // PixelsFromBottom
        guard let pixelsFromBottom = indexer.intValue(forElement: Elements.PixelsFromBottom) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.PixelsFromBottom, element: indexer.element)
        }

        size = CGSize(width: width, height: height)
        bottomLeftPoint = CGPoint(x: pixelsFromLeft, y: pixelsFromBottom)
    }

}

open class NodeStyle {

    private struct Attributes {
        static let NodeStyleID = "NodeStyleID"
        static let Looping = "looping"
        static let Tag = "tag"
    }

    private struct Elements {
        static let ThemeID = "ThemeID"
        static let Background = "Background"
        static let Color = "Color"
        static let Adaptation = "Adaptation"
        static let ScaleMethod = "ScaleMethod"
        static let PositioningMethod = "PositioningMethod"
        static let Video = "Video"
        static let PresentationID = "PresentationID"
        static let LoopTimecode = "LoopTimecode"
        static let Image = "Image"
        static let PictureGroupID = "PictureGroupID"
        static let AudioLoop = "AudioLoop"
        static let AudioTrackID = "AudioTrackID"
        static let OverlayArea = "OverlayArea"
    }

    private struct OverlayAreaType {
        static let Button = "button"
        static let Title = "title"
    }

    // MARK: Instance Variables
    /// Unique identifier
    var id: String

    /// Properties
    public var supportsLandscape = false
    public var supportsPortrait = false
    public var supportsTablet = false
    public var supportsPhone = false

    /// General theme (includes buttons)
    private var themeID: String
    open lazy var theme: Theme = { [unowned self] in
        return (CPEXMLSuite.current?.cpeStyle?.themeWithID(self.themeID))!
    }()

    /// Background properties
    public var backgroundColor = UIColor.black
    public var backgroundScaleMethod = BackgroundScaleMethod.bestFit
    public var backgroundPositioningMethod = BackgroundPositioningMethod.centered

    /// Background image
    private var backgroundImagePictureGroupID: String?
    
    private lazy var backgroundImage: Image? = { [unowned self] in
        return CPEXMLSuite.current?.manifest.pictureGroupWithID(self.backgroundImagePictureGroupID)?.pictures.first?.image
    }()
    
    open var backgroundImageSize: CGSize {
        return (backgroundImage?.size ?? CGSize.zero)
    }

    open var backgroundImageURL: URL? {
        return backgroundImage?.url
    }

    /// Background video
    private var backgroundPresentationID: String?
    private var backgroundPresentation: Presentation? {
        return CPEXMLSuite.current?.manifest.presentationWithID(backgroundPresentationID)
    }

    open var backgroundVideoLoops = false
    open var backgroundVideoLoopTimecode = 0.0
    open var backgroundVideoSize: CGSize {
        return (backgroundPresentation?.video?.size ?? CGSize.zero)
    }

    open var backgroundVideoURL: URL? {
        return backgroundPresentation?.videoURL
    }

    /// Background audio
    var backgroundAudioID: String?
    var backgroundAudio: Audio?
    open var backgroundAudioURL: URL? {
        return backgroundAudio?.url
    }

    public var buttonOverlayArea: OverlayArea?
    public var titleOverlayArea: OverlayArea?

    init(indexer: XMLIndexer) throws {
        // NodeStyleID
        guard let id = indexer.stringValue(forAttribute: Attributes.NodeStyleID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.NodeStyleID, element: indexer.element)
        }

        self.id = id

        // ThemeID
        guard let themeID = indexer.stringValue(forElement: Elements.ThemeID) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.ThemeID, element: indexer.element)
        }

        self.themeID = themeID

        // Background
        if indexer.hasElement(Elements.Background) {
            let backgroundIndexer = indexer[Elements.Background]

            // Looping
            backgroundVideoLoops = backgroundIndexer.boolValue(forAttribute: Attributes.Looping)

            // Color
            if let colorString = backgroundIndexer.stringValue(forElement: Elements.Color) {
                backgroundColor = UIColor(hexString: colorString)
            }

            // Adaption
            if backgroundIndexer.hasElement(Elements.Adaptation) {
                // ScaleMethod
                if let string = backgroundIndexer[Elements.Adaptation].stringValue(forElement: Elements.ScaleMethod), let scaleMethod = BackgroundScaleMethod(rawValue: string) {
                    backgroundScaleMethod = scaleMethod
                }

                // PositioningMethod
                if let string = backgroundIndexer[Elements.Adaptation].stringValue(forElement: Elements.PositioningMethod), let positioningMethod = BackgroundPositioningMethod(rawValue: string) {
                    backgroundPositioningMethod = positioningMethod
                }
            }

            // Video
            if backgroundIndexer.hasElement(Elements.Video) {
                // PresentationID
                guard let presentationID = backgroundIndexer[Elements.Video].stringValue(forElement: Elements.PresentationID) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.PresentationID, element: backgroundIndexer[Elements.Video].element)
                }

                backgroundPresentationID = presentationID

                // LoopTimecode
                backgroundVideoLoopTimecode = (backgroundIndexer[Elements.Video].doubleValue(forElement: Elements.LoopTimecode) ?? 0)
            }

            // Image
            if backgroundIndexer.hasElement(Elements.Image) {
                // PictureGroupID
                guard let pictureGroupID = backgroundIndexer[Elements.Image].stringValue(forElement: Elements.PictureGroupID) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.PictureGroupID, element: backgroundIndexer[Elements.Image].element)
                }

                backgroundImagePictureGroupID = pictureGroupID
            }

            // AudioLoop
            if backgroundIndexer.hasElement(Elements.AudioLoop) {
                // AudioTrackID
                guard let audioID = backgroundIndexer[Elements.AudioLoop].stringValue(forElement: Elements.AudioTrackID) else {
                    throw ManifestError.missingRequiredChildElement(name: Elements.AudioTrackID, element: backgroundIndexer[Elements.AudioLoop].element)
                }

                backgroundAudioID = audioID
            }

            // OverlayArea
            if backgroundIndexer.hasElement(Elements.OverlayArea) {
                let overlayIndexer = backgroundIndexer[Elements.OverlayArea]

                // Type
                guard let type = overlayIndexer.stringValue(forAttribute: Attributes.Tag)?.lowercased() else {
                    throw ManifestError.missingRequiredAttribute(Attributes.Tag, element: overlayIndexer.element)
                }

                if type == OverlayAreaType.Button {
                    buttonOverlayArea = try OverlayArea(indexer: overlayIndexer)
                } else if type == OverlayAreaType.Title {
                    titleOverlayArea = try OverlayArea(indexer: overlayIndexer)
                }
            }
        }
    }

}
