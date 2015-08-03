//
//  VObjectManager+Experiments.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension VObjectManager {
    
    typealias ExperimentSuccess = (experiments:[Experiment], defaultExperimentIds: Set<Int>) -> ()
    
    /// Loads all available experiments from the backend as `Experiment`
    ///
    /// :param: success Closure to be called if server does not return an error.
    /// :param: failure Closure to be called if server returns an error.
    func getDeviceExperiments( #success: ExperimentSuccess, failure: VFailBlock ) -> RKManagedObjectRequestOperation? {
        
        let fullSuccess: VSuccessBlock = { (operation, result, resultObjects) in
            
            // WARNING: This is sample code, delete when done testing
            var hardcodedExperiments = [Experiment]()
            let sampleData = [
                "exp0" : "layer1",
                "exp1" : "layer1",
                "exp2" : "layer1",
                
                "exp3" : "layer2",
                "exp4" : "layer2",
                "exp5" : "layer2" ]
            var i = 0
            for (name, layer) in sampleData {
                if let experiment = VObjectManager.sharedManager().objectWithEntityName( Experiment.v_defaultEntityName, subclass: Experiment.self ) as? Experiment {
                    experiment.name = name
                    experiment.layerName = layer
                    experiment.id = NSNumber(integer: 100 + i++)
                    hardcodedExperiments.append( experiment )
                }
            }
            
            let defaultExperimentIds = Set<Int>([101, 102]) //Set<Int>( result?[ "experiment_ids" ] as? [Int] ?? [Int]() )
            var experiments = hardcodedExperiments //resultObjects as? [Experiment] ?? [Experiment]()
            
            success( experiments: experiments, defaultExperimentIds: defaultExperimentIds )
        }
        
        return self.GET( "/api/device/experiments",
            object: nil,
            parameters: nil,
            successBlock: fullSuccess,
            failBlock: failure )
    }
}