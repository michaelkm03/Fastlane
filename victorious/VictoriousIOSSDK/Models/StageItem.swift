//
//  StageItem.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A compound struct that contain both the actual content that goes on stage and 
/// the metaData object that belongs to it.
public struct StageItem {
    public let content: ContentModel
    public let metaData: StageMetaData?

    public init(content: ContentModel, metaData: StageMetaData? = nil) {
        self.content = content
        self.metaData = metaData
    }
}
