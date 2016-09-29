//
//  VLoginType+Tracking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VLoginType {
    
    func trackSuccess(_ newUser: Bool) {
        switch self {
        case .email:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithEmailDidSucceed)
        case .facebook:
            if newUser {
                let params = [
                    VTrackingKeyPermissionName: VTrackingValueAuthorized,
                    VTrackingKeyPermissionState: VTrackingValueFacebookDidAllow
                ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserPermissionDidChange, parameters: params)
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventSignupWithFacebookDidSucceed)
            }
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithFacebookDidSucceed)
        default:()
        }
    }
    
    func trackFailure() {
        switch self {
        case .email:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithEmailDidFail)
        case .facebook:
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventLoginWithFacebookDidFail)
        default:
            return
        }
    }
}
