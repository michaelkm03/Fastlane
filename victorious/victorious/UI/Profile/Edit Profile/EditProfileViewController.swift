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
    
    private static let unwindToSettingsSegueKey = "unwindToSettings"

    var dependencyManager: VDependencyManager?
    private var dataSource: EditProfileDataSource?
    private var profilePicturePresenter: VEditProfilePicturePresenter?
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    
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
    
    // MARK: - Validation
    
    private func setupDataSource() {
        guard let dependencyManager = dependencyManager,
            currentUser = VCurrentUser.user() else {
                print("We need a dependencyManager in the edit profile VC!")
                return
        }
        dataSource = EditProfileDataSource(dependencyManager: dependencyManager,
                                           tableView: tableView,
                                           userModel: currentUser)
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
        self.profilePicturePresenter = VEditProfilePicturePresenter(dependencyManager: dependencyManager)
        self.profilePicturePresenter?.resultHandler = { [weak self] success, previewImage, mediaURL in
            defer {
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            
            guard success else {
                return
            }
            self?.dataSource?.useNewAvatar(previewImage, fileURL: mediaURL)
        }
        self.profilePicturePresenter?.presentOnViewController(self)
    }
}
