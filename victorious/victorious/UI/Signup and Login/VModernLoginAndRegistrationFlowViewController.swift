//
//  VModernLoginAndRegistrationFlowViewController.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VModernLoginAndRegistrationFlowViewController: FixedWebContentPresenter {
    func showFixedWebContent(_ type: FixedWebContentType) {
        showFixedWebContent(type, withDependencyManager: dependencyManager)
    }
}
