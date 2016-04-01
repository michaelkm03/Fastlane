//
//  VLoginType+Tracking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VLoginType {
    
    func trackSuccess(newUser: Bool) {
        switch self {
        case .Email:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithEmailDidSucceed)
        case .Facebook:
            if newUser {
                let params = [
                    VTrackingKeyPermissionName: VTrackingValueAuthorized,
                    VTrackingKeyPermissionState: VTrackingValueFacebookDidAllow
                ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserPermissionDidChange, parameters: params)
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventSignupWithFacebookDidSucceed)
            }
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithFacebookDidSucceed)
        case .Twitter:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithTwitterDidSucceed)
        default:()
        }
    }
    
    func trackFailure() {
        switch self {
        case .Email:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithEmailDidFail)
        case .Facebook:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithFacebookDidFail)
        case .Twitter:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithTwitterDidFailUnknown)
        default:
            return
        }
    }
}
