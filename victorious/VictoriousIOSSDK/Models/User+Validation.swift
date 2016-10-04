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
        static let maxUsernameLength = 20
        static let maxDisplayNameLength = 40
    }
    
    // MARK: - Validating properties
    
    public static func validationError(forUsername username: String, errorFormat: UserValidationErrorFormat = .long) -> Error? {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUsername.isEmpty else {
            return validationError(withDescription: NSLocalizedString("EmptyUsername", comment: ""))
        }
        
        guard trimmedUsername.isValidUserName else {
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
    
    public static func validationError(forDisplayName displayName: String) -> Error? {
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedDisplayName.characters.count <= Constants.maxDisplayNameLength else {
            return validationError(withDescription: NSLocalizedString("DisplayNameTooLong", comment: ""))
        }
        
        return nil
    }
    
    // MARK: - Generating errors
    
    private static func validationError(withDescription description: String) -> Error {
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

private extension String {
    // This is a workaround of the bug where CharacterSet.isSuperSetOf can cause random crashes.
    var isValidUserName: Bool {
        let regex = "\\A\\w+\\z"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
}
