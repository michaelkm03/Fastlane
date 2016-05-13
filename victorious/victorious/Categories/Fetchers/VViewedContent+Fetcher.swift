//
//  VViewedContent+Fetcher.swift
//  victorious
//
//  Created by Vincent Ho on 5/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VViewedContent {
    var contentID: String {
        return content?.remoteID ?? ""
    }
}
