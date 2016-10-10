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
            return UsernameValidationError.empty
        }
        
        guard trimmedUsername.isValidUserName else {
            return UsernameValidationError.invalidCharacters(format: errorFormat)
        }
        
        guard trimmedUsername.characters.count <= Constants.maxUsernameLength else {
            return UsernameValidationError.tooLong
        }
        
        return nil
    }
    
    public static func validationError(forDisplayName displayName: String) -> Error? {
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedDisplayName.characters.count <= Constants.maxDisplayNameLength else {
            return DisplayNameValidationError.tooLong
        }
        
        return nil
    }
}

private extension String {
    // This is a workaround of the bug where CharacterSet.isSuperSetOf can cause random crashes.
    var isValidUserName: Bool {
        let regex = "\\A\\w+\\z"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
}

/// An enum for different formats of error messages returned from validating `User` properties.
public enum UserValidationErrorFormat {
    case long, short
}

/// Errors that can occur when validating a username.
public enum UsernameValidationError: LocalizedError {
    case empty
    case tooLong
    case alreadyTaken
    case invalidCharacters(format: UserValidationErrorFormat)
    
    public var errorDescription: String? {
        switch self {
            case .empty: return NSLocalizedString("EmptyUsername", comment: "")
            case .tooLong: return NSLocalizedString("UsernameTooLong", comment: "")
            case .alreadyTaken: return NSLocalizedString("UsernameTaken", comment: "")
            case .invalidCharacters(let format):
                switch format {
                    case .short: return NSLocalizedString("InvalidUsernameCharactersShort", comment: "")
                    case .long: return NSLocalizedString("InvalidUsernameCharactersLong", comment: "")
                }
        }
    }
}

/// Errors that can occur when validating a display name.
public enum DisplayNameValidationError: LocalizedError {
    case tooLong
    
    public var errorDescription: String? {
        switch self {
            case .tooLong: return NSLocalizedString("DisplayNameTooLong", comment: "")
        }
    }
}
