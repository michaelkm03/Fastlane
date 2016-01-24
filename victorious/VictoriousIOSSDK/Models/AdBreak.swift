//
//  AdBreak.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct AdBreak: ModelType {
    public let adSystemID: Int
    public let timeout: Int
    public let adTag: String?
    public let cannedAdXML: String?
}

extension AdBreak {
    public init?(json: JSON) {
        guard let adSystemID = json["ad_system_id"].int, timeout = json["timeout"].int else {
            return nil
        }

        let adTag = json["ad_tag"].string
        let cannedAdXML = json["canned_ad_xml"].string

        if adTag == nil && cannedAdXML == nil {
            print("Failed to parse an AdBreak because there is no ad information")
            return nil
        }

        self.adSystemID = adSystemID
        self.timeout = timeout
        self.adTag = adTag
        self.cannedAdXML = cannedAdXML
    }
}
