//
//  VObjectManager+Interstitials.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension VObjectManager {
    
    /// Marks an interstitial as seen, which should remove it from any firther response payloads.
    ///
    /// - parameter remoteID: The ID of the interstitial to be marked as seen.
    /// - parameter success: Closure to be called if server does not return an error.
    /// - parameter failure: Closure to be called if server returns an error.
    func markInterstitialAsSeen( remoteID: Int, success: VSuccessBlock?, failure: VFailBlock? ) -> RKManagedObjectRequestOperation? {
        return self.POST( "/api/alert/acknowledge",
            object: nil,
            parameters: ["alert_id" : remoteID],
            successBlock: success,
            failBlock: failure)
    }
    
    /// Registers a test alert for the current user.
    ///
    /// - parameter params: A parameter dictionary representing the alert.
    /// - parameter success: Closure to be called if server does not return an error.
    /// - parameter failure: Closure to be called if server returns an error.
    func registerTestAlert( params: [String : AnyObject], success: VSuccessBlock?, failure: VFailBlock? ) -> RKManagedObjectRequestOperation? {
        
        if let paramsInfo = params["params"] as? [String : AnyObject], type = params["type"] as? String {
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramsInfo, options: [])
            let paramsString = String(data: jsonData, encoding: NSUTF8StringEncoding)
            
            let formattedParams = ["type" : type, "params" : paramsString!]
            
            return self.POST( "/api/alert/create",
                object: nil,
                parameters:formattedParams,
                successBlock: success,
                failBlock: failure)
        }
        
        return nil
    }
}
