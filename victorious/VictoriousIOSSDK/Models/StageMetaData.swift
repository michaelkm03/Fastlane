//
//  StageMetaData.swift
//  victorious
//
//  Created by Sebastian Nystorm on 12/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

///
/// Contains meta data about the content currently on stage right now. It is populated by data from the refresh stage event.
/// 
public struct StageMetaData {

    public let title: String?

    public init(title: String? = nil) {
        self.title = title
    }
}
