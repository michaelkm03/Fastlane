//
//  StageMetaData.swift
//  victorious
//
//  Created by Sebastian Nystorm on 12/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Contains meta data about the content currently on stage right now.
public struct StageMetaData {

    let title: String?
    private(set) var description: String?
    private(set) var author: UserModel?

    public init(title: String? = nil) {
        self.title = title
        description = nil
        author = nil
    }

    /// The StageMetaData struct is constructed at a two step process and aggregates data from the stage refresh even and the content fetching event.
    public mutating func populateWith(content: ContentModel) {
        self.description = content.text
        self.author = content.author
    }
}
