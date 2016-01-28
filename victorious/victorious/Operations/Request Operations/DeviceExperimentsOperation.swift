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
    
    private let request = DeviceExperimentsRequest()
    
    private(set) var defaultExperimentIDs: Set<Int> = []
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( result: (experiments: [DeviceExperiment], defaultExperimentIDs: [Int]), completion:() -> () ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            for experiment in result.experiments {
                let uniqueElements = [ "id" : experiment.id, "layerId" : experiment.layerID ]
                let persistentExperiment: Experiment = context.v_findOrCreateObject(uniqueElements)
                persistentExperiment.populate(fromSourceModel: experiment)
                context.v_save()
            }
            // Convert to Set<Int>
            for defaultID in result.defaultExperimentIDs {
                self.defaultExperimentIDs.insert(Int(defaultID))
            }

            completion()
        }
    }
}
