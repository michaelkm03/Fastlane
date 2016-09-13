//
//  NSNumberFormatter.swift
//  victorious
//
//  Created by Jarod Long on 8/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private let _integerFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    formatter.maximumFractionDigits = 0
    return formatter
}()

extension NSNumberFormatter {
    /// A number formatter that produces integer strings.
    static var integerFormatter: NSNumberFormatter {
        return _integerFormatter
    }
}
