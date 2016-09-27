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
    
    // TODO: We want to auto-trim these names. Maybe these methods should return a Result<String> for a processed value
    // or a validation error.
    
    public static func validationError(forUsername username: String, errorFormat: UserValidationErrorFormat = .long) -> ErrorType? {
        guard !username.isEmpty else {
            return validationError(withDescription: NSLocalizedString("EmptyUsername", comment: ""))
        }
        
        let usernameCharacters = NSCharacterSet(charactersInString: username)
        
        guard Constants.validUsernameCharacters.isSupersetOfSet(usernameCharacters) else {
            return validationError(withDescription: {
                switch errorFormat {
                    case .long: return NSLocalizedString("InvalidUsernameCharactersLong", comment: "")
                    case .short: return NSLocalizedString("InvalidUsernameCharactersShort", comment: "")
                }
            }())
        }
        
        guard username.characters.count <= Constants.maxUsernameLength else {
            return validationError(withDescription: NSLocalizedString("UsernameTooLong", comment: ""))
        }
        
        return nil
    }
    
    public static func validationError(forDisplayName displayName: String) -> ErrorType? {
        guard !displayName.isEmpty else {
            return validationError(withDescription: NSLocalizedString("EmptyDisplayName", comment: ""))
        }
        
        guard displayName.characters.count < Constants.maxDisplayNameLength else {
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
