//
//  NGDMPeople.swift
//

public enum TalentType: String {
    case unknown = "Unknown"
    case actor = "Actor"
    case director = "Director"
    case producer = "Producer"
    case writer = "Writer"
}

public enum SocialAccountType: String {
    case unknown = "UNKNOWN"
    case facebook = "FACEBOOK"
    case twitter = "TWITTER"
    case instagram = "INSTAGRAM"
}

// Wrapper class for `NGEBasicMetadataPeopleType` Manifest object
open class NGDMPeople: NSObject {
    
    // MARK: Instance Variables
    open var id: String!
    open var apiID: String?
    
    open var name: String?
    open var role: String?
    open var billingBlockOrder = 0
    var type = TalentType.unknown
    var biography: String?
    open var images: [TalentImage]?
    open var films: [TalentFilm]?
    var socialAccounts: [TalentSocialAccount]?
    open var detailsLoaded = false
    
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
    
    // MARK: Initialization
    /**
        Initializes a new People object
     
        - Parameters:
            - manifestObject: Raw Manifest data object
     */
    convenience init(manifestObject: NGEBasicMetadataPeopleType) {
        self.init()
        
        if let identifiers = manifestObject.IdentifierList {
            for identifier in identifiers {
                if identifier.Namespace == Namespaces.PeopleID {
                    id = identifier.Identifier
                } else if let talentAPIUtil = NGDMConfiguration.talentAPIUtil, type(of: talentAPIUtil).APINamespace == identifier.Namespace {
                    apiID = identifier.Identifier
                }
            }
        }
        
        id = (id ?? apiID ?? String(arc4random()))
        name = manifestObject.Name.DisplayNameList.first?.value
        role = manifestObject.JobList.first?.CharacterList?.first
        if let job = manifestObject.JobList.first {
            if job.BillingBlockOrder != nil {
                billingBlockOrder = job.BillingBlockOrder!
            }
            
            if let jobFunction = job.JobFunction?.value, let type = TalentType(rawValue: jobFunction) {
                self.type = type
            } else {
                type = .unknown
            }
        }
    }
    
}

// Alias for `NGDMPeople`
open class NGDMTalent: NGDMPeople {
    
    // MARK: Initialization
    /**
        Initializes a new People object from custom data
     
        - Parameters:
            - baselineInfo: Response from the Baseline API
     */
    public convenience init(apiID: String, name: String?, role: String?, billingBlockOrder: Int, type: TalentType) {
        self.init()
        
        self.apiID = apiID
        self.name = name
        self.role = role
        self.billingBlockOrder = billingBlockOrder
        self.type = type
    }
    
    open func getTalentDetails(_ successBlock: @escaping (_ biography: String?, _ socialAccounts: [TalentSocialAccount]?, _ films: [TalentFilm]?) -> Void) {
        if detailsLoaded {
            successBlock(biography, socialAccounts, films)
        } else if let talentAPIUtil = NGDMConfiguration.talentAPIUtil, let id = apiID {
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

public struct TalentImage {
    
    public var thumbnailImageURL: URL?
    public var imageURL: URL?
    
    public init() {
        
    }
    
}

public struct TalentFilm {
    
    var id: String!
    public var title: String!
    public var imageURL: URL?
    
    public init(id: String, title: String, imageURL: URL?) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
    }
    
}

public struct TalentSocialAccount {
    
    public var type = SocialAccountType.unknown
    public var handle: String
    public var url: URL?
    
    public init(handle: String, urlString: String) {
        self.handle = handle
        
        var urlString = urlString
        if urlString.contains("twitter") {
            type = SocialAccountType.twitter
        } else if urlString.contains("facebook") {
            type = SocialAccountType.facebook
        } else if urlString.contains("instagram") {
            type = SocialAccountType.instagram
        }
        
        url = URL(string: urlString)
    }
    
}
