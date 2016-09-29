//
//  VModernLoginAndRegistrationFlowViewController.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VModernLoginAndRegistrationFlowViewController {
    func showFixedWebContent(_ type: FixedWebContentType) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: false, forceModal: true, isVIPOnly: false, title: type.title)
        router.navigate(to: DeeplinkDestination.externalURL(url: dependencyManager.urlForFixedWebContent(type) as URL, configuration: configuration), from: nil)
    }
}
