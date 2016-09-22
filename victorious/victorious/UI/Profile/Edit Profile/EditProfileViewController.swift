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
    private struct Constants {
        static let animationDuration: NSTimeInterval = 0.25
        static let errorOnScreenDuration: NSTimeInterval = 3.5
        static let cellDisabledAlpha: CGFloat = 0.7
    }

    var dependencyManager: VDependencyManager?
    private var dataSource: EditProfileDataSource?
    private var profilePicturePresenter: VEditProfilePicturePresenter?
    private var keyboardManager: VKeyboardNotificationManager?
    
    @IBOutlet private weak var validationErrorLabel: UILabel!
    @IBOutlet private weak var validationView: UIView!
    @IBOutlet private weak var validationViewTopToLayoutGuideBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    // Exposed for tests since cells are registered in storybaord
    @IBOutlet weak var tableView: UITableView!
    
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

        dataSource?.onErrorUpdated = { [weak self] localizedErrorString in
            self?.animateErrorInThenOut(localizedErrorString)
        }
        navigationItem.title = NSLocalizedString("EditProfile", comment: "Title for edit profile screen.")

        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundView = dependencyManager?.background().viewForBackground()

        keyboardManager = VKeyboardNotificationManager(keyboardWillShowBlock: { [weak self] _,endFrame, _, _ in
            if let existingInsets = self?.tableView.contentInset {
                let newInsets = UIEdgeInsets(top: existingInsets.top, left: existingInsets.left, bottom: endFrame.height, right: existingInsets.right)
                self?.tableView.contentInset = newInsets
                self?.tableView.scrollIndicatorInsets = newInsets
            }
        }, willHideBlock: { _, _, _, _ in
                
        }, willChangeFrameBlock: { [weak self] _, endFrame, _, _ in
            if let existingInsets = self?.tableView.contentInset {
                let newInsets = UIEdgeInsets(top: existingInsets.top, left: existingInsets.left, bottom: endFrame.height, right: existingInsets.right)
                self?.tableView.contentInset = newInsets
                self?.tableView.scrollIndicatorInsets = newInsets
            }
        })
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
        guard let profileUpdate = dataSource?.accountUpdateDelta(), dependencyManager = dependencyManager, let apiPath = dependencyManager.userValidationAPIPath else {
            return
        }
        
        navigationItem.leftBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.enabled = false
        editingEnabled = false
        
        let enableUIClosure = {
            self.editingEnabled = true
            self.navigationItem.leftBarButtonItem?.enabled = true
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        
        let accountUpdateClosure = {
            AccountUpdateOperation(profileUpdate: profileUpdate)?.queue() { result in
                switch result {
                    case .success: self.navigationController?.popViewControllerAnimated(true)
                    default:
                        self.v_showErrorDefaultError()
                        enableUIClosure()
                }
            }
        }
        
        if let username = profileUpdate.username {
            let appID = VEnvironmentManager.sharedInstance().currentEnvironment.appID.stringValue

            UsernameAvailabilityOperation(apiPath: apiPath, usernameToCheck: username, appID: appID)?.queue() { result in
                switch result {
                    case .success(let available):
                        if available {
                            accountUpdateClosure()
                        } else {
                            self.animateErrorInThenOut("Username is not available")
                            enableUIClosure()
                        }
                    case .failure(_), .cancelled:
                        self.animateErrorInThenOut("Failureto check")
                        enableUIClosure()
                }
            }
        } else {
            accountUpdateClosure()
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

    private func animateErrorInThenOut(localizedErrorString: String) {
        self.validationErrorLabel.text = localizedErrorString
        // artificial delay to prevent animations from batching
        dispatch_after(0.01) { [weak self] in
            self?.animateErrorIn()
        }
    }
    
    private func animateErrorIn() {
        UIView.animateWithDuration(
            Constants.animationDuration,
            animations: {
                self.validationViewTopToLayoutGuideBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { finished in
                dispatch_after(Constants.errorOnScreenDuration) { [weak self] in
                    self?.animateErrorOut()
                }
            }
        )
    }
    
    private func animateErrorOut() {
        UIView.animateWithDuration(Constants.animationDuration){
            let validationViewSize = self.validationView.systemLayoutSizeFittingSize(self.view.bounds.size)
            self.validationViewTopToLayoutGuideBottomConstraint.constant = -validationViewSize.height
            self.view.layoutIfNeeded()
        }
    }
}

private extension VDependencyManager {
    var userValidationAPIPath: APIPath? {
        return networkResources?.apiPathForKey("username.validity.URL")
    }
}
