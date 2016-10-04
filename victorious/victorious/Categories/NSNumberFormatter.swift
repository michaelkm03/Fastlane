//
//  NSNumberFormatter.swift
//  victorious
//
//  Created by Jarod Long on 8/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private let _integerFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    return formatter
}()

extension NumberFormatter {
    /// A number formatter that produces integer strings.
    static var integerFormatter: NumberFormatter {
        return _integerFormatter
    }
}
