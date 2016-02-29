//
//  JSONDeseriealizable.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

protocol JSONDeseriealizable {
    init?(json: JSON)
}

extension JSONDeseriealizable {
    init?(url: NSURL) {
        guard let data = NSData(contentsOfURL: url) else {
            print("Failed to read data from fileURL \(url)")
            return nil
        }
        let json = JSON(data: data)
        self.init(json: json)
    }
}
