//
//  LightboxMenuItem.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum LightboxMenuItem {
    
    private struct Icon {
        
        static let share: UIImage! = nil
        static let report: UIImage! = nil
        static let blockUser: UIImage! = nil
        static let promote: UIImage! = nil
    }
    
    case Share, Report, BlockUser, Promote
    
    func associatedIcon() -> UIImage {
        switch self {
        case .Share:
            return Icon.share
        case .Report:
            return Icon.report
        case .BlockUser:
            return Icon.blockUser
        case .Promote:
            return Icon.promote
        }
    }
}
