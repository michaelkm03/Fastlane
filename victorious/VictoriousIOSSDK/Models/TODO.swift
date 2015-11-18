//
//  TODO.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Tracking {}
extension Tracking {
    public init?(json: JSON) {
        self.init()
    }
}

public struct EndCard {}
extension EndCard {
    public init?(json: JSON) {
        self.init()
    }
}

public struct AdBreak {}
extension AdBreak {
    public init?(json: JSON) {
        self.init()
    }
}

public struct PollResult {}
extension PollResult {
    public init?(json: JSON) {
        return nil
    }
}
