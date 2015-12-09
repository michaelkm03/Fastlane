//
//  DeviceExperimentsOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DeviceExperimentsOperation: RequestOperation {
    
    let request = DeviceExperimentsRequest()
    private(set) var defaultExperimentIDs: Set<Int> = []
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( result: (experiments: [DeviceExperiment], defaultExperimentIDs: [Int64]), completion:() -> () ) {
        
        persistentStore.asyncFromBackground(){ context in
            for experiment in result.experiments {
                let persistentExperiment: Experiment = context.findOrCreateObject(["id": NSNumber(longLong: experiment.id),
                    "layerId": NSNumber(longLong: experiment.layerID)])
                persistentExperiment.populate(fromSourceModel: experiment)
                context.saveChanges()
            }
            for defaultID in result.defaultExperimentIDs {
                self.defaultExperimentIDs.insert(Int(defaultID))
            }

            completion()
        }
    }
    
}
