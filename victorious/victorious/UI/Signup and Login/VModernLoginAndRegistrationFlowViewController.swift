//
//  VModernLoginAndRegistrationFlowViewController.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VModernLoginAndRegistrationFlowViewController {
    func showFixedWebContent(type: FixedWebContentType) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        router.navigate(to: DeeplinkDestination.externalURL(url: dependencyManager.urlForFixedWebContent(type), addressBarVisible: false, isVIPOnly: false, title: type.title))
    }
}