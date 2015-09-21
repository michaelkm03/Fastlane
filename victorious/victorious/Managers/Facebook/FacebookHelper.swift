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
    
    /// - returns: true if a Facebook app ID is present in the app's Info.plist file.
    class func facebookAppIDPresent() -> Bool {
        if let facebookID = NSBundle(forClass: self).objectForInfoDictionaryKey("FacebookAppID") as? String {
            return facebookID != ""
        }
        return false
    }
    
    private static let fbSchemeRegex = try! NSRegularExpression(pattern: "^fb\\d+", options: [.CaseInsensitive])
}
