//
//  EditProfileDataSource.swift
//  victorious
//
//  Created by Michael Sena on 7/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class EditProfileDataSource: NSObject, UITableViewDataSource {
    fileprivate struct Constants {
        static let displayNameLength = 40
        static let usernameLength = 20
    }
    
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let tableView: UITableView
    let nameAndLocationCell: DisplaynameLocationAvatarCell
    let aboutMeCell: AboutMeTextCell
    fileprivate var newAvatarFileURL: URL?
    fileprivate var user: UserModel {
        didSet {
            updateUI()
            if let currentUser = user as? User {
                VCurrentUser.update(to: currentUser)
            }
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
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    /// Check this to determine whether or not the entered data is currently valid. When this propery is `nil` the dataSource is considered valid.
    var localizedError: String? {
        get {
            // Displayname Validation
            let displayname = nameAndLocationCell.displayname
            guard let trimmedDisplayName = displayname?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) , !trimmedDisplayName.isEmpty else {
                return NSLocalizedString("Your display name cannoot be blank.", comment: "While editing, error letting the user know their display name cannot be blank.")
            }
            
            guard displayname?.characters.count < Constants.displayNameLength else {
                return NSLocalizedString("Your display name is too long.", comment: "While editing, error letting the user know their display name must be shorter.")
            }
            
            // Username Validation
            guard let username = nameAndLocationCell.username , !username.characters.isEmpty else {
                return NSLocalizedString("Your username cannot be empty.", comment: "While editing, error to the user letting them know their username must not be empty.")
            }
            let usernameCharacterset = CharacterSet(charactersIn: username)
            guard CharacterSet.validUsernameCharacters.isSuperset(of: usernameCharacterset) else {
                return NSLocalizedString("Your username can only contain lowercase letters a-z, number 0-9, and underscores \"_\".",
                    comment: "While editing, an error that informs they have entered and invalid characters and must remove the invalid character.")
            }
            guard username.characters.count <= Constants.usernameLength else {
                return NSLocalizedString("Your username can only be 20 characters long.",
                comment: "While editing, an error that informs they have entered and invalid characters and must remove the invalid character.")
            }
            return nil
        }
    }
    
    /// This function will update the UI with the provided `previewImage`
    func useNewAvatar(_ previewImage: UIImage, fileURL: URL) {
        // Create a new userModel with the new preview image
        newAvatarFileURL = fileURL
        let imageAsset = ImageAsset(url: fileURL, size: previewImage.size)
        let newUser = User(id: user.id,
                           username: nameAndLocationCell.username ?? user.username,
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
                             username: nameAndLocationCell.username == VCurrentUser.user?.username ? nil : nameAndLocationCell.username,
                             location: nameAndLocationCell.location,
                             tagline: aboutMeCell.tagline,
                             profileImageURL: newAvatarFileURL)
    }
    
    func beginEditing() {
        nameAndLocationCell.beginEditing()
    }
    
    // MARK: - Misc Private Funcitons
    
    fileprivate func updateUI() {
        nameAndLocationCell.populate(withUser: user)
        aboutMeCell.tagline = user.tagline
    }
    
    fileprivate func configureNameAndLocationCell(_ nameCell: DisplaynameLocationAvatarCell) {
        nameCell.onReturnKeySelected = { [weak self] in
            self?.aboutMeCell.beginEditing()
        }
        nameCell.onAvatarSelected = { [weak self] in
            self?.onUserRequestsCameraFlow?()
        }
        nameCell.dependencyManager = dependencyManager
    }
    
    fileprivate func configueAboutMeCell(_ aboutMeCell: AboutMeTextCell) {
        // Support resizing
        aboutMeCell.onDesiredHeightChangeClosure = { [weak self] height in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
        
        aboutMeCell.dependencyManager = dependencyManager
    }
}
