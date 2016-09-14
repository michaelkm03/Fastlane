//
//  DeviceExperiment.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct DeviceExperiment {
    public var id: Int
    public var name: String
    public var bucketType: String
    public var numberOfBuckets: Int
    public var layerID: Int
    public var layerName: String
    public var isEnabled: Bool
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
        isEnabled = false
    }
}
