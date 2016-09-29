//
//  dsa.swift
//  victorious
//
//  Created by Patrick Lynch on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

extension RequestContext {
    
    init( environment: VEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment ) {
        let deviceID = UIDevice.current.v_authorizationDeviceID
        let firstInstallDeviceID = FirstInstallManager().generateFirstInstallDeviceID() ?? deviceID
        let sessionID = VRootViewController.shared()?.sessionTimer.sessionID
        let buildNumber: String
        let version: String
        
        if let buildNumberFromBundle = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            buildNumber = buildNumberFromBundle
        } else {
            buildNumber = ""
        }
        if let versionFromBundle = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            version = versionFromBundle
        } else {
            version = ""
        }
        
        self.init(appID: environment.appID.intValue, deviceID: deviceID, firstInstallDeviceID: firstInstallDeviceID, buildNumber: buildNumber, appVersion: version, experimentIDs: ExperimentSettings().activeExperiments ?? [], sessionID: sessionID)
    }
}
