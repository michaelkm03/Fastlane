//
//  VHashtag+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VHashtag: PersistenceParsable {
    
    func populate( fromSourceModel hashtag: Hashtag ) {
        tag = hashtag.tag
        count = hashtag.count == nil ? count : NSNumber(longLong: hashtag.count!)
    }
}
