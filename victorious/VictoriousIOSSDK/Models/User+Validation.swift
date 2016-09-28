//
//  User+Validation.swift
//  victorious
//
//  Created by Jarod Long on 9/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension User {
    
    // MARK: - Validation constants
    
    private struct Constants {
        static let validUsernameCharacters = NSCharacterSet(
            charactersInString: "abcdefghijklmnopqrstuvwxyz0123456789_"
        )
        
        static let maxUsernameLength = 20
        static let maxDisplayNameLength = 40
    }
    
    // MARK: - Validating properties
    
    public static func validationError(forUsername username: String, errorFormat: UserValidationErrorFormat = .long) -> ErrorType? {
        let trimmedUsername = username.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        guard !trimmedUsername.isEmpty else {
            return validationError(withDescription: NSLocalizedString("EmptyUsername", comment: ""))
        }
        
        let usernameCharacters = NSCharacterSet(charactersInString: trimmedUsername)
        
        guard Constants.validUsernameCharacters.isSupersetOfSet(usernameCharacters) else {
            return validationError(withDescription: {
                switch errorFormat {
                    case .long: return NSLocalizedString("InvalidUsernameCharactersLong", comment: "")
                    case .short: return NSLocalizedString("InvalidUsernameCharactersShort", comment: "")
                }
            }())
        }
        
        guard trimmedUsername.characters.count <= Constants.maxUsernameLength else {
            return validationError(withDescription: NSLocalizedString("UsernameTooLong", comment: ""))
        }
        
        return nil
    }
    
    public static func validationError(forDisplayName displayName: String) -> ErrorType? {
        let trimmedDisplayName = displayName.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        guard trimmedDisplayName.characters.count <= Constants.maxDisplayNameLength else {
            return validationError(withDescription: NSLocalizedString("DisplayNameTooLong", comment: ""))
        }
        
        return nil
    }
    
    // MARK: - Generating errors
    
    private static func validationError(withDescription description: String) -> ErrorType {
        // FUTURE: We should create `LocalizedError` enums for each validated property once we move to Swift 3.
        return NSError(domain: "UserValidationError", code: -1, userInfo: [
            NSLocalizedDescriptionKey: description
        ])
    }
}

/// An enum for different formats of error messages returned from validating `User` properties.
public enum UserValidationErrorFormat {
    case long, short
}
