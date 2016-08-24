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
    let nameAndLocationCell: DisplaynameLocationAvatarCell
    let aboutMeCell: AboutMeTextCell
    private var newAvatarFileURL: NSURL?
    private var user: UserModel {
        didSet {
            updateUI()
        }
    }
    
    init(dependencyManager: VDependencyManager, tableView: UITableView, userModel: UserModel) {
        self.dependencyManager = dependencyManager
        self.tableView = tableView
        self.user = userModel
        nameAndLocationCell = tableView.dequeueReusableCellWithIdentifier("NameLocationAndPictureCell") as! DisplaynameLocationAvatarCell
        aboutMeCell = tableView.dequeueReusableCellWithIdentifier("AboutMe") as! AboutMeTextCell
        super.init()
        self.updateUI()
        nameAndLocationCell.onDataChange = { [weak self] in
            self?.onUserUpdateData?()
        }
        aboutMeCell.onDataChange = { [weak self] in
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
    
    /// A callback to be notified when the user would like to edit their profile avatar
    var onUserRequestsCameraFlow: (() -> Void)?
    
    /// A callback to be notified when the user has made any changes to their information
    var onUserUpdateData: (() -> Void)?
    
    /// Check this boolean to determine whether or not the entered data is currently valid
    var enteredDataIsValid: Bool {
        get {
            let username = nameAndLocationCell.displayname
            guard
                let trimmedUsername = username?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                where !trimmedUsername.isEmpty
            else {
                return false
            }
            guard trimmedUsername.characters.count < 255 else {
                return false
            }
            guard aboutMeCell.isWithinValidLength else {
                return false
            }
            return true
        }
    }
    
    /// This function will update the UI with the provided `previewImage`
    func useNewAvatar(previewImage: UIImage, fileURL: NSURL) {
        // Create a new userModel with the new preview image
        newAvatarFileURL = fileURL
        let imageAsset = ImageAsset(url: fileURL, size: previewImage.size)
        let newUser = User(id: user.id,
                           displayName: nameAndLocationCell.displayname ?? user.displayName,
                           completedProfile: user.completedProfile,
                           location: nameAndLocationCell.location ?? user.location,
                           tagline: aboutMeCell.tagline,
                           accessLevel: user.accessLevel,
                           previewImages: [imageAsset],
                           avatarBadgeType: user.avatarBadgeType,
                           vipStatus: user.vipStatus)
        self.user = newUser
    }
    
    func accountUpdateDelta() -> ProfileUpdate? {
        return ProfileUpdate(displayName: nameAndLocationCell.displayname,
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
    
    private func configureNameAndLocationCell(nameCell: DisplaynameLocationAvatarCell) {
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
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
        
        aboutMeCell.dependencyManager = dependencyManager
    }
}
