//
//  DeviceExperiment.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct DeviceExperiment {
    public let id: Int
    public let name: String
    public let bucketType: String
    public let numberOfBuckets: Int
    public let layerID: Int
    public let layerName: String
}

extension DeviceExperiment {
    public init?(json: JSON) {
        if let experimentID = Int(json["id"].stringValue), let layerID = Int(json["layer_id"].stringValue) {
            self.id = experimentID
            self.layerID = layerID
        }
        else {
            id = -1
            name = ""
            bucketType = ""
            numberOfBuckets = -1
            layerID = -1
            layerName = ""
            return nil
        }
        name = json["name"].stringValue
        bucketType = json["bucket_type"].stringValue
        numberOfBuckets = Int(json["num_buckets"].stringValue) ?? 0
        layerName = json["layer_name"].stringValue
    }
}
