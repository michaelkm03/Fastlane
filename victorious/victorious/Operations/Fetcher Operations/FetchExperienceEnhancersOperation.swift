//
//  ExperienceEnhancersOperation.swift
//  victorious
//
//  Created by Michael Sena on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// Creates and populates `VExperienceEnhancers` with any data already stored in Core Data.
class ExperienceEnhancersOperation: FetcherOperation {
    
    let sequenceID: String
    var productsDataSource: TemplateProductsDataSource
    
    init(sequenceID: String, productsDataSource: TemplateProductsDataSource) {
        self.sequenceID = sequenceID
        self.productsDataSource = productsDataSource
    }
    
    override func main() {
        
        self.results = persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let sequence: VSequence = context.v_findObjects(["remoteId" : self.sequenceID]).first else {
                return []
            }
            
            let voteTypes = self.productsDataSource.voteTypes
            guard !voteTypes.isEmpty else {
                return []
            }
            
            var experienceEnhancers = [VExperienceEnhancer]()
            for voteType in voteTypes {
                
                let voteCount: UInt
                if let allVoteResults = sequence.voteResults as? Set<VVoteResult>,
                    let voteResult = allVoteResults.filter({ $0.remoteId.stringValue == voteType.voteTypeID }).first {
                        voteCount = voteResult.count.unsignedIntegerValue
                } else {
                    voteCount = 0
                }
                
                let enhancer = VExperienceEnhancer(voteType: voteType, voteCount: voteCount)
                
                // Get icon image synhronously (we need it right away)
                let imageCache = VExperienceEnhancerController.imageMemoryCache()
                let key = voteType.voteTypeID
                if let imageForKey = imageCache.objectForKey(key) as? UIImage {
                    enhancer.iconImage = imageForKey
                } else {
                    enhancer.iconImage = voteType.iconImage
                    if let voteTypeIcon = voteType.iconImage {
                        imageCache.setObject(voteTypeIcon, forKey: key)
                    }
                }
                experienceEnhancers.append(enhancer)
            }
            return experienceEnhancers
        }
    }
}
