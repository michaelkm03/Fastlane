//
//  VObjectManager+Experiments.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension VObjectManager {
    
    func getDeviceExperiments( #success: VSuccessBlock, failure: VFailBlock ) -> RKManagedObjectRequestOperation? {
        let params = [ "" : "" ]
        return self.GET( "/api/device/experiments",
            object: nil,
            parameters: params,
            successBlock: success,
            failBlock: failure )
    }
    
    func setDeviceExperiments( #success: VSuccessBlock, failure: VFailBlock ) -> RKManagedObjectRequestOperation? {
        let params = [ "" : "" ]
        return self.POST( "/api/device/experiments",
            object: nil,
            parameters: params,
            successBlock: success,
            failBlock: failure )
    }
}