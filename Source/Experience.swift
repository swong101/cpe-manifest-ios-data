//
//  Experience.swift
//

import Foundation
import SWXMLHash

public enum ExperienceType {
    case app
    case audioVisual
    case gallery
    case location
    case product
}

public func == (lhs: Experience, rhs: Experience) -> Bool {
    return lhs.id == rhs.id
}

public struct ExperienceChild {

    private struct Elements {
        static let ExperienceID = "ExperienceID"
        static let SequenceInfo = "SequenceInfo"
        static let Number = "Number"
    }

    var experienceID: String
    var sequence: Int = 0

    init(indexer: XMLIndexer) throws {
        // ExperienceID
        guard let id = indexer.stringValue(forElement: Elements.ExperienceID) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.ExperienceID, element: indexer.element)
        }

        self.experienceID = id

        // SequenceInfo
        if indexer.hasElement(Elements.SequenceInfo) {
            // Number
            sequence = (indexer[Elements.SequenceInfo].intValue(forElement: Elements.Number) ?? 0)
        } else {
            sequence = 0
        }
    }

}

open class Experience: MetadataDriven, Equatable, Trackable {

    var nodeStyles: [NodeStyle]?

    private struct Attributes {
        static let ExperienceID = "ExperienceID"
    }

    private struct Elements {
        static let Region = "Region"
        static let ExcludedRegion = "ExcludedRegion"
        static let Country = "country"
        static let AudioVisual = "Audiovisual"
        static let Gallery = "Gallery"
        static let App = "App"
        static let ExperienceChild = "ExperienceChild"
    }

    var id: String
    open var audioVisual: ExperienceAudioVisual?
    open var gallery: Gallery?
    open var app: ExperienceApp?
    open var experienceChildren: [ExperienceChild]?

    override open var title: String? {
        return (super.title ?? location?.title)
    }

    override open var description: String? {
        return (super.description ?? location?.description)
    }

    override open var thumbnailImageURL: URL? {
        if let imageURL = super.thumbnailImageURL {
            return imageURL
        }

        // Break recursion if this is one of the main experiences
        if isMainExperience || isInMovieExperience || isOutOfMovieExperience {
            return nil
        }

        if let imageURL = audioVisual?.thumbnailImageURL {
            return imageURL
        }

        if let imageURL = gallery?.thumbnailImageURL {
            return imageURL
        }

        if let imageURL = location?.thumbnailImageURL {
            return imageURL
        }

        if let imageURL = product?.productImageURL {
            return imageURL
        }

        if let imageURL = app?.thumbnailImageURL {
            return imageURL
        }

        return childExperiences?.first?.thumbnailImageURL
    }

    open var childExperiences: [Experience]? {
        if let experienceChildren = experienceChildren {
            return experienceChildren.flatMap({ CPEXMLSuite.current?.manifest.experienceWithID($0.experienceID) })
        }

        return nil
    }

    open var numChildExperiences: Int {
        return (experienceChildren?.count ?? 0)
    }

    open var location: LocationAppDataItem? {
        return CPEXMLSuite.current?.appData?.locationWithID(app?.id)
    }

    open var locationMediaCount: Int {
        return (location?.mediaCount ?? 0)
    }

    open var product: ProductAppDataItem? {
        return CPEXMLSuite.current?.appData?.productWithID(app?.id)
    }

    open var productCategories: [ProductCategory]? {
        var productCategories: [ProductCategory]?
        if let childExperiences = childExperiences {
            for childExperience in childExperiences {
                if let category = childExperience.product?.category {
                    if productCategories == nil {
                        productCategories = [ProductCategory]()
                    }

                    if !productCategories!.contains(where: { $0.id == category.id }) {
                        productCategories!.append(category)
                    }
                }
            }
        }

        return productCategories
    }

    open var isMainExperience: Bool {
        return (audioVisual?.type == .main)
    }

    open var isInMovieExperience: Bool {
        return (CPEXMLSuite.current?.manifest.inMovieExperience == self)
    }

    open var isOutOfMovieExperience: Bool {
        return (CPEXMLSuite.current?.manifest.outOfMovieExperience == self)
    }

    // Trackable
    public var analyticsID: String {
        return id
    }

    override init?(indexer: XMLIndexer) throws {
        // ExperienceID
        guard let id = indexer.stringValue(forAttribute: Attributes.ExperienceID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.ExperienceID, element: indexer.element)
        }

        self.id = id

        // Region / ExcludedRegion
        if let regionCode = Locale.currentRegionCode {
            if indexer.hasElement(Elements.Region) {
                let supportedRegions = indexer[Elements.Region].flatMap({ $0.stringValue(forElement: Elements.Country) })
                if !supportedRegions.contains(regionCode) {
                    print("Ignoring unsupported Experience object with ID \(id) and Regions \"\(supportedRegions.joined(separator: ", "))\"")
                    return nil
                }
            } else if indexer.hasElement(Elements.ExcludedRegion) {
                let unsupportedRegions = indexer[Elements.ExcludedRegion].flatMap({ $0.stringValue(forElement: Elements.Country) })
                if unsupportedRegions.contains(regionCode) {
                    print("Ignoring unsupported Experience object with ID \(id) and ExcludedRegions \"\(unsupportedRegions.joined(separator: ", "))\"")
                    return nil
                }
            }
        }

        // AudioVisual
        if indexer.hasElement(Elements.AudioVisual) {
            if let audioVisual = try ExperienceAudioVisual(indexer: indexer[Elements.AudioVisual]) {
                self.audioVisual = audioVisual
                if let presentationID = audioVisual.presentationID {
                    CPEXMLSuite.current?.manifest.addMapping(forPresentationID: presentationID, audioVisual: audioVisual)
                }
            }
        }

        // Gallery
        if indexer.hasElement(Elements.Gallery) {
            if let gallery = try Gallery(indexer: indexer[Elements.Gallery]) {
                CPEXMLSuite.current?.manifest.addGallery(gallery)
                self.gallery = gallery
            }
        }

        // App
        if indexer.hasElement(Elements.App) {
            if let app = try ExperienceApp(indexer: indexer[Elements.App]) {
                CPEXMLSuite.current?.manifest.addExperienceApp(app)
                self.app = app
            }
        }

        // ExperienceChild
        if indexer.hasElement(Elements.ExperienceChild) {
            experienceChildren = try indexer[Elements.ExperienceChild].flatMap({ try ExperienceChild(indexer: $0) })
        }

        // MetadataDriven
        try super.init(indexer: indexer)
    }

    // MARK: Helper Methods
    /**
        Check if Experience is of the specified type
     
        - Parameters:
            - type: Type of Experience
     
        - Returns: `true` if the Experience is of the specified type
     */
    // FIXME: Hardcoded Experience ID strings are being used to identify Experience types
    open func isType(_ type: ExperienceType) -> Bool {
        switch type {
        case .app:
            return (app != nil)

        case .audioVisual:
            return audioVisual != nil

        case .gallery:
            return (gallery != nil)

        case .location:
            if location != nil {
                return true
            }

            if let firstChildExperience = childExperiences?.first {
                return firstChildExperience.isType(.location)
            }

            return false

        case .product:
            if product != nil {
                return true
            }

            if let firstChildExperience = childExperiences?.first {
                return firstChildExperience.isType(.product)
            }

            return false
        }
    }

    /**
        Finds the Experience media associated with the AppData at the specified index
 
        - Parameters:
            - index: Media index to search
 
        - Returns: Associated Experience if it exists
    */
    open func locationMediaAtIndex(_ index: Int) -> Experience? {
        return location?.mediaAtIndex(index)
    }

    /**
        Finds the NodeStyle matching the current orientation and device
 
        - Parameters:
            - interfaceOrientation: Current device orientation
 
        - Returns: Current NodeStyle if it exists
    */
    open func getNodeStyle(_ interfaceOrientation: UIInterfaceOrientation) -> NodeStyle? {
        var tabletLandscapeNodeStyle: NodeStyle?
        var tabletPortraitNodeStyle: NodeStyle?
        var phoneLandscapeNodeStyle: NodeStyle?
        var phonePortraitNodeStyle: NodeStyle?

        if let nodeStyles = nodeStyles {
            for nodeStyle in nodeStyles {
                if nodeStyle.supportsTablet {
                    if nodeStyle.supportsLandscape {
                        tabletLandscapeNodeStyle = nodeStyle
                    } else if nodeStyle.supportsPortrait {
                        tabletPortraitNodeStyle = nodeStyle
                    }
                }

                if nodeStyle.supportsPhone {
                    if nodeStyle.supportsLandscape {
                        phoneLandscapeNodeStyle = nodeStyle
                    } else if nodeStyle.supportsPortrait {
                        phonePortraitNodeStyle = nodeStyle
                    }
                }
            }
        }

        let isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return (isLandscape ? (tabletLandscapeNodeStyle ?? tabletPortraitNodeStyle) : (tabletPortraitNodeStyle ?? tabletLandscapeNodeStyle))
        }

        return (isLandscape ? (phoneLandscapeNodeStyle ?? phonePortraitNodeStyle) : (phonePortraitNodeStyle ?? phoneLandscapeNodeStyle))
    }

    /**
        Finds the ExperienceChild at the given index
 
        - Parameters:
            - index: Child experience index to search
 
        - Returns: Child experience, if it exists
    */
    open func childExperience(atIndex index: Int) -> Experience? {
        if let childExperiences = childExperiences, childExperiences.count > index {
            return childExperiences[index]
        }

        return nil
    }

}
