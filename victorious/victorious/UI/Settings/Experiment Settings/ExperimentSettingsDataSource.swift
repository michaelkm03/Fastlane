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
    
    weak var delegate: ExperimentSettingsDataSourceDelegate?
    
    struct TintColor {
        static let unmodified = UIColor.gray
        static let modified = UIColor.red
        var current = TintColor.unmodified
    }
    fileprivate var tintColor = TintColor()
    
    var selectedExperimentIds: Set<Int> {
        return Set(sections.flatMap {
            $0.experiments.filter { $0.isEnabled }.map { $0.id }
        })
    }
    
    let experimentSettings = ExperimentSettings()
    
    fileprivate enum State: Int {
        case loading, content, noContent, error
        
        /// Returns a message to display to the user for this state.
        /// Non-localized, as this is for testing purposes only.
        var message: String {
            switch self {
            case .error:
                return "An error occured while loading the list of available experiments."
            case .noContent:
                return "There are no experiments running right now."
            case .loading:
                return "  Loading experiments..."
            default:
                return ""
            }
        }
    }
    
    struct Section {
        var title: String
        var experiments: [DeviceExperiment]
    }
    
    fileprivate var sections = [Section]()
    fileprivate var state: State = .loading
    
    func saveSettings() {
        self.experimentSettings.activeExperiments = self.selectedExperimentIds
    }
    
    func resetSettings() {
        self.experimentSettings.reset()
    }
    
    func loadSettings() {
        self.sections = []
        self.state = .loading
        self.delegate?.tableView.reloadData()
        
        RequestOperation(request: DeviceExperimentsRequest()).queue { result in
            switch result {
                case .success(let experiments, let defaultExperimentIDs):
                    let activeExperimentIDs = self.experimentSettings.activeExperiments ?? defaultExperimentIDs
                    
                    self.updateTintColor()
                    
                    let layers = Set<String>(experiments.map { $0.layerName })
                    
                    for layer in layers {
                        let experimentsInLayer: [DeviceExperiment] = experiments.filter { $0.layerName == layer }.map { experiment in
                            var experiment = experiment
                            experiment.isEnabled = activeExperimentIDs.contains(experiment.id)
                            return experiment
                        }
                        
                        self.sections.append(Section(title: layer, experiments: experimentsInLayer))
                    }
                    
                    self.state = self.sections.count > 0 ? .Content : .NoContent
                    self.delegate?.tableView.reloadData()
                
                case .failure(_), .cancelled:
                    self.sections = []
                    self.state = .Error
            }
        }
    }
    
    fileprivate func updateTintColor() {
        self.tintColor.current = self.experimentSettings.activeExperiments != nil ? TintColor.modified : TintColor.unmodified
    }
    
    fileprivate func updateVisibleCells() {
        if let tableView = self.delegate?.tableView {
            for cell in tableView.visibleCells {
                if let switchCell = cell as? VSettingsSwitchCell {
                    switchCell.switchColor = self.tintColor.current
                    if let indexPath = tableView.indexPathForCell( switchCell ) {
                        let experiment = self.sections[ indexPath.section ].experiments[ indexPath.row ]
                        let nameWithID = "\(experiment.name) (\(experiment.id))"
                        switchCell.setTitle(nameWithID, value: experiment.isEnabled)
                    }
                }
            }
        }
    }
}

extension ExperimentSettingsDataSource: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell(_ cell: VSettingsSwitchCell, newValue: Bool, key: String) {
        if let indexPath = delegate?.tableView.indexPathForCell(cell) {
            sections[indexPath.section].experiments[indexPath.row].isEnabled = newValue
            
            saveSettings()
            
            // Update values only on visible cells that need updating
            for index in sections[indexPath.section].experiments.indices {
                let otherCellIndexPath = NSIndexPath(forRow: index, inSection: indexPath.section)
                
                if
                    otherCellIndexPath != indexPath,
                    let cell = delegate?.tableView.cellForRowAtIndexPath(otherCellIndexPath) as? VSettingsSwitchCell
                {
                    cell.setValue(false, animated: true)
                }
            }
            
            updateTintColor()
            updateVisibleCells()
        }
    }
}

extension ExperimentSettingsDataSource: SettingsButtonCellDelegate {
    
    func buttonPressed( _ button: UIButton ) {
        self.resetSettings()
        self.loadSettings()
    }
}

extension ExperimentSettingsDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let noContentIdentifier = SettingsEmptyCell.defaultReuseIdentifier
        if self.state != .content,
            let cell = tableView.dequeueReusableCell( withIdentifier: noContentIdentifier, for: indexPath ) as? SettingsEmptyCell {
                cell.message = self.state.message
                return cell
        }
        
        let buttonCellIdentifier = SettingsButtonCell.defaultReuseIdentifier
        if self.state == .content && (indexPath as NSIndexPath).section == tableView.lastSection(),
            let cell = tableView.dequeueReusableCell( withIdentifier: buttonCellIdentifier, for: indexPath ) as? SettingsButtonCell {
                if let button = cell.button as? VButton,
                    let color = self.delegate?.dependencyManager?.color(forKey:  VDependencyManagerLinkColorKey ),
                    let font = self.delegate?.dependencyManager?.font(forKey:  VDependencyManagerHeaderFontKey ) {
                        button.primaryColor = color
                        button.titleLabel?.font = font
                        button.style = .Primary
                }
                cell.delegate = self
                return cell
        }
        
        let identifier = VSettingsSwitchCell.suggestedReuseIdentifier()
        if self.state == .content,
            let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
                let experiment = self.sections[ (indexPath as NSIndexPath).section ].experiments[ indexPath.row ]
                let nameWithID = "\(experiment.name) (\(experiment.id))"
                cell.setTitle( nameWithID, value: experiment.isEnabled.boolValue )
                cell.delegate = self
                cell.switchColor = self.tintColor.current
                return cell
        }
        
        fatalError( "Could not load cell" )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .content where section != tableView.lastSection():
            return self.sections[ section ].experiments.count
        default:
            return 1 // No content/loading cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch state {
        case .content:
            return self.sections.count + 1 // Reset button
        default:
            return 1 // No content/loading cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch state {
        case .content where section != tableView.lastSection():
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
