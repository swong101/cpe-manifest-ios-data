//
//  Person.swift
//

import Foundation
import SWXMLHash

public enum SocialAccountType: String {
    case unknown = "UNKNOWN"
    case facebook = "FACEBOOK"
    case twitter = "TWITTER"
    case instagram = "INSTAGRAM"
}

public struct TalentImage {

    public var thumbnailImageURL: URL?
    public var imageURL: URL?

    public init() {

    }

}

public struct Film {

    var id: String
    public var title: String
    public var imageURL: URL?

    public init(id: String, title: String, imageURL: URL? = nil) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
    }

}

public struct SocialAccount {

    public var type = SocialAccountType.unknown
    public var handle: String
    public var url: URL?

    public init(handle: String, urlString: String) {
        self.handle = handle

        if urlString.contains("twitter") {
            type = .twitter
        } else if urlString.contains("facebook") {
            type = .facebook
        } else if urlString.contains("instagram") {
            type = .instagram
        }

        url = URL(string: urlString)
    }

}

public enum PersonJobFunction: String {
    case actor = "Actor"
    case director = "Director"
    case producer = "Producer"
    case writer = "Writer"

    public static func build(rawValue: String?) -> PersonJobFunction {
        if let rawValue = rawValue, let jobFunction = PersonJobFunction(rawValue: rawValue) {
            return jobFunction
        }

        return .actor
    }
}

public struct PersonJob {

    private struct Elements {
        static let JobFunction = "JobFunction"
        static let BillingBlockOrder = "BillingBlockOrder"
        static let Character = "Character"
    }

    var function: PersonJobFunction
    var billingBlockOrder: Int = 0
    var characters: [String]?

    init(function: PersonJobFunction = .actor, billingBlockOrder: Int = 0, character: String? = nil) {
        self.function = function
        self.billingBlockOrder = billingBlockOrder
        if let character = character {
            characters = [character]
        }
    }

    init(indexer: XMLIndexer) throws {
        // JobFunction
        guard let functionString = indexer.stringValue(forElement: Elements.JobFunction) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.JobFunction, element: indexer.element)
        }

        function = PersonJobFunction.build(rawValue: functionString)

        // BillingBlockOrder
        if let billingBlockOrder = indexer.intValue(forElement: Elements.BillingBlockOrder) {
            self.billingBlockOrder = billingBlockOrder
        }

        // Character
        if indexer.hasElement(Elements.Character) {
            characters = indexer[Elements.Character].flatMap({ $0.stringValue })
        }
    }

}

public func == (lhs: Person, rhs: Person) -> Bool {
    return (lhs.id == rhs.id)
}

open class Person: Equatable, Trackable {

    private struct Elements {
        static let Job = "Job"
        static let Name = "Name"
        static let DisplayName = "DisplayName"
        static let Identifier = "Identifier"
    }

    public var jobs: [PersonJob]?
    public var name: String
    var contentIdentifiers: [ContentIdentifier]?
    public var biography: String?
    public var images: [TalentImage]?
    public var socialAccounts: [SocialAccount]?
    public var films: [Film]?

    open var id: String {
        return (personID ?? apiID)!
    }

    private var customAPIID: String?
    open var apiID: String? {
        if let apiID = customAPIID {
            return apiID
        }

        if let talentAPIUtil = CPEXMLSuite.Settings.talentAPIUtil {
            let apiNamespace = type(of: talentAPIUtil).APINamespace
            return contentIdentifiers?.first(where: { $0.namespace == apiNamespace })?.identifier
        }

        return nil
    }

    open var personID: String? {
        return contentIdentifiers?.first(where: { $0.namespace == Namespaces.PeopleID })?.identifier
    }

    open var character: String? {
        return jobs?.first?.characters?.first
    }

    open var billingBlockOrder: Int {
        return (jobs?.first?.billingBlockOrder ?? 0)
    }

    open var isActor: Bool {
        if let jobs = jobs {
            return jobs.contains(where: { $0.function == .actor })
        }

        return true
    }

    open var thumbnailImageURL: URL? {
        return images?.first?.thumbnailImageURL
    }

    open var fullImageURL: URL? {
        return images?.first?.imageURL
    }

    open var additionalImages: [TalentImage]? {
        if var images = images {
            images.remove(at: 0)
            return images
        }

        return nil
    }

    public var detailsLoaded = false

    // Trackable
    open var analyticsID: String {
        return id
    }

    public init(apiID: String, name: String, jobFunction: PersonJobFunction = .actor, billingBlockOrder: Int = 0, character: String? = nil) {
        self.customAPIID = apiID
        self.name = name
        if let character = character {
            jobs = [PersonJob(function: jobFunction, billingBlockOrder: billingBlockOrder, character: character)]
        }
    }

    init(indexer: XMLIndexer) throws {
        // Job
        guard indexer.hasElement(Elements.Job) else {
            throw ManifestError.missingRequiredChildElement(name: Elements.Job, element: indexer.element)
        }

        jobs = try indexer[Elements.Job].flatMap({ try PersonJob(indexer: $0) })

        // Name
        guard let name = indexer[Elements.Name][Elements.DisplayName].stringValue else {
            throw ManifestError.missingRequiredChildElement(name: "\(Elements.Name).\(Elements.DisplayName)", element: indexer.element)
        }

        self.name = name

        // Identifier
        if indexer.hasElement(Elements.Identifier) {
            contentIdentifiers = try indexer[Elements.Identifier].flatMap({ try ContentIdentifier(indexer: $0) })
        }
    }

    open func getTalentDetails(_ successBlock: @escaping (_ biography: String?, _ socialAccounts: [SocialAccount]?, _ films: [Film]?) -> Void) {
        if detailsLoaded {
            successBlock(biography, socialAccounts, films)
        } else if let talentAPIUtil = CPEXMLSuite.Settings.talentAPIUtil, let id = apiID {
            talentAPIUtil.getTalentDetails(id, completion: { [weak self] (biography, socialAccounts, films) in
                if let strongSelf = self {
                    strongSelf.biography = biography
                    strongSelf.socialAccounts = socialAccounts
                    strongSelf.films = films
                    strongSelf.detailsLoaded = true
                }

                successBlock(biography, socialAccounts, films)
            })
        } else {
            successBlock(biography, socialAccounts, films)
            detailsLoaded = true
        }
    }

}
