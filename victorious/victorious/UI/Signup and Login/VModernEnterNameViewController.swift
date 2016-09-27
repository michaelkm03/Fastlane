//
//  VModernEnterNameViewController.swift
//  victorious
//
//  Created by Jarod Long on 9/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VModernEnterNameViewController {
    func validateUsername(from textField: VInlineValidationTextField) -> Bool {
        let username = textField.text ?? ""
        
        guard let error = User.validationError(forUsername: username) else {
            return true
        }
        
        let errorDescription = (error as NSError).localizedDescription
        textField.showInvalidText(errorDescription, animated: true, shake: true, forced: true)
        return false
    }
}
