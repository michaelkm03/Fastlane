//
//  TextPostAsset.swift
//  victorious
//
//  Created by Tian Lan on 2/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import SwiftyJSON

public struct TextPostAsset {
    public let type: AssetType
    public let data: String
    public let backgroundColor: String?
    public let backgroundImageURL: String?
}

extension TextPostAsset {
    public init?(json: JSON) {
        guard let type = AssetType(rawValue: json["type"].stringValue) where type == .Text,
            let data = json["data"].string else {
                return nil
        }
        self.type = type
        self.data = data
        
        backgroundColor         = json["background_color"].string
        backgroundImageURL      = json["background_image"].string
    }
}
