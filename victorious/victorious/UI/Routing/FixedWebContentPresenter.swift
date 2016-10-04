//
//  FixedWebContentPresenter.swift
//  victorious
//
//  Created by Vincent Ho on 9/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

protocol FixedWebContentPresenter {
    func showFixedWebContent(_ type: FixedWebContentType, withDependencyManager dependencyManager: VDependencyManager)
}

extension FixedWebContentPresenter where Self: UIViewController {
    func showFixedWebContent(_ type: FixedWebContentType, withDependencyManager dependencyManager: VDependencyManager) {
        guard let webContentDependencyManager = dependencyManager.fixedWebContentBackground else {
            return
        }
        
        let router = Router(originViewController: self, dependencyManager: webContentDependencyManager)
        let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: false, forceModal: true, isVIPOnly: false, title: type.title)
        
        router.navigate(to: DeeplinkDestination.externalURL(url: dependencyManager.urlForFixedWebContent(type) as URL, configuration: configuration), from: nil)
    }
}

private extension VDependencyManager {
    var fixedWebContentBackground: VDependencyManager? {
        return childDependency(forKey: "static.webcontent.background")
    }
}
