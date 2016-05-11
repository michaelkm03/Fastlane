//
//  VContent+Fetcher.swift
//  victorious
//
//  Created by Vincent Ho on 5/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VContent {
    func contentType() -> ContentType? {
        guard let type = type else {
            return nil
        }
        return ContentType(rawValue: type)
    }
}
