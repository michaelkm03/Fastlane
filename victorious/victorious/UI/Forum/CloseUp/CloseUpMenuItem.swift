//
//  CloseUpMenuItem.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum CloseUpMenuItem {
    
    fileprivate struct Icon {
        
        static let share: UIImage! = nil
        static let report: UIImage! = nil
        static let blockUser: UIImage! = nil
        static let promote: UIImage! = nil
    }
    
    case share, report, blockUser, promote
    
    func associatedIcon() -> UIImage {
        switch self {
        case .share:
            return Icon.share
        case .report:
            return Icon.report
        case .blockUser:
            return Icon.blockUser
        case .promote:
            return Icon.promote
        }
    }
}
