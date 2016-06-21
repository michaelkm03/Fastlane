//
//  EditProfileViewController.swift
//  victorious
//
//  Created by Michael Sena on 6/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class EditProfileViewController: UITableViewController {
    
    private static let unwindToSettingsSegueKey = "unwindToSettings"

    var dependencyManager: VDependencyManager?
    var dataSource: EditProfileTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.backgroundView = dependencyManager?.background().viewForBackground()
        
        if let dependencyManager = dependencyManager {
            dataSource = EditProfileTableViewDataSource(dependencyManager: dependencyManager,
                                                        tableView: tableView)
            tableView.dataSource = dataSource
        }
        
    }
    
    //MARK: - Target Action
    
    @IBAction func tappedSave(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(EditProfileViewController.unwindToSettingsSegueKey, sender: self)
    }

}


private extension VDependencyManager {
    
    var placeholderAndEnteredTextFont: UIFont? {
        return fontForKey("font.paragraph")
    }
    
    var placeholderTextColor: UIColor? {
        return colorForKey("color.text.placeholder")
    }
    
    var enteredTextColor: UIColor? {
        return colorForKey("color.text")
    }
    
    var cellBackgroundColor: UIColor? {
        return colorForKey("color.accent")
    }
}

class EditProfileTableViewDataSource: NSObject, UITableViewDataSource {
    
    let dependencyManager: VDependencyManager
    let tableView: UITableView
    let nameAndLocationCell: UsernameLocationAvatarCell
    let aboutMeCell: AboutMeTextCell
    
    init(dependencyManager: VDependencyManager,
         tableView: UITableView) {
        self.dependencyManager = dependencyManager
        self.tableView = tableView
        nameAndLocationCell = tableView.dequeueReusableCellWithIdentifier("NameLocationAndPictureCell") as! UsernameLocationAvatarCell
        aboutMeCell = tableView.dequeueReusableCellWithIdentifier("AboutMe") as! AboutMeTextCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Username, locaiton and camera
            configureNameAndLocationCell(nameAndLocationCell)
            return nameAndLocationCell
        } else {
            // About Me
            configueAboutMeCell(aboutMeCell)
            return aboutMeCell
        }
    }
    
    private func configureNameAndLocationCell(nameCell: UsernameLocationAvatarCell) {
        nameCell.onReturnKeySelected = { [weak self] in
            self?.aboutMeCell.textView.becomeFirstResponder()
        }
    }
    
    private func configueAboutMeCell(aboutMeCell: AboutMeTextCell) {
        
        // Support resizing
        aboutMeCell.onDesiredHeightChangeClosure = { [weak self] height in
            print(height)
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
        
        aboutMeCell.dependencyManager = dependencyManager
    }
}

class UsernameLocationAvatarCell: UITableViewCell, UITextFieldDelegate {
    
    var onReturnKeySelected: (() -> ())?
    
    var dependencyManager: VDependencyManager? {
        didSet {
            // Visual Configuration
            guard let dependencyManager = dependencyManager,
                let font = dependencyManager.placeholderAndEnteredTextFont,
                let placeholderTextColor = dependencyManager.placeholderTextColor,
                let enteredTextColor = dependencyManager.enteredTextColor else {
                    return
            }
            
            // Font + Colors
            usernameField.font = font
            locationField.font = font
            usernameField.textColor = enteredTextColor
            locationField.textColor = enteredTextColor
            
            // Placeholder
            let placeholderAttributes = [NSForegroundColorAttributeName: placeholderTextColor]
            usernameField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                     attributes: placeholderAttributes)
            locationField.attributedPlaceholder = NSAttributedString(string: "Location",
                                                                     attributes: placeholderAttributes)
            
            // Background
            contentView.backgroundColor = dependencyManager.cellBackgroundColor
        }
    }
    
    @IBOutlet private var usernameField: UITextField! {
        didSet {
            usernameField.delegate = self
        }
    }
    @IBOutlet private var locationField: UITextField! {
        didSet {
            locationField.delegate = self
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField == usernameField {
            locationField.becomeFirstResponder()
        } else if textField == locationField {
            onReturnKeySelected?()
        }
        return true
    }
    
}

class AboutMeTextCell: UITableViewCell, UITextViewDelegate {
    
    var dependencyManager: VDependencyManager? {
        didSet {
            // Visual Configuration
            guard let dependencyManager = dependencyManager,
                let font = dependencyManager.placeholderAndEnteredTextFont,
                let placeholderTextColor = dependencyManager.placeholderTextColor,
                let enteredTextColor = dependencyManager.enteredTextColor else {
                    return
            }
            
            textView.placeholderText = "About Me"
            textView.setPlaceholderFont(font)
            textView.setPlaceholderTextColor(placeholderTextColor)
            textView.textColor = enteredTextColor
            textView.font = font
            
            contentView.backgroundColor = dependencyManager.cellBackgroundColor
        }
    }
    
    var onDesiredHeightChangeClosure: ((desiredHeight: CGFloat) -> ())?
    
    @IBOutlet private var textView: VPlaceholderTextView!
    
    @objc func textViewDidChange(textView: UITextView) {
        let textSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.max))
        guard textSize.height != contentView.bounds.height else {
            return
        }
        
        onDesiredHeightChangeClosure?(desiredHeight: textSize.height)
    }
    
}
