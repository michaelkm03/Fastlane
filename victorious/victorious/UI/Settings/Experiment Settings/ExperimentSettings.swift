//
//  ExperimentSettings.swift
//  victorious
//
//  Created by Josh Hinman on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

private let kActiveExperimentsKey = "com.getvictorious.experiments.active_experiments";

/// Stores a list of active experiment IDs kept synched internally by NSUserDefaults.
/// Multiple instances of this class can be used independenctly and NSUserDefaults
/// will keep values synched.
class ExperimentSettings: NSObject {
    
    /// A set of the user-selected experiments to be active in all subsequent backend interactions
    var activeExperiments: Set<Int>? {
        get {
            if let activeExperiments = UserDefaults.standard.object(forKey: kActiveExperimentsKey) as? [Int] {
                return Set(activeExperiments)
            }
            return nil
        }
        set(experiments) {
            let userDefaults = UserDefaults.standard
            if let experiments = experiments {
                userDefaults.set(Array(experiments), forKey: kActiveExperimentsKey)
            }
            else {
                userDefaults.removeObject(forKey: kActiveExperimentsKey)
            }
            userDefaults.synchronize()
        }
    }
    
    /// Removes all active experiments and clears value in NSUserDefaults.
    /// This will return the application to membership in experiments as determined by the backend,
    /// essentially undoing and previously user-selected experiment memberships.
    func reset() {
        activeExperiments = nil
    }
    
    /// Returns a command-separated list of hte active experiments for use in request header.
    func commaSeparatedList() -> String? {
        
        if let activeExperiments = self.activeExperiments {
            // An empty string used in a header indicates to the backend that the user has
            // manually opted out of all experiments
            return activeExperiments.map { "\($0)" }.joined( separator: "," )
        }
        else {
            // A nil value used in a header indicates to the backend that the user does not wish
            // to deviate from the default experiment membership
            return nil
        }
    }
}
