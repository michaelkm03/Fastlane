//
//  StageContent.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A compound struct that contain both the actual content that goes on stage and 
/// the meta data object that belongs to it.
public struct StageContent {
    public let content: Content
    public let metaData: StageMetaData?

    public init(content: Content, metaData: StageMetaData? = nil) {
        self.content = content
        self.metaData = metaData
    }
}
