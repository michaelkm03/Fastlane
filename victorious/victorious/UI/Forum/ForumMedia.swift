//
//  ForumMedia.swift
//  victorious
//
//  Created by Patrick Lynch on 3/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct ForumMedia {
    let url: NSURL
    let width: CGFloat
    let height: CGFloat
    
    var aspectRatio: CGFloat { return width / height }
}
