//
//  JSONDeseriealizable.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import SwiftyJSON

protocol JSONDeseriealizable {
    init?(json: JSON)
}
