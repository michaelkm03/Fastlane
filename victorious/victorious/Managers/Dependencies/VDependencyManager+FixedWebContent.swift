//
//  VDependencyManager+FixedWebContent.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc enum FixedWebContentType : Int {
    case PrivacyPolicy
    case HelpCenter
    case TermsOfService
    
    var title: String {
        switch self {
        case .PrivacyPolicy: return NSLocalizedString("Privacy Policy", comment: "")
        case .HelpCenter: return NSLocalizedString("Help", comment: "")
        case .TermsOfService: return NSLocalizedString("Terms of Service", comment: "")
        }
    }
    
    var templateURLKey: String {
        switch self {
        case .PrivacyPolicy: return "privacyURL"
        case .HelpCenter: return "helpCenterURL"
        case .TermsOfService: return "tosURL"
        }
    }
}

extension VDependencyManager {
    func urlForFixedWebContent(type: FixedWebContentType) -> NSURL {
        return NSURL(string: stringForKey(type.templateURLKey)) ?? NSURL()
    }
}
