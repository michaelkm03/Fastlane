//
//  FacebookHelper.swift
//  victorious
//
//  Created by Josh Hinman on 9/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import FBSDKLoginKit
import FBSDKShareKit

class FacebookHelper: NSObject {
    
    /// The set of read permissions that should be requested when logging in
    static let readPermissions = ["public_profile", "user_friends", "email"]
    
    /// Determines if a URL is a Facebook deep link.
    ///
    /// - parameter url: A deeplink URL
    /// 
    /// - returns: true if the url is meant to be handled by Facebook, false otherwise
    class func canOpenURL(_ url: NSURL) -> Bool {
        guard let urlScheme = url.scheme else {
            return false
        }

        return !fbSchemeRegex.matches(in: urlScheme, options: [], range: NSMakeRange(0, urlScheme.characters.count)).isEmpty
    }
    
    /// - returns: true if a Facebook app ID is present in the app's Info.plist file.
    class func facebookAppIDPresent() -> Bool {
        if let facebookID = Bundle(for: self).objectForInfoDictionaryKey("FacebookAppID") as? String {
            return facebookID != ""
        }
        return false
    }
    
    /// Create and return an instance of FBSDKShareDialog with a correct mode set.
    ///
    /// - parameter content: The content to be shared
    /// - parameter mode: A mode to use. If this mode is unavailable, the object will be returned with FBSDKShareDialogModeAutomatic set.
    class func shareDialog( content shareContent: FBSDKSharingContent, mode: FBSDKShareDialogMode = .automatic ) -> FBSDKSharingDialog {
        
        let shareDialog = FBSDKShareDialog()
        shareDialog.shareContent = shareContent
        shareDialog.mode = mode
        
        if !shareDialog.canShow() {
            // if the mode that's been selected isn't avaliable, setting it to automatic should let the SDK choose a mode that will work.
            shareDialog.mode = .automatic
        }
        return shareDialog
    }
    
    fileprivate static let fbSchemeRegex = try! NSRegularExpression(pattern: "^fb\\d+", options: [.caseInsensitive])
}
