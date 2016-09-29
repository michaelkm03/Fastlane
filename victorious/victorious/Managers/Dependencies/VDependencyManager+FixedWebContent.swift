//
//  VDependencyManager+FixedWebContent.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc enum FixedWebContentType : Int {
    case privacyPolicy
    case helpCenter
    case termsOfService
    
    var title: String {
        switch self {
        case .privacyPolicy: return NSLocalizedString("Privacy Policy", comment: "")
        case .helpCenter: return NSLocalizedString("Help", comment: "")
        case .termsOfService: return NSLocalizedString("Terms of Service", comment: "")
        }
    }
    
    var templateURLKey: String {
        switch self {
        case .privacyPolicy: return "privacyURL"
        case .helpCenter: return "helpCenterURL"
        case .termsOfService: return "tosURL"
        }
    }
}

extension VDependencyManager {
    func urlForFixedWebContent(_ type: FixedWebContentType) -> NSURL {
        return NSURL(string: string(forKey: type.templateURLKey)) ?? NSURL()
    }
}
