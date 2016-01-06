//
//  HashtagSearchResult.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class HashtagSearchResultObject: NSObject {
    
    let sourceResult: VictoriousIOSSDK.Hashtag
    
    init( _ value: VictoriousIOSSDK.Hashtag ) {
        self.sourceResult = value
    }
}
