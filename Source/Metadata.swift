//
//  Metadata.swift
//

import Foundation
import SWXMLHash

open class LocalizedInfo {

    private struct Attributes {
        static let Language = "language"
        static let Default = "default"
    }

    private struct Elements {
        static let TitleDisplay19 = "TitleDisplay19"
        static let TitleDisplay60 = "TitleDisplay60"
        static let TitleDisplayUnlimited = "TitleDisplayUnlimited"
        static let TitleSort = "TitleSort"
        static let ArtReference = "ArtReference"
        static let Summary190 = "Summary190"
        static let Summary400 = "Summary400"
        static let Summary4000 = "Summary4000"
    }

    var language: String
    var isDefault = false

    public var titleShort: String?
    public var titleMedium: String?
    public var titleUnlimited: String?
    public var titleSortable: String
    open var title: String {
        return (titleUnlimited ?? titleSortable)
    }

    public var descriptionShort: String
    public var descriptionMedium: String?
    public var descriptionLong: String?
    open var description: String {
        return (descriptionLong ?? descriptionMedium ?? descriptionShort)
    }

    public var imageURLs: [URL]?
    open var imageURL: URL? {
        return imageURLs?.first
    }

    init(indexer: XMLIndexer) throws {
        // Language
        guard let language = indexer.stringValue(forAttribute: Attributes.Language) else {
            throw ManifestError.missingRequiredAttribute(Attributes.Language, element: indexer.element)
        }

        self.language = language

        // Default
        isDefault = indexer.boolValue(forAttribute: Attributes.Default)

        // TitleDisplay19
        titleShort = indexer.stringValue(forElement: Elements.TitleDisplay19)

        // TitleDisplay60
        titleMedium = indexer.stringValue(forElement: Elements.TitleDisplay60)

        // TitleDisplayUnlimited
        titleUnlimited = indexer.stringValue(forElement: Elements.TitleDisplayUnlimited)

        // TitleSort
        guard let titleSortable = indexer.stringValue(forElement: Elements.TitleSort) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.TitleSort, element: indexer.element)
        }

        self.titleSortable = titleSortable

        // ArtReference
        if indexer.hasElement(Elements.ArtReference) {
            imageURLs = indexer[Elements.ArtReference].flatMap({ $0.urlValue })
        }

        // Summary190
        guard let descriptionShort = indexer.stringValue(forElement: Elements.Summary190) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Summary190, element: indexer.element)
        }

        self.descriptionShort = descriptionShort

        // Summary400
        descriptionMedium = indexer.stringValue(forElement: Elements.Summary400)

        // Summary4000
        descriptionLong = indexer.stringValue(forElement: Elements.Summary4000)
    }

}

open class Metadata {

    private struct Attributes {
        static let ContentID = "ContentID"
    }

    private struct Elements {
        static let BasicMetadata = "BasicMetadata"
        static let LocalizedInfo = "LocalizedInfo"
        static let AltIdentifier = "AltIdentifier"
        static let People = "People"
    }

    var id: String
    private var contentIdentifiers: [ContentIdentifier]?
    private var localizedInfos: [LocalizedInfo]
    public var people: [Person]?
    private var personMapping: [String: Person]?

    private var defaultLocalizedInfo: LocalizedInfo {
        return (localizedInfos.first(where: { $0.isDefault }) ?? localizedInfos.first!)
    }

    open var title: String {
        return title(forLanguage: Locale.deviceLanguage)
    }

    open var description: String {
        return description(forLanguage: Locale.deviceLanguage)
    }

    open var imageURL: URL? {
        return imageURL(forLanguage: Locale.deviceLanguage)
    }

    open lazy var actors: [Person]? = { [unowned self] in
        return self.people?.filter({ $0.isActor })
    }()

    init(indexer: XMLIndexer) throws {
        // ContentID
        guard let id = indexer.stringValue(forAttribute: Attributes.ContentID) else {
            throw ManifestError.missingRequiredAttribute(Attributes.ContentID, element: indexer.element)
        }

        self.id = id

        // BasicMetadata
        guard indexer.hasElement(Elements.BasicMetadata) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.BasicMetadata, element: indexer.element)
        }

        let metadataIndexer = indexer[Elements.BasicMetadata]

        // LocalizedInfo
        guard metadataIndexer.hasElement(Elements.LocalizedInfo) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.LocalizedInfo, element: metadataIndexer.element)
        }

        localizedInfos = try metadataIndexer[Elements.LocalizedInfo].flatMap({ try LocalizedInfo(indexer: $0) })

        // AltIdentifier
        if metadataIndexer.hasElement(Elements.AltIdentifier) {
            contentIdentifiers = try metadataIndexer[Elements.AltIdentifier].flatMap({ try ContentIdentifier(indexer: $0) })
        }

        // People
        if metadataIndexer.hasElement(Elements.People) {
            people = try metadataIndexer[Elements.People].flatMap({ try Person(indexer: $0) }).sorted(by: { (person1, person2) -> Bool in
                return person1.billingBlockOrder < person2.billingBlockOrder
            })
        }
    }

    private func localizedInfo(forLanguage language: String? = nil) -> LocalizedInfo {
        return (localizedInfos.first(where: { $0.language == language }) ?? defaultLocalizedInfo)
    }

    private func title(forLanguage language: String? = nil) -> String {
        return localizedInfo(forLanguage: language).title
    }

    private func description(forLanguage language: String? = nil) -> String {
        return localizedInfo(forLanguage: language).description
    }

    private func imageURL(forLanguage language: String? = nil) -> URL? {
        return localizedInfo(forLanguage: language).imageURL
    }

    open func customIdentifier(_ namespace: String) -> String? {
        return contentIdentifiers?.first(where: { $0.namespace == namespace })?.identifier
    }

    open func personWithID(_ id: String?) -> Person? {
        if let id = id {
            if personMapping == nil, let people = people {
                var personMapping = [String: Person]()
                for person in people {
                    personMapping[person.id] = person
                }

                self.personMapping = personMapping
            }

            return personMapping![id]
        }

        return nil
    }

}
