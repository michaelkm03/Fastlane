//
//  CommentsDataSourceSwitcher.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// CommentsDataSourceSwitchter switches between an `EmtpyCommentsDataSource` and `SequenceCommentsDataSource` providing a nice absraction between the two states inherent in an optional sequence.
class CommentsDataSourceSwitchter {
    
    /// A `CommentsDataSource` conformant object. Consumers should call methods on this variable when determining the state of the comments.
    var dataSource: CommentsDataSource
    
    private let emptyDataSource = EmtpyCommentsDataSource()
    
    init () {
        dataSource = emptyDataSource
    }
    
    var sequence: VSequence? {
        didSet {
            if let sequence = sequence {
                dataSource = SequenceCommentsDataSource(sequence: sequence)
            }
            else {
                dataSource = emptyDataSource
            }
        }
    }
    
}
