//
//  EditProfileDataSource.swift
//  victorious
//
//  Created by Michael Sena on 7/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class EditProfileDataSource: NSObject, UITableViewDataSource {
    
    private let dependencyManager: VDependencyManager
    private let tableView: UITableView
    private let nameAndLocationCell: UsernameLocationAvatarCell
    private let aboutMeCell: AboutMeTextCell
    private var newAvatarFileURL: NSURL?
    
    /// Assign a user struct to update the UI. Does not reflect any edits
    var user: UserModel {
        didSet {
            updateUI()
        }
    }
    
    /// A callback to be notified when the user would like to edit their profile avatar
    var onUserRequestsCameraFlow: (() -> ())?
    
    /// A callback to be notified when the user has made any changes to their information
    var onUserUpdateData: (() -> ())?
    
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
        nameAndLocationCell.onDataChange = { [weak self] in
            self?.onUserUpdateData?()
        }
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
    
    /// Check this boolean to determine whether or not the entered data is currently valid
    var enteredDataIsValid: Bool {
        get {
            let username = nameAndLocationCell.username
            guard let trimmedUsername = username?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) where
                !trimmedUsername.isEmpty else {
                    return false
            }
            guard trimmedUsername.characters.count < 255 else {
                return false
            }
            return true
        }
    }
    
    /// This function will update the UI with the provided `previewImage` and returns it in the
    func useNewAvatar(previewImage: UIImage, fileURL: NSURL) {
        // Create a new userModel with the new preview image
        newAvatarFileURL = fileURL
        let imageAsset = ImageAsset(url: fileURL, size: previewImage.size)
        let newUser = User(id: user.id,
                           username: nameAndLocationCell.username ?? user.username,
                           completedProfile: user.completedProfile,
                           location: nameAndLocationCell.location ?? user.location,
                           tagline: aboutMeCell.tagline,
                           accessLevel: .owner,
                           previewImages: [imageAsset],
                           avatarBadgeType: user.avatarBadgeType,
                           vipStatus: user.vipStatus)
        self.user = newUser
    }
    
    /// An update 
    func accountUpdateDelta() -> ProfileUpdate? {
        return ProfileUpdate(email: nil,
                             name: nameAndLocationCell.username,
                             location: nameAndLocationCell.location,
                             tagline: aboutMeCell.tagline,
                             profileImageURL: newAvatarFileURL)
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
