//
//  UIViewController+CoachmarkContainer.swift
//  victorious
//
//  Created by Darvish Kamalia on 7/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension UIViewController {
    var coachmarkContainerView : UIView {
        return navigationController?.view ?? self.view
    }
}