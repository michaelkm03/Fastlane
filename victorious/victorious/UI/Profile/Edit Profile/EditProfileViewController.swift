//
//  EditProfileViewController.swift
//  victorious
//
//  Created by Michael Sena on 6/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

/// Provides UI for editing the currently logged in user's metadata
/// Uses a save button that enables/disables when the entered data is valid.
/// Navigates away with a storyboard segue back to settings when complete.
class EditProfileViewController: UIViewController {
    fileprivate struct Constants {
        static let animationDuration: TimeInterval = 0.25
        static let errorOnScreenDuration: TimeInterval = 3.5
        static let cellDisabledAlpha: CGFloat = 0.7
    }

    var dependencyManager: VDependencyManager?
    fileprivate var dataSource: EditProfileDataSource?
    fileprivate var profilePicturePresenter: VEditProfilePicturePresenter?
    fileprivate var keyboardManager: VKeyboardNotificationManager?
    
    @IBOutlet fileprivate weak var validationErrorLabel: UILabel!
    @IBOutlet fileprivate weak var validationView: UIView!
    @IBOutlet fileprivate weak var validationViewTopToLayoutGuideBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var saveButton: UIBarButtonItem!
    // Exposed for tests since cells are registered in storybaord
    @IBOutlet weak var tableView: UITableView!
    
    var editingEnabled: Bool = true {
        didSet {
            for cell in tableView.visibleCells {
                cell.alpha = editingEnabled ? 1.0 : 0.7
                cell.isUserInteractionEnabled = editingEnabled
            }
        }
    }
    
    // MARK: - UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()

        navigationItem.title = NSLocalizedString("EditProfile", comment: "Title for edit profile screen.")

        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundView = dependencyManager?.background().viewForBackground()

        keyboardManager = VKeyboardNotificationManager(keyboardWillShow: { [weak self] _,endFrame, _, _ in
            if let existingInsets = self?.tableView.contentInset {
                let newInsets = UIEdgeInsets(top: existingInsets.top, left: existingInsets.left, bottom: endFrame.height, right: existingInsets.right)
                self?.tableView.contentInset = newInsets
                self?.tableView.scrollIndicatorInsets = newInsets
            }
            }, willHide: { _, _, _, _ in
                
        }, willChangeFrameBlock: { [weak self] _, endFrame, _, _ in
            if let existingInsets = self?.tableView.contentInset {
                let newInsets = UIEdgeInsets(top: existingInsets.top, left: existingInsets.left, bottom: endFrame.height, right: existingInsets.right)
                self?.tableView.contentInset = newInsets
                self?.tableView.scrollIndicatorInsets = newInsets
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource?.beginEditing()
    }
    
    // MARK: - Target Action
    
    @IBAction func tappedCancel(_ sender: UIBarButtonItem) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction fileprivate func tappedSave(_ sender: UIBarButtonItem) {
        guard let profileUpdate = dataSource?.accountUpdateDelta(), let dependencyManager = dependencyManager, let apiPath = dependencyManager.userValidationAPIPath else {
            return
        }
        
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        editingEnabled = false
        
        let enableUIClosure = {
            self.editingEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        let accountUpdateClosure = {
            AccountUpdateOperation(profileUpdate: profileUpdate)?.queue() { result in
                switch result {
                    case .success:
                        let _ = self.navigationController?.popViewController(animated: true)
                    default:
                        self.v_showErrorDefaultError()
                        enableUIClosure()
                }
            }
        }
        
        if let username = profileUpdate.username {
            let appID = VEnvironmentManager.sharedInstance().currentEnvironment.appID.stringValue
            guard let usernameAvailabilityRequest = UsernameAvailabilityRequest(apiPath: apiPath, usernameToCheck: username, appID: appID) else {
                self.animateErrorInThenOut(NSLocalizedString("ErrorOccured", comment: ""))
                enableUIClosure()
                return
            }
            RequestOperation(request: usernameAvailabilityRequest).queue() { result in
                switch result {
                    case .success(let available):
                        if available {
                            accountUpdateClosure()
                        } else {
                            self.animateErrorInThenOut(NSLocalizedString("That username is already taken.", comment: ""))
                            enableUIClosure()
                        }
                    case .failure(_), .cancelled:
                        self.animateErrorInThenOut(NSLocalizedString("ErrorOccured", comment: ""))
                        enableUIClosure()
                }
            }
        } else {
            accountUpdateClosure()
        }
    }
    
    // MARK: - Miscellaneous Private Functions
    
    fileprivate func setupDataSource() {
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
    
    fileprivate func updateUI() {
        guard let dataSource = self.dataSource else {
            return
        }
        if let error = dataSource.localizedError {
            self.animateErrorInThenOut(error)
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    fileprivate func presentCamera() {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectImageForEditProfile)
        profilePicturePresenter = VEditProfilePicturePresenter(dependencyManager: dependencyManager)
        profilePicturePresenter?.resultHandler = { [weak self] success, previewImage, mediaURL in
            defer {
                self?.dismiss(animated: true, completion: nil)
            }
            
            guard success, let previewImage = previewImage, let mediaURL = mediaURL else {
                return
            }
            self?.dataSource?.useNewAvatar(previewImage, fileURL: mediaURL)
        }
        profilePicturePresenter?.present(on: self)
    }

    fileprivate func animateErrorInThenOut(_ localizedErrorString: String) {
        self.validationErrorLabel.text = localizedErrorString
        self.animateErrorIn()
    }
    
    fileprivate func animateErrorIn() {
        UIView.animate(
            withDuration: Constants.animationDuration,
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
    
    fileprivate func animateErrorOut() {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            let validationViewSize = self.validationView.systemLayoutSizeFitting(self.view.bounds.size)
            self.validationViewTopToLayoutGuideBottomConstraint.constant = -validationViewSize.height
            self.view.layoutIfNeeded()
        })
    }
}

private extension VDependencyManager {
    var userValidationAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "username.validity.URL")
    }
}
