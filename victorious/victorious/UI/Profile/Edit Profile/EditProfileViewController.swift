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
    var profilePicturePresenter: VEditProfilePicturePresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        guard let dependencyManager = dependencyManager,
            currentUser = VCurrentUser.user() else {
                print("We need a dependencyManager in the edit profile VC!")
                return
        }
        
        //TODO: Refactor me getting too nested in this bitch
        dataSource = EditProfileTableViewDataSource(dependencyManager: dependencyManager,
                                                    tableView: tableView,
                                                    userModel: currentUser)
        dataSource?.onUserRequestsCameraFlow = { [weak self] in
            VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectImageForEditProfile)
            self?.profilePicturePresenter = VEditProfilePicturePresenter(dependencyManager: dependencyManager)
            self?.profilePicturePresenter?.resultHandler = { success, previewImage, mediaURL in
                defer {
                    self?.dismissViewControllerAnimated(true, completion: nil)
                }
                
                guard success else {
                    return
                }
                
                // Create a new userModel with the new preview image
                let imageAsset = ImageAsset(url: mediaURL)
                let newUser = User(id: currentUser.id,
                                   email: nil,
                                   name: nil,
                                   completedProfile: nil,
                                   location: nil,
                                   tagline: nil,
                                   fanLoyalty: nil,
                                   isBlockedByCurrentUser: nil,
                                   accessLevel: .owner,
                                   isDirectMessagingDisabled: nil,
                                   isFollowedByCurrentUser: nil,
                                   numberOfFollowers: nil,
                                   numberOfFollowing: nil,
                                   likesGiven: nil,
                                   likesReceived: nil,
                                   previewImages: [imageAsset],
                                   maxVideoUploadDuration: nil,
                                   avatarBadgeType: currentUser.avatarBadgeType,
                                   vipStatus: nil)
                self?.dataSource?.user = newUser
            }
            self?.profilePicturePresenter?.presentOnViewController(self)
        }
        
        tableView.dataSource = dataSource
        tableView.backgroundView = dependencyManager.background().viewForBackground()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSource?.beginEditing()
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
    
    private let dependencyManager: VDependencyManager
    private let tableView: UITableView
    private let nameAndLocationCell: UsernameLocationAvatarCell
    private let aboutMeCell: AboutMeTextCell
    var user: UserModel {
        didSet {
            updateUI()
        }
    }
    var onUserRequestsCameraFlow: (() -> ())?
    
    init(dependencyManager: VDependencyManager,
         tableView: UITableView,
         userModel: UserModel) {
        self.dependencyManager = dependencyManager
        self.tableView = tableView
        self.user = userModel
        nameAndLocationCell = tableView.dequeueReusableCellWithIdentifier("NameLocationAndPictureCell") as! UsernameLocationAvatarCell
        aboutMeCell = tableView.dequeueReusableCellWithIdentifier("AboutMe") as! AboutMeTextCell
        super.init()
        self.updateUI()
    }
    
    // MARK: - UITableViewDataSource
    
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
    
    func beginEditing() {
        nameAndLocationCell.beginEditing()
    }
    
    // MARK: - Misc Private Funcitons
    
    private func updateUI() {
        nameAndLocationCell.user = user
        aboutMeCell.tagline = user.tagline
    }
    
    private func configureNameAndLocationCell(nameCell: UsernameLocationAvatarCell) {
        nameCell.onReturnKeySelected = { [weak self] in
            self?.aboutMeCell.beginEditing()
        }
        nameCell.onAvatarSelected = { [weak self] in
            self?.onUserRequestsCameraFlow?()
        }
        nameCell.dependencyManager = dependencyManager
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
