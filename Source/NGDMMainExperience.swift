//
//  NGDMMainExperience.swift
//

import Foundation

// Wrapper class for `NGEExperienceType` Manifest object associated with the main Experience
open class NGDMMainExperience: NGDMExperience {
    
    // MARK: Instance Variables
    /// List of Talent associated with the feature film
    var talents: [String: NGDMTalent]?
    
    /// Ordered list of Talents with type Actor associated with the feature film
    public var orderedActors: [NGDMTalent]? {
        if let talents = talents {
            return talents.values.filter { (talent) -> Bool in
                talent.type == TalentType.actor
            }.sorted(by: { (talent1, talent2) -> Bool in
                return talent1.billingBlockOrder < talent2.billingBlockOrder
            })
        }
        
        return nil
    }
    
    public var hasActors: Bool {
        return ((orderedActors?.count ?? 0) > 0)
    }
    
    public var interstitialVideoURL: URL? {
        return audioVisual?.interstitialVideoURL
    }
    
    public var commentaryAudioURL: URL? {
        return presentation?.commentaryAudioURL
    }
    
    // MARK: Helper Methods
    /**
        Find the value of any custom identifier associated with this Experience

        - Parameters:
            - namespace: The namespace of the custom identifier used in the Manifest

        - Returns: The value of the custom identifier if it exists
    */
    public func customIdentifier(_ namespace: String) -> String? {
        return audioVisual?.metadata?.customIdentifier(namespace)
    }
    
    /**
        Loads talent based on a series of fallbacks, starting with the Baseline API
    */
    public func loadTalent() {
        let loadTalentImages = {
            if let talentAPIUtil = NGDMConfiguration.talentAPIUtil, let talents = self.talents {
                for talent in talents.values {
                    if talent.images == nil, let talentId = talent.apiID {
                        talentAPIUtil.getTalentImages(talentId, completion: { (talentImages) in
                            talent.images = talentImages
                        })
                    }
                }
            }
        }
        
        if let talents = audioVisual?.metadata?.talents {
            self.talents = talents
        } else if let talentAPIUtil = NGDMConfiguration.talentAPIUtil {
            talentAPIUtil.prefetchCredits({ (talents) in
                self.talents = talents
                loadTalentImages()
            })
        }
        
        loadTalentImages()
    }
    
}
