//
//  Presentable.swift
//  victorious
//
//  Created by Sebastian Nystorm on 27/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// The implementer can be notified of when it enters and leaves the screen.
protocol Presentable {
    func willBePresented()

    func willBeDismissed()
}
