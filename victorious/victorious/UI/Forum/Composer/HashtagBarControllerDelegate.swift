//
//  HashtagBarControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol HashtagBarControllerDelegate: NSObjectProtocol {
    
    func hashtagBarController(hashtagBarController: HashtagBarController, selectedHashtag hashtag: VHashtag)
}
