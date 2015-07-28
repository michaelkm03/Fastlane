//
//  ExperimentSettingsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 7/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// This equality operator comapres two arrays of strings that are expected to contain integer text
/// such as "1" or "2".  It converts the strings to integers, sorts, then compares with the `Array`
/// type's default equality operator.
private func ==( lhs: [String], rhs: [String] ) -> Bool {
    if rhs.count == lhs.count {
        return false
    }
    return lhs.map({ $0.toInt()! }).sorted{ $0 < $1 } == rhs.map({ $0.toInt()! }).sorted{ $0 < $1 }
}

/// Designed to provided an `ExperimentSettingsDataSource` instance with a reference to
/// the table view it's feeding so that it can reload it or get access to individual cells
/// that need updating based on changes in the data model
protocol ExperimentSettingsDataSourceDelegate {
    var tableView: UITableView! { get }
}

class ExperimentSettingsDataSource: NSObject {
    
    var delegate:ExperimentSettingsDataSourceDelegate?
    
    private enum State: Int {
        case Loading, Content, NoContent, Error
        
        /// Returns a message to display to the user for this state.
        /// Non-localized, as this is for testing purposes only.
        var message: String {
            switch self {
            case .Error:
                return "An error occured while loading the list of available experiments."
            case .NoContent:
                return "There are no experiments running right now."
            case .Loading:
                return "  Loading experiments..."
            default:
                return ""
            }
        }
    }
    
    struct Section {
        let title: String
        let experiments: [Experiment]
        
        func containsExperiment( experimentId: String ) -> Bool {
            return contains( self.experiments.map { $0.id }, experimentId )
        }
    }
    private var sections = [Section]()
    
    private var userEnabledExperimentIds = [String]()
    private var defaultEnabledExperimentIds = [String]()
    private var state: State = .Loading
    
    func saveSettings() {
        // If the user changed any settings from the default (the backend settings)...
        if self.defaultEnabledExperimentIds != self.userEnabledExperimentIds {
            
            // ...we should update the `experimentIDs` in `VObjectManager` to add the header
            // which actually changes experiment membership
            VObjectManager.sharedManager().experimentIDs = self.userEnabledExperimentIds
        }
        else {
            // Otherwise, set the `experimentIDs` back to nil so that the header is not added
            // and the backend's experiment membership settings are applied as normal
            VObjectManager.sharedManager().experimentIDs = nil
        }
    }
    
    func updateData( #deafultExperimentIds: [String], allExperiments: [Experiment] ) {
        
        // Get the enabled experiments as determined by the server
        self.defaultEnabledExperimentIds = deafultExperimentIds
        
        // Get any user enabled experiment IDs previosuly selected from this settings view
        // Or just use the defaults provided by the server if there are none
        self.userEnabledExperimentIds = VObjectManager.sharedManager().experimentIDs as? [String] ?? self.defaultEnabledExperimentIds
        
        // Create sections to be shown in the table view based on the data
        let layers = Set<String>( map( allExperiments, { $0.layerName }) )
        for layer in layers {
            let experiments = filter(allExperiments, { $0.layerName == layer })
            self.sections.append( Section(title: layer, experiments: experiments) )
        }
    }
    
    func loadSettings() {
        self.state = .Loading
        
        VObjectManager.sharedManager().getDeviceExperiments(
            success: { (operation, result, results) -> Void in
                if let result = result as? [String: AnyObject],
                    let experimentIdsFromResponse = result[ "experiment_ids" ] as? [String] {
                        let experiments = results as? [Experiment] ?? [Experiment]()
                        self.updateData( deafultExperimentIds: [ "2", "5" ], allExperiments: experiments )
                }
                
                self.state = self.sections.count > 0 ? .Content : .NoContent
                self.delegate?.tableView.reloadData()
            },
            failure: { (operation, error) -> Void in
                self.sections = []
                self.state = .Error
            }
        )
    }
}

extension ExperimentSettingsDataSource: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = VSettingsSwitchCell.suggestedReuseIdentifier()
        if self.state == .Content, let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
            
            let experiment = self.sections[ indexPath.section ].experiments[ indexPath.row ]
            let enabled = contains( self.userEnabledExperimentIds, experiment.id )
            cell.setTitle( experiment.name, value: enabled )
            cell.delegate = self
            return cell
        }
        
        let noContentIdentifier = SettingsEmptyCell.defaultSwiftReuseIdentifier
        if let cell = tableView.dequeueReusableCellWithIdentifier( noContentIdentifier, forIndexPath: indexPath ) as? SettingsEmptyCell {
            cell.message = self.state.message
            return cell
        }
        
        fatalError( "Could not load cell" )
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max( self.sections[ section ].experiments.count, 1 )
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[ section ].title
    }
}

extension ExperimentSettingsDataSource: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell( cell: VSettingsSwitchCell ) {
        if let indexPath = self.delegate?.tableView.indexPathForCell( cell ) {
            
            let section = self.sections[ indexPath.section ]
            let experiment = section.experiments[ indexPath.row ]
            
            // Update our data model
            self.userEnabledExperimentIds.append( experiment.id )
            self.userEnabledExperimentIds = self.userEnabledExperimentIds.filter {
                // Keep only experiment IDs that are not in this section or the experiment ID we just selected.
                // In other words, make sure only one experiment per section is selected.
                return !section.containsExperiment( $0 ) || $0 == experiment.id
            }
            
            // Update values only on visible cells that need updating
            for i in 0..<section.experiments.count {
                let otherCellIndexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
                if let cell = self.delegate?.tableView.cellForRowAtIndexPath( otherCellIndexPath ) as? VSettingsSwitchCell where otherCellIndexPath != indexPath {
                    cell.setValue(false, animated: true)
                }
            }
        }
    }
}
