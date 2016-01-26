//
//  CommentsDataSource.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class CommentsDataSource : PaginatedDataSource {
    
    private let sequence: VSequence
    
    init(sequence: VSequence) {
        self.sequence = sequence
        super.init()
    }
    
    func loadComments( pageType: VPageType, completion:((NSError?)->())? = nil ) {
        self.loadPage( pageType,
            createOperation: {
                return SequenceCommentsOperation(sequenceID: self.sequence.remoteId)
            },
            completion: { (operation, error) in
                completion?(error)
                
                // Start observing after we've loaded once
                self.KVOController.unobserve( self.sequence )
                self.KVOController.observe( self.sequence,
                    keyPath: "comments",
                    options: [.Initial],
                    action: Selector("onCommentsChanged:")
                )
            }
        )
    }
    
    func onCommentsChanged( change: [NSObject : AnyObject]? ) {
        guard let value = change?[ NSKeyValueChangeKindKey ] as? UInt,
            let kind = NSKeyValueChange(rawValue:value) where kind == .Setting else {
                return
        }
        
        self.refreshLocal(
            createOperation: {
                return FetchCommentsOperation(sequenceID: self.sequence.remoteId)
            },
            completion: nil
        )
    }
    
    func deleteSequence( completion completion: ((NSError?)->())? = nil ) {
        DeleteSequenceOperation(sequenceID: self.sequence.remoteId).queue() { error in
            completion?( error )
        }
    }
}
