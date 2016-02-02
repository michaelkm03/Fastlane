//
//  Keyable.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct Victorious: Keyable {
    enum Keys: String {
        case displayOrder
    }
}

protocol Keyable {
    typealias Keys
}
