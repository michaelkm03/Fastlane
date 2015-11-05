//
//  VObjectManager+ExecuteRequest.swift
//  victorious
//
//  Created by Josh Hinman on 10/27/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VObjectManager {
    func executeRequest<R: RequestType>(request: R, callback: ((result: R.ResultType?, error: ErrorType?) -> ())?) -> Cancelable {
        
        let environment = VEnvironmentManager.sharedInstance().currentEnvironment
        return request.execute(baseURL: environment.baseURL, requestContext: RequestContext(environment: environment), authenticationContext: nil, callback: callback)
    }
}

extension RequestContext {
    private init(environment: VEnvironment) {
        
        let deviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? ""
        let buildNumber: String
        
        if let buildNumberFromBundle = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            buildNumber = buildNumberFromBundle
        } else {
            buildNumber = ""
        }
        self.init(appID: environment.appID.integerValue, deviceID: deviceID, buildNumber: buildNumber)
    }
}
