//
//  ExperienceEnhancersOperation.swift
//  victorious
//
//  Created by Michael Sena on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// Creates and populates `VExperienceEnhancers` with any data already stored in Core Data.
class ExperienceEnhancersOperation: Operation {
    
    let sequenceManagedObjectID: NSManagedObjectID
    let voteTypes: [VVoteType]
    let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    var experienceEnhancers: [VExperienceEnhancer]?
    
    init(sequence: VSequence, voteTypes: [VVoteType]) {
        self.sequenceManagedObjectID = sequence.objectID
        self.voteTypes = voteTypes
        super.init()
    }
    
    override func start() {
        beganExecuting()
        
        persistentStore.createBackgroundContext().v_performBlock { context in
            var experienceEnhancers = [VExperienceEnhancer]()
            
            for voteType in self.voteTypes {
                let voteResult = self.resultForVoteType(voteType,
                    withSequenceObjectID: self.sequenceManagedObjectID,
                    fromContext: context)
                let existingVoteCount = voteResult?.count.unsignedIntegerValue
                let enhancer = VExperienceEnhancer(voteType: voteType, voteCount: existingVoteCount ?? 0)
                
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
            self.experienceEnhancers = experienceEnhancers
            self.finishedExecuting()
        }
    }
    
    private func resultForVoteType(voteType: VVoteType, withSequenceObjectID sequenceObjectID: NSManagedObjectID, fromContext: NSManagedObjectContext) -> VVoteResult? {
        guard let sequence = fromContext.objectWithID(sequenceObjectID) as? VSequence,
            voteResultsSet = sequence.voteResults as? Set<VVoteResult> else {
                return nil
        }
        
        return voteResultsSet.filter { $0.remoteId.stringValue == voteType.voteTypeID }.first
    }
    
}
