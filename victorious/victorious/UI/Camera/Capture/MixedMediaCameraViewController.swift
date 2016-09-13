//
//  MixedMediaCameraViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import MBProgressHUD

/// Manages a camera that allows the user to take a video or capture a still image
class MixedMediaCameraViewController: UIViewController, VCaptureVideoPreviewViewDelegate, VCameraVideoEncoderDelegate {
    
    private struct Constants {
        static let verySmallInnerRadius: CGFloat = 0
        static let verySmallOuterRadius: CGFloat = 0.01
        static let gradientDelta: CGFloat = 20
        static let errorMessageDisplayDuration: NSTimeInterval = 2
        static let maxImageDimension: CGFloat = 640
        static let videoSize = VCameraCaptureVideoSize(width: 640, height: 640)
    }
    
    weak var delegate: MixedMediaCameraViewControllerDelegate?
    
    private var dependencyManager: VDependencyManager!
    
    private var cameraContext: VCameraContext! {
        didSet {
            cameraCaptureController.context = cameraContext
        }
    }
    
    private let cameraCaptureController: VCameraCaptureController = {
        let captureController = VCameraCaptureController()
        captureController.setSessionPreset(AVCaptureSessionPresetHigh, completion: { _ in })
        return captureController
    }()
    
    private lazy var permissionsController: VCameraPermissionsController = VCameraPermissionsController.init(viewControllerToPresentOn: self)
    
    // MARK: - Views created after view loads
    
    private var coachMarkAnimator: VCameraCoachMarkAnimator!
        
    // MARK: - State vars
    
    private var isTrashOpen: Bool = false {
        didSet {
            updateAppearanceOfTrashButton()
        }
    }
    
    private var totalTimeRecorded: Float64 = 0 {
        didSet {
            updateRightBarButtonItem()
        }
    }
    
    private var userDeniedPrePrompt: Bool = false
    
    private var savedVideoURL: NSURL? = nil
    
    private var previewImage: UIImage? = nil
    
    lazy private var maximumRecordingDuration: Float64 = {
        guard let duration = VCurrentUser.user?.maxVideoUploadDuration else {
            return 0
        }
        
        return Float64(duration)
    }()
    
    private var previewViewRadialHypotenuse: CGFloat {
        
        guard isViewLoaded() else {
            return 0
        }
        
        let horizontalDimension = previewView.bounds.width / 2
        let verticalDimension = previewView.bounds.height / 2
        let sumOfDimensionSquares = (horizontalDimension * horizontalDimension) + (verticalDimension * verticalDimension)
        return sqrt(sumOfDimensionSquares)
    }
    
    // MARK: - Outlets
    
    // Intentionally strong because they aren't subviews
    
    @IBOutlet private var switchCameraButton: CameraDirectionButton!
    
    @IBOutlet private var flashBarButtonItem: CameraFlashBarButtonItem!
    
    @IBOutlet private var nextBarButtonItem: CameraNextBarButtonItem!
    
    // Weak because these are always retained by view
    
    @IBOutlet weak private var coachMarkLabel: UILabel!
    
    @IBOutlet weak private var cameraControl: VCameraControl!
    
    @IBOutlet weak private var trashButton: UIButton!
    
    @IBOutlet weak private var previewView: VCaptureVideoPreviewView!
    
    @IBOutlet weak private var capturedImageView: UIImageView!
    
    @IBOutlet weak private var shutterView: VRadialGradientView!
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> MixedMediaCameraViewController {
        
        let cameraViewController: MixedMediaCameraViewController = self.v_initialViewControllerFromStoryboard()
        cameraViewController.dependencyManager = dependencyManager
        return cameraViewController
    }
    
    class func mixedMediaCamera(dependencyManager: VDependencyManager, cameraContext: VCameraContext) -> MixedMediaCameraViewController {
        
        let cameraViewController = dependencyManager.templateValueOfType(MixedMediaCameraViewController.self, forKey: "mixedMediaCameraScreen") as! MixedMediaCameraViewController
        cameraViewController.cameraContext = cameraContext
        return cameraViewController
    }
    
    // MARK: - Lifecycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventCameraUserDidEnter)
        coachMarkAnimator = VCameraCoachMarkAnimator(coachView: coachMarkLabel)
        coachMarkLabel.text = NSLocalizedString("MixedMediaCoachMessage", comment: "")
        registerButtonActions()
        styleButtons()
        navigationItem.titleView = switchCameraButton
        setupTrashButton()
        setupShutterView()
        updateRightBarButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventCameraUserDidEnter)
        checkPermissions(onSuccess: {
            self.startCaptureSession()
            self.cameraCaptureController.setVideoOrientation(UIDevice.currentDevice().orientation)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateOrientation), name: UIDeviceOrientationDidChangeNotification, object: nil)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let boundsCenter = CGPoint(x: shutterView.bounds.midX, y: shutterView.bounds.midY)
        shutterView.innerCenter = boundsCenter
        shutterView.outerCenter = boundsCenter
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventCameraDidAppear)
        coachMarkAnimator.fadeIn(1)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventCameraUserDidExit)
        cameraCaptureController.videoEncoder = nil
        cameraControl.restoreCameraControlToDefault()
        previewView.hidden = false
        clearRecordedVideoAndResetControl()
    }
    
    // MARK: - Button setup
    
    private func registerButtonActions() {
        
        flashBarButtonItem.interactiveButton.addTarget(self, action: #selector(switchFlashAction), forControlEvents: .TouchUpInside)
        
        cameraControl.addTarget(self, action: #selector(startRecordingVideo), forControlEvents: UIControlEvents(rawValue: UInt(VCameraControlEventStartRecordingVideo)))
        cameraControl.addTarget(self, action: #selector(endRecordingVideo), forControlEvents: UIControlEvents(rawValue: UInt(VCameraControlEventEndRecordingVideo)))
        cameraControl.addTarget(self, action: #selector(failedRecordingVideo), forControlEvents: UIControlEvents(rawValue: UInt(VCameraControlEventFailedRecordingVideo)))
        cameraControl.addTarget(self, action: #selector(takePicture), forControlEvents: UIControlEvents(rawValue: UInt(VCameraControlEventWantsStillImage)))
        
        nextBarButtonItem.target = self
        nextBarButtonItem.action = #selector(nextAction)
    }
    
    private func styleButtons() {
        
        flashBarButtonItem.dependencyManager = dependencyManager
        nextBarButtonItem.dependencyManager = dependencyManager
        switchCameraButton.dependencyManager = dependencyManager
    }
    
    private func setupTrashButton() {
        trashButton.layer.masksToBounds = true
        trashButton.layer.cornerRadius = trashButton.bounds.width / 2
    }
    
    private func setupShutterView() {
        
        let boundsCenter = CGPoint(x: shutterView.bounds.midX, y: shutterView.bounds.midY)
        shutterView.innerRadius = 0
        shutterView.innerCenter = boundsCenter
        shutterView.colors = [UIColor.clearColor(), UIColor.blackColor()]
        shutterView.outerRadius = 5
        shutterView.outerCenter = boundsCenter
    }
    
    // MARK: - View state updating
    
    private func updateAppearanceOfTrashButton() {
        if isTrashOpen {
            trashButton.hidden = false
            trashButton.backgroundColor = UIColor.redColor()
        } else {
            trashButton.hidden = true
            trashButton.backgroundColor = UIColor.clearColor()
        }
    }
    
    private func updateRightBarButtonItem() {
        let hasRecordedVideoContent = totalTimeRecorded > 0
        let rightBarButtonItem = hasRecordedVideoContent ? nextBarButtonItem : flashBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    // MARK: - VCaptureVideoPreviewViewDelegate
    
    func captureVideoPreviewView(previewView: VCaptureVideoPreviewView!, tappedLocation locationInCaptureDeviceCoordinates: CGPoint) {
        cameraCaptureController.focusAtPointOfInterest(locationInCaptureDeviceCoordinates, withCompletion: { _ in })
    }
    
    func shouldShowTapsForVideoPreviewView(previewView: VCaptureVideoPreviewView!) -> Bool {
        guard let currentDevice = cameraCaptureController.currentDevice else {
            return false
        }
        
        return currentDevice.focusPointOfInterestSupported
    }
    
    // MARK: - Notification response
    
    @objc private func startRecordingVideo() {
        if setupEncoderIfNeeded() {
            cameraCaptureController.videoEncoder?.recording = true
        }
        switchCameraButton.enabled = false
        coachMarkAnimator.fadeOut(1)
    }
    
    @objc private func endRecordingVideo() {
        cameraCaptureController.videoEncoder?.recording = false
        switchCameraButton.enabled = true
        updateOrientation()
    }
    
    @objc private func failedRecordingVideo() {
        coachMarkAnimator.flash()
    }
    
    @objc private func takePicture() {
        coachMarkAnimator.fadeOut(1)
        cameraControl.flashGrowAnimations()
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventCameraDidCapturePhoto)
        switchCameraButton.enabled = false
        flashBarButtonItem.enabled = false
        cameraCaptureController.captureStillWithCompletion { [weak self] image, error in
            
            guard let strongSelf = self else {
                return
            }
            
            if error != nil {
                strongSelf.updateFlashStateForCurrentDevice()
                strongSelf.switchCameraButton.enabled = strongSelf.cameraCaptureController.firstAlternatePositionDevice() != nil
                strongSelf.cameraControl.restoreCameraControlToDefault()
            } else {
                strongSelf.finishWithImage(image)
            }
        }
    }
    
    private func finishWithImage(image: UIImage?) {
        guard let image = image,
            let currentDevice = cameraCaptureController.currentDevice else {
                displayTemporaryHUDWithMessage(NSLocalizedString("ImageCaptureFailed", comment: ""))
            return
        }
        
        let wasTakenByFrontCamera = currentDevice.position == .Front
        self.capturedImageView.transform = wasTakenByFrontCamera ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformIdentity
        self.capturedImageView.image = image
        self.previewView.hidden = true
        self.animateShutterOpenWithCompletion { [weak self] in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                guard let strongSelf = self else {
                    return
                }
                
                let previewImage = image.fixOrientation().scaledImageWithMaxDimension(Constants.maxImageDimension, upScaling: false).squareImageByCropping()
                guard let savedFileURL = strongSelf.persistToFileWithImage(previewImage),
                    let delegate = strongSelf.delegate else {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    delegate.mixedMediaCameraViewController(strongSelf, capturedImageWithMediaURL: savedFileURL, previewImage: previewImage)
                }
            }
        }
    }
    
    private func persistToFileWithImage(image: UIImage) -> NSURL? {
        guard let fileURL = NSURL.v_temporaryFileURLWithExtension(VConstantMediaExtensionJPG, inDirectory: kCameraDirectory) else {
            return nil
        }
        let jpegData = UIImageJPEGRepresentation(image, VConstantJPEGCompressionQuality)
        jpegData?.writeToURL(fileURL, atomically: true)
        return fileURL
    }
    
    // MARK: - Actions
    
    @objc private func nextAction() {
        cameraCaptureController.videoEncoder?.finishRecording()
    }
    
    @IBAction private func trashAction() {
        trashButton.backgroundColor = isTrashOpen ? UIColor.clearColor() : UIColor.redColor()
        let eventName = isTrashOpen ? VTrackingEventCameraUserDidConfirmDelete : VTrackingEventCameraUserDidSelectDelete
        VTrackingManager.sharedInstance().trackEvent(eventName)
        if isTrashOpen {
            cameraCaptureController.videoEncoder = nil
            resetAllControls()
            nextBarButtonItem.enabled = false
        }
        isTrashOpen = !isTrashOpen
    }
    
    @IBAction private func reverseCameraAction() {
        guard let deviceForPosition = cameraCaptureController.firstAlternatePositionDevice() else {
            return
        }
        
        cameraCaptureController.setCurrentDevice(deviceForPosition) { [weak self] error in
            dispatch_async(dispatch_get_main_queue()) {
                guard error == nil else {
                    return
                }
                self?.updateFlashStateForCurrentDevice()
            }
        }
    }
    
    @objc private func switchFlashAction() {
        
        cameraCaptureController.toggleFlashWithCompletion() { [weak self] error in
            dispatch_async(dispatch_get_main_queue()) {
                self?.updateFlashStateForCurrentDevice()
            }
        }
    }
    
    @objc private func updateOrientation() {
        if let videoEncoder = cameraCaptureController.videoEncoder where videoEncoder.recording {
            return
        }
        
        cameraCaptureController.setVideoOrientation(UIDevice.currentDevice().orientation)
    }
    
    // MARK: - VCameraVideoEncoderDelegate
    
    func videoEncoder(videoEncoder: VCameraVideoEncoder!, didEncounterError error: NSError!) {
        dispatch_async(dispatch_get_main_queue()) {
            videoEncoder.recording = false
            self.updateRightBarButtonItem()
            self.displayTemporaryHUDWithMessage(NSLocalizedString("VideoCaptureFailed", comment: ""))
        }
    }
    
    func videoEncoder(videoEncoder: VCameraVideoEncoder!, hasEncodedTotalTime time: CMTime) {
        
        dispatch_async(dispatch_get_main_queue()) {
            let seconds = CMTimeGetSeconds(time)
            self.updateProgressForSeconds(seconds)
            if seconds >= self.maximumRecordingDuration {
                self.endRecordingVideo()
                self.nextAction()
            }
            if seconds >= 0 {
                self.nextBarButtonItem.enabled = true
                self.trashButton.hidden = false
            }
        }
    }
    
    func videoEncoderDidFinish(encoder: VCameraVideoEncoder, withError error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            guard error == nil else {
                self.displayTemporaryHUDWithMessage(NSLocalizedString("VideoSaveFailed", comment: ""))
                return
            }
            
            guard let fileURL = encoder.fileURL,
                let previewImage = fileURL.v_videoPreviewImage else {
                return
            }
            
            self.savedVideoURL = fileURL
            self.previewImage = previewImage
            self.cameraCaptureController.videoEncoder = nil
            if self.cameraCaptureController.captureSession.running {
                self.cameraCaptureController.stopRunningWithCompletion() { [weak self] in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.delegate?.mixedMediaCameraViewController(strongSelf, capturedImageWithMediaURL: fileURL, previewImage: previewImage)
                }
            }
        }
    }
    
    // MARK: - Capture state management
    
    private func checkPermissions(onSuccess completion: Void -> ()) {
        guard !userDeniedPrePrompt else {
            return
        }
        
        let cameraPermission = VPermissionCamera.init(dependencyManager: dependencyManager)
        permissionsController.requestPermissionWithPermission(cameraPermission) {deniedPrePrompt, state in
            
            self.userDeniedPrePrompt = deniedPrePrompt
            guard !deniedPrePrompt && state == .Authorized else {
                self.switchCameraButton.enabled = false
                self.cameraControl.enabled = false
                return
            }
            
            let microphonePermission = VPermissionMicrophone.init(dependencyManager: self.dependencyManager)
            self.permissionsController.requestPermissionWithPermission(microphonePermission, completion: { deniedPrePrompt, state in
                
                self.userDeniedPrePrompt = deniedPrePrompt
                guard !deniedPrePrompt && state == .Authorized else {
                    self.switchCameraButton.enabled = false
                    self.cameraControl.enabled = false
                    return
                }
                
                completion()
            })
        }
    }
    
    private func startCaptureSession() {
        let captureSession = cameraCaptureController.captureSession
        previewView.session = captureSession
        guard !captureSession.running else {
            resetAllControls()
            return
        }
        
        cameraCaptureController.startRunningWithVideoEnabled(true) { [weak self] error in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.animateShutterOpenWithCompletion(nil)
                
                if error != nil {
                    
                    strongSelf.displayTemporaryHUDWithMessage(NSLocalizedString("CameraFailed", comment: ""))
                }
                strongSelf.setupCapturingKVO()
                strongSelf.resetAllControls()
            })
            
        }
    }
    
    private func setupEncoderIfNeeded() -> Bool {
        guard cameraCaptureController.videoEncoder == nil else {
            return true
        }
        
        do {
            let encoder = try VCameraVideoEncoder(maximumOutputSideLength: Int(cameraCaptureController.maxOutputSideLength), dependencyManager: dependencyManager)
            cameraCaptureController.videoEncoder = encoder
            encoder.delegate = self
            encoder.recording = true
            return true
        } catch {
            displayTemporaryHUDWithMessage(NSLocalizedString("VideoCaptureFailed", comment: ""))
            nextBarButtonItem.enabled = false
            return false
        }
    }
    
    private func setupCapturingKVO() {
        
        KVOController.observe(cameraCaptureController.imageOutput, keyPath: "capturingStillImage", options: [] as NSKeyValueObservingOptions) { [weak self] (observer, imageOutput, change) in
            
            let imageOutput = imageOutput as! AVCaptureStillImageOutput
            guard let strongSelf = self else {
                return
            }
            
            if imageOutput.capturingStillImage {
                strongSelf.animateShutterCloseWithCompletion(nil)
            }
        }
    }
    
    // MARK: - View updating
    
    private func resetAllControls() {
        clearRecordedVideoAndResetControl()
        updateFlashStateForCurrentDevice()
        updateSwitchCameraButton()
    }
    
    private func clearRecordedVideoAndResetControl() {
        updateProgressForSeconds(0)
        cameraControl.restoreCameraControlToDefault()
        nextBarButtonItem.enabled = false
    }
    
    private func updateProgressForSeconds(seconds: Float64) {
        totalTimeRecorded = seconds
        
        let progress = CGFloat(seconds / maximumRecordingDuration)
        cameraControl.setRecordingProgress(progress, animated: true)
    }
    
    private func updateFlashStateForCurrentDevice() {

        guard let currentDevice = cameraCaptureController.currentDevice else {
            assertionFailure("Mixed Media Camera's Camera Capture Controller cannot update flash")
            return
        }
        
        let hasFlash = currentDevice.hasFlash
        let flashEnabled = currentDevice.flashMode == .On
        flashBarButtonItem.interactiveButton.hidden = !hasFlash
        flashBarButtonItem.enabled = hasFlash
        flashBarButtonItem.interactiveButton.selected = flashEnabled
    }
    
    private func updateSwitchCameraButton() {
        let canSwitchCamera = cameraCaptureController.firstAlternatePositionDevice() != nil
        switchCameraButton.hidden = !canSwitchCamera
        switchCameraButton.enabled = canSwitchCamera
    }
    
    // MARK: - Shutter management
    
    private func animateShutterOpenWithCompletion(completion: (Void -> ())?) {
        
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [] as UIViewAnimationOptions, animations: {
            self.shutterView.innerRadius = self.previewViewRadialHypotenuse
            self.shutterView.outerRadius = self.previewViewRadialHypotenuse + Constants.gradientDelta
            }, completion: { _ in
                completion?()
        })
    }
    
    private func animateShutterCloseWithCompletion(completion: (Void -> ())?) {
        
        UIView.animateWithDuration(0.15, delay: 0, options: [] as UIViewAnimationOptions, animations: {
            self.cameraControl.flashShutterAnimations()
            self.shutterView.innerRadius = Constants.verySmallInnerRadius
            self.shutterView.outerRadius = Constants.verySmallOuterRadius
            }, completion: { _ in
                completion?()
        })
    }
    
    private func displayTemporaryHUDWithMessage(message: String) {
        let hud = MBProgressHUD.showHUDAddedTo(previewView, animated: true)
        hud.mode = .Text
        hud.labelText = message
        hud.hide(true, afterDelay: Constants.errorMessageDisplayDuration)
    }
}
