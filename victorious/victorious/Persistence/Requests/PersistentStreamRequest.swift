//
//  PersistentStreamRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension AuthenticationContext {
    init?( v_currentUser currentUser: VUser? ) {
        guard let currentUser = currentUser else {
            return nil
        }
        self.init( userID: Int64(currentUser.remoteId.integerValue), token: currentUser.token)
    }
}

extension RequestContext {
    init( v_environment environment: VEnvironment ) {
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

class PersistentStreamRequest {
    
    private let dataStore = BackgroundContextDataStore()
    private var request: StreamRequest
    
    init( request: StreamRequest ) {
        self.request = request
    }
    
    func execute( callback:((result: Stream?, error: ErrorType?)->())? ) {
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let authenticationContext =  AuthenticationContext(v_currentUser: VObjectManager.sharedManager().mainUser)
        let requestContext = RequestContext(v_environment: currentEnvironment)
        
        self.request.execute(
            baseURL: currentEnvironment.baseURL,
            requestContext: requestContext,
            authenticationContext: authenticationContext,
            callback: { (pageableResult, error) in
                guard let pageableResult = pageableResult else {
                    callback?( result: nil, error: error! )
                    return
                }
                
                let query: [String : AnyObject] = [ "apiPath" : self.request.apiPath ]
                let stream: VStream = self.dataStore.findOrCreateObject( query )
                stream.serialize( pageableResult.results, dataStore: self.dataStore )
                
                if let nextRequest = pageableResult.nextPage {
                    self.request = nextRequest
                }
                
                if self.dataStore.saveChanges() {
                    callback?( result: pageableResult.results, error: nil )
                }  else {
                    callback?( result: nil, error: PersistenceError.FailedToSave )
                }
        })
    }
}
