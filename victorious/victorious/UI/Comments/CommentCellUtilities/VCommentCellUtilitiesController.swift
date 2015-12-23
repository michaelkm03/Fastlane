//
//  VCommentCellUtilitiesController.swift
//  victorious
//
//  Created by Patrick Lynch on 12/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

public extension VCommentCellUtilitiesController {
    
    func flagComment( comment: VComment ) {
        FlagCommentOperation(commentID: comment.remoteId.longLongValue).queue()
    }
    
    func deleteComment( comment: VComment ) {
        FlagCommentOperation(commentID: comment.remoteId.longLongValue).queue()
    }
}
