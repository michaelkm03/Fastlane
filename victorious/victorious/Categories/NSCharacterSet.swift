//
//  NSCharacterSet.swift
//  victorious
//
//  Created by Michael Sena on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension CharacterSet {
    public static var validUsernameCharacters: CharacterSet {
        return CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_")
    }

}
