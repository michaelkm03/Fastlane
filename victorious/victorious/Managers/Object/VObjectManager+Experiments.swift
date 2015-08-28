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
            
            let defaultExperimentIds = Set<Int>( result?[ "experiment_ids" ] as? [Int] ?? [Int]() )
            let experiments = resultObjects as? [Experiment] ?? [Experiment]()
            
            success( experiments: experiments, defaultExperimentIds: defaultExperimentIds )
        }
        
        return self.GET( "/api/device/experiments",
            object: nil,
            parameters: nil,
            successBlock: fullSuccess,
            failBlock: failure )
    }
}