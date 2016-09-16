//
//  EditProfileViewController.swift
//  victorious
//
//  Created by Michael Sena on 6/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Provides UI for editing the currently logged in user's metadata
/// Uses a save button that enables/disables when the entered data is valid.
/// Navigates away with a storyboard segue back to settings when complete.
class EditProfileViewController: UITableViewController {
    var dependencyManager: VDependencyManager?
    private static let unwindToSettingsSegueKey = "unwindToSettings"
    private var dataSource: EditProfileDataSource?
    private var profilePicturePresenter: VEditProfilePicturePresenter?
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    
    // MARK: - UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundView = dependencyManager?.background().viewForBackground()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSource?.beginEditing()
    }
    
    // MARK: - Target Action
    
    @IBAction private func tappedSave(sender: UIBarButtonItem) {
        
        guard let profileUpdate = dataSource?.accountUpdateDelta() else {
            return
        }
        
        AccountUpdateOperation(profileUpdate: profileUpdate)?.queue() { result in
            switch result {
                case .success: self.performSegueWithIdentifier(EditProfileViewController.unwindToSettingsSegueKey, sender: self)
                default: print("failure!")
            }
        }
    }
    
    // MARK: - Miscellaneous Private Functions
    
    private func setupDataSource() {
        guard
            let dependencyManager = dependencyManager,
            let currentUser = VCurrentUser.user else {
                v_log("We need a dependencyManager in the edit profile VC!")
                return
        }
        dataSource = EditProfileDataSource(dependencyManager: dependencyManager, tableView: tableView, userModel: currentUser)
        dataSource?.onUserRequestsCameraFlow = { [weak self] in
            self?.presentCamera()
        }
        dataSource?.onUserUpdateData = { [weak self] in
            self?.updateUI()
        }
        
        tableView.dataSource = dataSource
    }
    
    private func updateUI() {
        guard let dataSource = self.dataSource else {
            return
        }
        saveButton.enabled = dataSource.enteredDataIsValid
    }
    
    private func presentCamera() {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectImageForEditProfile)
        profilePicturePresenter = VEditProfilePicturePresenter(dependencyManager: dependencyManager)
        profilePicturePresenter?.resultHandler = { [weak self] success, previewImage, mediaURL in
            defer {
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            
            guard success else {
                return
            }
            self?.dataSource?.useNewAvatar(previewImage, fileURL: mediaURL)
        }
        profilePicturePresenter?.presentOnViewController(self)
    }
}
