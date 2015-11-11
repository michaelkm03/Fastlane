//
//  TODO.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Comment {}
extension Comment {
    public init?(json: JSON) {
        return nil
    }
}

public struct VoteResult {}
extension VoteResult {
    public init?(json: JSON) {
        return nil
    }
}

public struct Tracking {}
extension Tracking {
    public init?(json: JSON) {
        return nil
    }
}

public struct EndCard {}
extension EndCard {
    public init?(json: JSON) {
        return nil
    }
}

public struct AdBreak {}
extension AdBreak {
    public init?(json: JSON) {
        return nil
    }
}

/// This is a temporary implementation to make tests pass
public struct Sequence {
    public var sequenceID: Int64
    
    public init (sequenceID: Int64) {
        self.sequenceID = sequenceID
    }
}
extension Sequence {
    public init?(json: JSON) {
        if let sequenceID = json["id"].string {
            self.sequenceID = Int64(sequenceID)!
        } else if let sequenceID = json["id"].int64 {
            self.sequenceID = sequenceID
        } else {
            return nil
        }
    }
}
