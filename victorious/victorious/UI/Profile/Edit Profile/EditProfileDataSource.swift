//
//  EditProfileDataSource.swift
//  victorious
//
//  Created by Michael Sena on 7/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class EditProfileDataSource: NSObject, UITableViewDataSource {
    private let dependencyManager: VDependencyManager
    private let tableView: UITableView
    let nameAndLocationCell: DisplaynameLocationAvatarCell
    let aboutMeCell: AboutMeTextCell
    private var newAvatarFileURL: URL?
    private var user: UserModel {
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
        nameAndLocationCell = tableView.dequeueReusableCell(withIdentifier: "NameLocationAndPictureCell") as! DisplaynameLocationAvatarCell
        aboutMeCell = tableView.dequeueReusableCell(withIdentifier: "AboutMe") as! AboutMeTextCell
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Username, location and camera
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
    var localizedError: Error? {
        let username = nameAndLocationCell.username ?? ""
        let displayName = nameAndLocationCell.displayname ?? ""
        
        return (
            User.validationError(forUsername: username) ??
            User.validationError(forDisplayName: displayName)
        )
    }
    
    /// This function will update the UI with the provided `previewImage`
    func useNewAvatar(_ previewImage: UIImage, fileURL: URL) {
        // Create a new userModel with the new preview image
        newAvatarFileURL = fileURL
        
        let imageAsset = ImageAsset(url: fileURL as NSURL, size: previewImage.size)
        self.user = User(
            id: user.id,
            username: nameAndLocationCell.username ?? user.username,
            displayName: nameAndLocationCell.displayname ?? user.displayName,
            completedProfile: user.completedProfile,
            location: nameAndLocationCell.location ?? user.location,
            tagline: aboutMeCell.tagline,
            accessLevel: user.accessLevel,
            previewImages: [imageAsset],
            avatarBadgeType: user.avatarBadgeType,
            vipStatus: user.vipStatus
        )
    }
    
    func accountUpdateDelta() -> ProfileUpdate? {
        return ProfileUpdate(
            displayName: nameAndLocationCell.displayname,
            username: nameAndLocationCell.username == VCurrentUser.user?.username ? nil : nameAndLocationCell.username,
            location: nameAndLocationCell.location,
            tagline: aboutMeCell.tagline,
            profileImageURL: newAvatarFileURL as NSURL?
        )
    }
    
    func beginEditing() {
        nameAndLocationCell.beginEditing()
    }
    
    // MARK: - Misc Private Funcitons
    
    private func updateUI() {
        nameAndLocationCell.populate(withUser: user)
        aboutMeCell.tagline = user.tagline
    }
    
    private func configureNameAndLocationCell(_ nameCell: DisplaynameLocationAvatarCell) {
        nameCell.onReturnKeySelected = { [weak self] in
            self?.aboutMeCell.beginEditing()
        }
        nameCell.onAvatarSelected = { [weak self] in
            self?.onUserRequestsCameraFlow?()
        }
        nameCell.dependencyManager = dependencyManager
    }
    
    private func configueAboutMeCell(_ aboutMeCell: AboutMeTextCell) {
        // Support resizing
        aboutMeCell.onDesiredHeightChangeClosure = { [weak self] height in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
        
        aboutMeCell.dependencyManager = dependencyManager
    }
}

private extension String {
    var isValidUserName: Bool {
        let regex = "\\A\\w+\\z"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
}
