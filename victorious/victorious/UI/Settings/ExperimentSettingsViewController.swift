//
//  ExperimentSettingsViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// This equality operator comapres to arrays of strings that are expected to contain integer text
/// such as "1" or "2".  It converts the strings to integers, sorts, then compares with the `Array`
/// type's default equality operator.
private func ==( lhs: [String], rhs: [String] ) -> Bool {
    if rhs.count == lhs.count {
        return false
    }
    return lhs.map({ $0.toInt()! }).sorted{ $0 < $1 } == rhs.map({ $0.toInt()! }).sorted{ $0 < $1 }
}

/// Simple table view controller that loads all available experiments from the server
/// and displays each one in a cell with a switch to allow the user to opt in or out
/// of the experiment.
class ExperimentSettingsViewController: UITableViewController {
    
    private var allAvailableExperiments = [Experiment]()
    
    private var defaultEnabledExperimentIds = [String]()
    private var userEnabledExperimentIds = [String]()
    
    enum State: Int {
        case Loading, Content, NoContent, Error
    }
    private var state: State = .Loading {
        didSet {
            println( "STATE = \(self.state)" )
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )
        
        self.loadSettings()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear( animated )
        
        self.saveSettings()
    }
    
    private func saveSettings() {
        // If the user selected experiments matches the default as defined on the server,
        // we don't want to supply any experimentIds to VObjectManager.  If we provide any experiment IDs,
        // even if they are the same as what the server has selected for the user, allowing experiment
        // participation to remain dynamic.
        if self.defaultEnabledExperimentIds == self.userEnabledExperimentIds {
            VObjectManager.sharedManager().experimentIDs = nil
        }
        else {
            VObjectManager.sharedManager().experimentIDs = self.userEnabledExperimentIds
        }
    }
    
    private func loadSettings() {
        self.state = .Loading
        
        VObjectManager.sharedManager().getDeviceExperiments(
            success: { (operation, result, results) -> Void in
                if let result = result as? [String: AnyObject] {
                    
                    // Get the enabled experiments as determined by the server without overriding
                    if let serverConfiguredExperimentIds = result[ "experiment_ids" ] as? [String] {
                        self.defaultEnabledExperimentIds = serverConfiguredExperimentIds
                    }
                    
                    // Get any overrides previosuly selected from this settings view
                    if let manuallyConfiguredExperimentIds = VObjectManager.sharedManager().experimentIDs as? [String] {
                        self.userEnabledExperimentIds = manuallyConfiguredExperimentIds
                    }
                    // But if there are none, use the defaults provided by the server
                    else {
                        self.userEnabledExperimentIds = self.defaultEnabledExperimentIds
                    }
                }
                
                if let allAvailableExperiments = results as? [Experiment] {
                    self.allAvailableExperiments = allAvailableExperiments
                }
                
                self.state = self.allAvailableExperiments.count > 0 ? .Content : .NoContent
            },
            failure: { (operation, error) -> Void in
                self.allAvailableExperiments = []
                self.state = .Error
            }
        )
    }
}

extension ExperimentSettingsViewController: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell( cell: VSettingsSwitchCell ) {
        if let indexPath = self.tableView.indexPathForCell( cell ) {
            let experiment = self.allAvailableExperiments[ indexPath.row ]
            if cell.value {
                self.userEnabledExperimentIds.append( experiment.id )
            }
            else {
                self.userEnabledExperimentIds = self.userEnabledExperimentIds.filter { $0 != experiment.id }
            }
        }
    }
}

extension ExperimentSettingsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = VSettingsSwitchCell.suggestedReuseIdentifier()
        if self.state == .Content, let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
        
            let experiment = self.allAvailableExperiments[ indexPath.row ]
            let enabled = contains( self.userEnabledExperimentIds, experiment.id )
            cell.setTitle( experiment.name, value: enabled )
            cell.delegate = self
            return cell
        }
        
        let noContentIdentifier = SettingsEmptyCell.defaultSwiftReuseIdentifier
        if let cell = tableView.dequeueReusableCellWithIdentifier( noContentIdentifier, forIndexPath: indexPath ) as? SettingsEmptyCell {
            switch self.state {
            case .Error:
                cell.message = "An error occured while loading the list of available experiments."
            case .NoContent:
                cell.message = "Unforunately, there are no available experiments right now."
            case .Loading:
                cell.message = "  Loading available experiments..."
            case .Content:
                fatalError( "This cell should not show when there is content." )
            }
            return cell
        }
            
        fatalError( "Could not load cell" )
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max( allAvailableExperiments.count, 1 )
    }
}