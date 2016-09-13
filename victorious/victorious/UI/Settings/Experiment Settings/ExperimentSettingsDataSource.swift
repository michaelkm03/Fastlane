//
//  ExperimentSettingsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 7/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousCommon

/// Designed to provided an `ExperimentSettingsDataSource` instance with a reference to
/// the table view it's feeding so that it can reload it or get access to individual cells
/// that need updating based on changes in the data model
protocol ExperimentSettingsDataSourceDelegate: class {
    var tableView: UITableView! { get }
    var dependencyManager: VDependencyManager? { get }
}

class ExperimentSettingsDataSource: NSObject {
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    weak var delegate: ExperimentSettingsDataSourceDelegate?
    
    struct TintColor {
        static let unmodified = UIColor.grayColor()
        static let modified = UIColor.redColor()
        var current = TintColor.unmodified
    }
    private var tintColor = TintColor()
    
    var selectedExperimentIds: Set<Int> {
        return Set<Int>( self.sections.flatMap { $0.experiments.filter { $0.isEnabled.boolValue }.map { $0.id.integerValue } } )
    }
    
    let experimentSettings = ExperimentSettings()
    
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
    }
    private var sections = [Section]()
    private var state: State = .Loading
    
    func saveSettings() {
        self.experimentSettings.activeExperiments = self.selectedExperimentIds
    }
    
    func resetSettings() {
        self.experimentSettings.reset()
    }
    
    func loadSettings() {
        self.sections = []
        self.state = .Loading
        self.delegate?.tableView.reloadData()
        
        RequestOperation(request: DeviceExperimentsRequest()).queue { result in
            switch result {
                case .success(let deviceExperiments, let defaultExperimentIDs):
                    self.persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
                        for experiment in deviceExperiments {
                            let uniqueElements = [ "id": experiment.id, "layerId": experiment.layerID ]
                            let persistentExperiment: Experiment = context.v_findOrCreateObject(uniqueElements)
                            persistentExperiment.populate(fromSourceModel: experiment)
                            context.v_save()
                        }
                    }
                
                    // Synchronously grab all experiments from the main queue context.
                    let experiments: [Experiment] = self.persistentStore.mainContext.v_performBlockAndWait() { context in
                        return context.v_findAllObjects()
                    }
                    
                    // If we have (internal) user configured experiments use those, otherwise use defaults returned from the operation.
                    let activeExperiments = self.experimentSettings.activeExperiments ?? defaultExperimentIDs
                    for experiment in experiments {
                        experiment.isEnabled = activeExperiments.contains( experiment.id.integerValue )
                    }

                    self.updateTintColor()
                    
                    let layers = Set<String>( experiments.map { $0.layerName } )
                    for layer in layers {
                        let experimentsInLayer = experiments.filter { $0.layerName == layer }
                        self.sections.append( Section(title: layer, experiments: experimentsInLayer) )
                    }
                    
                    self.state = self.sections.count > 0 ? .Content : .NoContent
                    self.delegate?.tableView.reloadData()
                
                case .failure(_), .cancelled:
                    self.sections = []
                    self.state = .Error
            }
        }
    }
    
    private func updateTintColor() {
        self.tintColor.current = self.experimentSettings.activeExperiments != nil ? TintColor.modified : TintColor.unmodified
    }
    
    private func updateVisibleCells() {
        if let tableView = self.delegate?.tableView {
            for cell in tableView.visibleCells {
                if let switchCell = cell as? VSettingsSwitchCell {
                    switchCell.switchColor = self.tintColor.current
                    if let indexPath = tableView.indexPathForCell( switchCell ) {
                        let experiment = self.sections[ indexPath.section ].experiments[ indexPath.row ]
                        let nameWithID = "\(experiment.name) (\(experiment.id))"
                        switchCell.setTitle( nameWithID, value: experiment.isEnabled.boolValue )
                    }
                }
            }
        }
    }
}

extension ExperimentSettingsDataSource: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell(cell: VSettingsSwitchCell, newValue: Bool, key: String) {
        if let indexPath = self.delegate?.tableView.indexPathForCell( cell ) {
            
            let section = self.sections[ indexPath.section ]
            let selectedExperiment = section.experiments[ indexPath.row ]
            for experiment in section.experiments {
                experiment.isEnabled = selectedExperiment == experiment ? cell.value : false
            }
            self.saveSettings()
            
            // Update values only on visible cells that need updating
            for i in 0..<section.experiments.count {
                let otherCellIndexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
                if otherCellIndexPath != indexPath,
                    let cell = self.delegate?.tableView.cellForRowAtIndexPath( otherCellIndexPath ) as? VSettingsSwitchCell {
                        cell.setValue(false, animated: true)
                }
            }
            
            self.updateTintColor()
            self.updateVisibleCells()
        }
    }
}

extension ExperimentSettingsDataSource: SettingsButtonCellDelegate {
    
    func buttonPressed( button: UIButton ) {
        self.resetSettings()
        self.loadSettings()
    }
}

extension ExperimentSettingsDataSource: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let noContentIdentifier = SettingsEmptyCell.defaultReuseIdentifier
        if self.state != .Content,
            let cell = tableView.dequeueReusableCellWithIdentifier( noContentIdentifier, forIndexPath: indexPath ) as? SettingsEmptyCell {
                cell.message = self.state.message
                return cell
        }
        
        let buttonCellIdentifier = SettingsButtonCell.defaultReuseIdentifier
        if self.state == .Content && indexPath.section == tableView.lastSection(),
            let cell = tableView.dequeueReusableCellWithIdentifier( buttonCellIdentifier, forIndexPath: indexPath ) as? SettingsButtonCell {
                if let button = cell.button as? VButton,
                    let color = self.delegate?.dependencyManager?.colorForKey( VDependencyManagerLinkColorKey ),
                    let font = self.delegate?.dependencyManager?.fontForKey( VDependencyManagerHeaderFontKey ) {
                        button.primaryColor = color
                        button.titleLabel?.font = font
                        button.style = .Primary
                }
                cell.delegate = self
                return cell
        }
        
        let identifier = VSettingsSwitchCell.suggestedReuseIdentifier()
        if self.state == .Content,
            let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
                let experiment = self.sections[ indexPath.section ].experiments[ indexPath.row ]
                let nameWithID = "\(experiment.name) (\(experiment.id))"
                cell.setTitle( nameWithID, value: experiment.isEnabled.boolValue )
                cell.delegate = self
                cell.switchColor = self.tintColor.current
                return cell
        }
        
        fatalError( "Could not load cell" )
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .Content where section != tableView.lastSection():
            return self.sections[ section ].experiments.count
        default:
            return 1 // No content/loading cell
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch state {
        case .Content:
            return self.sections.count + 1 // Reset button
        default:
            return 1 // No content/loading cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch state {
        case .Content where section != tableView.lastSection():
            return self.sections[ section ].title
        default:
            return ""
        }
    }
}

private extension UITableView {
    func lastSection() -> Int {
        return max( 0, self.numberOfSections - 1)
    }
}
