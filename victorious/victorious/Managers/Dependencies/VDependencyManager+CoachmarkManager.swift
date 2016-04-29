//
//  VDependencyManager+CoachmarkManager.swift
//  victorious
//
//  Created by Jarod Long on 4/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VDependencyManager {
    var coachmarkManager: VCoachmarkManager? {
        return (scaffoldViewController() as? Scaffold)?.coachmarkManager
    }
}
