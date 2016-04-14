//
//  ListMenuSectionDataSource.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Discrete data source for a section within a List Menu component.
/// Mainly in charge of fetch data from backend, and notify its delegate
protocol ListMenuSectionDataSource {
    associatedtype SectionItem
    
    /// The delegate to be notified when data get updated
    var delegate: ListMenuSectionDataSourceDelegate { get }
    
    /// The visible items fetched from backend and should be displayed
    var visibleItems: [SectionItem] { get }
    
    /// Kick off a network request to fetch data and fill `visibleItems`
    func fetchRemoteData()
}

/// Conformers of this protocol respond to List Menu Data Sources data update events
protocol ListMenuSectionDataSourceDelegate {
    
    /// Called when List Menu Network Data Sources have finished fetching data
    /// from backend, and updated its `visibleItems`
    func didUpdateVisibleItems(forSection section: ListMenuSection)
}
