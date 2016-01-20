//
//  AdBreak.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct AdBreak {
    let adSystemID: Int
    let timeout: Int
    let adTag: String?
    let cannedAdXML: String?
}

extension AdBreak {
    public init?(json: JSON) {
        guard let adSystemID = json["ad_system_id"].int,
            timeout = json["timeout"].int else {
            print("Failed to parse an AdBreak due to missing ad_system_id or timeout")
            return nil
        }

        let adTag = json["ad_tag"].string
        let cannedAdXML = json["canned_ad_xml"].string

        if adTag == nil && cannedAdXML == nil {
            print("Failed to parse an AdBreak ")
            return nil
        }

        self.adSystemID = adSystemID
        self.timeout = timeout
        self.adTag = adTag
        self.cannedAdXML = cannedAdXML
    }
}
