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
    public let id: Int64
    public let name: String
    public let bucketType: String
    public let numberOfBuckets: Int64
    public let layerID: Int64
    public let layerName: String
}

extension DeviceExperiment {
    public init?(json: JSON) {
        if let experimentID = Int64(json["id"].stringValue), let layerID = Int64(json["layer_id"].stringValue) {
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
        numberOfBuckets = Int64(json["num_buckets"].stringValue) ?? 0
        layerName = json["layer_name"].stringValue
    }
}
