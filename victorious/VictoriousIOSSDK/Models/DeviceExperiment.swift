//
//  DeviceExperiment.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// DeviceExperiment is a simple networking struct that is quickly converted from JSON.
public struct DeviceExperiment {
    
    /// The server provided ID for this experiment. Should be globally unique.
    public let id: Int64
    
    /// The name of this Experiment. Internally visible (in settings) user string to describe the experiment.
    public let name: String
    
    /// The name of the containing experiment bucket. Internally visible (in settings) user string to describe the experiment.
    public let bucketType: String
    
    ///
    public let numberOfBuckets: Int64
    
    /// The ID of the layer that this experiment will be contained in. Note: only 1 experiment may be activated per a layer.
    public let layerID: Int64
    
    /// The name of the layer this experiment is contained in. Note: only 1 experiment may be activated per a layer.
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
