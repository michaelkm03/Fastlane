//
//  StageMetaData.swift
//  victorious
//
//  Created by Sebastian Nystorm on 12/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

///
/// Contains meta data about the content currently on stage right now.
/// 
/// Since this struct holds data from two separate parts of the stage update flow, it is populated in two steps.
/// 1. When a stage refresh message is received from the backend.
/// 2. When the actual content has been fetched.
///
public struct StageMetaData {

    let title: String?
    private(set) var description: String?
    private(set) var author: UserModel?

    public init(title: String? = nil) {
        self.title = title
        description = nil
        author = nil
    }

    /// Populates the StageMetaData struct with information about the content and it's author.
    public mutating func populateWith(content: ContentModel) {
        self.description = content.text
        self.author = content.author
    }
}
