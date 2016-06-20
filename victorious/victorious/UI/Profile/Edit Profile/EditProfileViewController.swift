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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.backgroundView = dependencyManager?.background().viewForBackground()
    }
    
    //MARK: - Target Action
    
    @IBAction func tappedSave(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(EditProfileViewController.unwindToSettingsSegueKey, sender: self)
    }
    
    // MARK: - UITableViewDataSource
//TODO: Move to data source object
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Username, locaiton and camera
            return tableView.dequeueReusableCellWithIdentifier("NameLocationAndPictureCell")!
        } else {
            // About Me
            let aboutMeCell = tableView.dequeueReusableCellWithIdentifier("AboutMe") as! AboutMeTextCell
            configueAboutMeCell(aboutMeCell)
            return aboutMeCell
        }
    }
    
    // MARK: - Cell Configuration
    
    private func configueAboutMeCell(aboutMeCell: AboutMeTextCell) {
        
        // Support resizing
        aboutMeCell.onDesiredHeightChangeClosure = { height in
            print(height)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        aboutMeCell.dependencyManager = dependencyManager
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

class UsernameLocationAvatarCell: UITableViewCell {
    
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
    
    @IBOutlet private var usernameField: UITextField!
    @IBOutlet private var locationField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
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
