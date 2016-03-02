//
//  LightboxControllerOverflowMenuItem.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum LightboxControllerOverflowMenuItem {
    
    private struct Icon {
        
        //TODO: Replace with real icon names once assets are imported
        static let share = UIImage(named: "share")!
        static let report = UIImage(named: "library")!
        static let blockUser = UIImage(named: "gif")!
        static let promote = UIImage(named: "promote")!
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
