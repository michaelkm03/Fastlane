//
//  VObjectManager+Experiments.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension VObjectManager {
    
    /// Loads all available experiments from the backend as `Experiment`
    ///
    /// :param: success Closure to be called if server does not return an error.
    /// :param: failure Closure to be called if server returns an error.
    func getDeviceExperiments( #success: VSuccessBlock, failure: VFailBlock ) -> RKManagedObjectRequestOperation? {
        
        return self.GET( "/api/device/experiments",
            object: nil,
            parameters: nil,
            successBlock: success,
            failBlock: failure )
    }
}