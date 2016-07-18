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
        
        guard let dataSource = dataSource else {
            // Must have a dataSource in order to grab the values
            return
        }
        
        if let delta = dataSource.accountUpdateDelta(),
            let operation = AccountUpdateOperation(profileUpdate: delta) {
                operation.queue()
        } else {
            print("failed ot create operation!!")
        }
        
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
    
    // MARK: - API
    
    func accountUpdateDelta() -> ProfileUpdate? {
        guard let currentUser = VCurrentUser.user() else {
            print("we need a user to compute the delta on!")
            return nil
        }
        
        let nameFieldValue = nameAndLocationCell.username
        let locationFieldValue = nameAndLocationCell.location
        let taglineFieldValue = aboutMeCell.tagline
        
        let username = nameFieldValue != currentUser.name ? nameFieldValue : nil
        let location = locationFieldValue != currentUser.location ? locationFieldValue : nil
        let tagline = taglineFieldValue != currentUser.tagline ? taglineFieldValue : nil
        
        return ProfileUpdate(email: nil,
                             name: username,
                             location: location,
                             tagline: tagline,
                             profileImageURL: nil)
    }
    
    // MARK: - Misc Private Funcitons
    
    private func configureNameAndLocationCell(nameCell: UsernameLocationAvatarCell) {
        nameCell.onReturnKeySelected = { [weak self] in
            self?.aboutMeCell.beginEditing()
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
