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
}
