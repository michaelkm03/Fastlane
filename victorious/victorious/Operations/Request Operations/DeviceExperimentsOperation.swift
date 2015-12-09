//
//  DeviceExperimentsOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Encapsulates requesting and persisting hte results of a request for the current device's experiments.
/// By the time the completion block has been called for this operation the results will have been parsed 
/// and peristed to the parent background context.
class DeviceExperimentsOperation: RequestOperation {
    
    private let request = DeviceExperimentsRequest()
    
    /// Calling code can read the default experiments IDs from this property.
    private(set) var defaultExperimentIDs: Set<Int> = []
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( result: (experiments: [DeviceExperiment], defaultExperimentIDs: [Int64]), completion:() -> () ) {
        
        /// Persist to Core Data in the background
        persistentStore.asyncFromBackground(){ context in
            for experiment in result.experiments {
                let persistentExperiment: Experiment = context.findOrCreateObject(["id": NSNumber(longLong: experiment.id),
                    "layerId": NSNumber(longLong: experiment.layerID)])
                persistentExperiment.populate(fromSourceModel: experiment)
                context.saveChanges()
            }
            // Convert to Set<Int>
            for defaultID in result.defaultExperimentIDs {
                self.defaultExperimentIDs.insert(Int(defaultID))
            }

            completion()
        }
    }
}
