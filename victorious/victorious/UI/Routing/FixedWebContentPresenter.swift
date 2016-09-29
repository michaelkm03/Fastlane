//
//  FixedWebContentPresenter.swift
//  victorious
//
//  Created by Vincent Ho on 9/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol FixedWebContentPresenter {
    func showFixedWebContent(type: FixedWebContentType, withDependencyManager dependencyManager: VDependencyManager)
}

extension FixedWebContentPresenter where Self: UIViewController {
    func showFixedWebContent(type: FixedWebContentType, withDependencyManager dependencyManager: VDependencyManager) {
        guard let webContentDependencyManager = dependencyManager.childDependencyForKey("webContentBackground") else {
            return
        }
        
        let router = Router(originViewController: self, dependencyManager: webContentDependencyManager)
        let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: false, forceModal: true, isVIPOnly: false, title: type.title)
        router.navigate(to: DeeplinkDestination.externalURL(url: dependencyManager.urlForFixedWebContent(type), configuration: configuration), from: nil)
    }
}
