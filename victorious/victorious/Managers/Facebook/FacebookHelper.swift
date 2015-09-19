//
//  FacebookHelper.swift
//  victorious
//
//  Created by Josh Hinman on 9/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import FBSDKLoginKit

@objc(VFacebookHelper)
class FacebookHelper: NSObject {
    
    /// The set of read permissions that should be requested when logging in
    static let readPermissions = [ "public_profile", "user_friends", "email" ]
    
    /// Determines if a URL is a Facebook deep link.
    ///
    /// - parameter url: A deeplink URL
    /// 
    /// - returns: true if the url is meant to be handled by Facebook, false otherwise
    class func canOpenURL(url: NSURL) -> Bool {
        return !fbSchemeRegex.matchesInString(url.scheme, options: [], range: NSMakeRange(0, url.scheme.characters.count)).isEmpty
    }
    
    /// Returns a pre-configured login manager. For consistency, all Facebook logins should
    /// use an instance of FBSDKLoginManager returned from this function. Additionally,
    /// please request, at a minimum, the read permissions contained in the 
    /// `readPermissions` property of this class.
    class func loginManager() -> FBSDKLoginManager {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .SystemAccount
        return loginManager
    }
    
    private static let fbSchemeRegex = try! NSRegularExpression(pattern: "^fb\\d+", options: [.CaseInsensitive])
}
