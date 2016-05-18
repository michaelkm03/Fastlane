//
//  TutorialNetworkDataSource.swift
//  victorious
//
//  Created by Tian Lan on 5/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers can respond to the results fetched by this network data source
protocol TutorialNetworkDataSourceDelegate: class {
    func didUpdateVisibleItems(from oldValue: [DisplayableChatMessage], to newValue: [DisplayableChatMessage])
    func didFinishFetchingAllItems()
}

class TutorialNetworkDataSource: NSObject, NetworkDataSource {
    private(set) var visibleItems: [DisplayableChatMessage] = [] {
        didSet {
            delegate?.didUpdateVisibleItems(from: oldValue, to: visibleItems)
        }
    }
    
    private var queuedTutorialMessages: [DisplayableChatMessage] = []
    
    private var timerManager: VTimerManager? = nil
    
    weak var delegate: TutorialNetworkDataSourceDelegate?
    
    private let dependencyManager: VDependencyManager
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        
        super.init()

        guard let urlString = dependencyManager.tutorialContentsEndpoint else {
            delegate?.didFinishFetchingAllItems()
            return
        }
        
        let operation = TutorialContentsRemoteOperation(urlString: urlString)
        operation.queue { [weak self] results, error, cancelled in
            self?.queuedTutorialMessages = results?.flatMap { $0 as? ViewedContent } ?? []
            
            self?.timerManager = VTimerManager.scheduledTimerManagerWithTimeInterval(3.0, target: self, selector: #selector(self?.dequeueTutorialMessage), userInfo: nil, repeats: true)
        }
    }

    @objc private func dequeueTutorialMessage() {
        if !queuedTutorialMessages.isEmpty {
            let newMessageToDisplay = queuedTutorialMessages.removeFirst()
            visibleItems.append(newMessageToDisplay)
        } else {
            timerManager?.invalidate()
            delegate?.didFinishFetchingAllItems()
        }
    }
}

private extension VDependencyManager {
    var tutorialContentsEndpoint: String? {
        return stringForKey("tutorialMessagesEndpoint")
    }
}
