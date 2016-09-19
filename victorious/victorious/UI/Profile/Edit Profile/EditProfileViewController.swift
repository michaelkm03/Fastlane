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
class EditProfileViewController: UIViewController {
    var dependencyManager: VDependencyManager?
    private var dataSource: EditProfileDataSource?
    private var profilePicturePresenter: VEditProfilePicturePresenter?
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView!
    
    var editingEnabled: Bool = true {
        didSet {
            for cell in tableView.visibleCells {
                cell.alpha = editingEnabled ? 1.0 : 0.7
                cell.userInteractionEnabled = editingEnabled
            }
        }
    }
    
    // MARK: - UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundView = dependencyManager?.background().viewForBackground()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSource?.beginEditing()
    }
    
    // MARK: - Target Action
    
    @IBAction func tappedCancel(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction private func tappedSave(sender: UIBarButtonItem) {
        
        guard let profileUpdate = dataSource?.accountUpdateDelta() else {
            return
        }
        
        navigationItem.leftBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.enabled = false
        editingEnabled = false
        AccountUpdateOperation(profileUpdate: profileUpdate)?.queue() { result in
            
            switch result {
                case .success: self.navigationController?.popViewControllerAnimated(true)
                default:
                    // TODO: Better error handling
                    self.v_showErrorWithTitle("failure", message: "oh no")
                    self.editingEnabled = true
                    self.navigationItem.leftBarButtonItem?.enabled = true
                    self.navigationItem.rightBarButtonItem?.enabled = true
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
        // TODO: Provide better feedback and error handling
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
