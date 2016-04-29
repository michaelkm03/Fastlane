//
//  ContentView.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public class ContentView {
    public let content: Content
    
    public init?(json: JSON) {
        guard let content = Content(json: json["payload", "content"]) else {
                return nil
        }

        self.content = content
    }
}
