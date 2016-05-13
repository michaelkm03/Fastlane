//
//  ViewedContent.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public class ViewedContent {
    public let content: Content
    public let author: User
    
    public init?(json: JSON) {
        guard let content = Content(json: json["content"]),
            let author = User(json: json["author"]) else {
                return nil
        }
        
        self.content = content
        self.author = author
    }
}
