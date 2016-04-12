//
//  VEditCommentViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 12/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

extension VEditCommentViewController {
    
    func editComment( comment: VComment, withText text: String ) {
        CommentEditOperation(commentID: comment.remoteId.integerValue, text: text).queue()
    }
}
