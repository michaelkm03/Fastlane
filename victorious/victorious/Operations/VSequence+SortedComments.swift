//
//  VSequence+SortedComments.swift
//  victorious
//
//  Created by Patrick Lynch on 12/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VSequence {
    
    /// Adds the provided comments to the receiver's `comments` ordered set and sorts by date posted
    /// This is the recommended way to parse loaded or newly-created comments.
    func addAndSortComments( comments: [VComment] ) {
        guard !comments.isEmpty else {
            return
        }
        let allComments: [VComment] = (self.comments.array as? [VComment] ?? []) + comments
        let sortedComments = allComments.sort { return $0.postedAt.compare($1.postedAt) == .OrderedDescending }
        self.comments = NSOrderedSet(array: sortedComments)
        
        for comment in self.comments.array as! [VComment] {
            print( "\(comment.postedAt) :: \(comment.text)" )
        }
    }
}
