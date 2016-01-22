//
//  VLikersDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc final class VLikersDataSource: PaginatedDataSource, VUsersDataSource {
    
    let sequence: VSequence
    
    init( sequence: VSequence ) {
        self.sequence = sequence
    }
    
    func users() -> NSOrderedSet {
        return self.visibleItems
    }
    
    func loadUsersWithPageType( pageType: VPageType, completion: (NSError? -> ())? = nil ) {
        
        self.loadPage( pageType,
            createOperation: {
                return SequenceLikersOperation(sequenceID: self.sequence.remoteId)
            },
            completion:{ (operation, error) in
                completion?( error )
            }
        )
    }
    
    // MARK: - VUsersDataSource
    
    func noContentTitle() -> String {
        return  NSLocalizedString( "NoLikersTitle", comment: "" )
    }
    
    func noContentMessage() -> String {
        return  NSLocalizedString( "NoLikersMessage", comment: "" )
    }
    
    func noContentImage() -> UIImage {
        return UIImage(named: "noLikersIcon" )!
    }
}
