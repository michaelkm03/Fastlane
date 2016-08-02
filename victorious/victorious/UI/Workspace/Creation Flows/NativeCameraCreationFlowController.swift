//
//  NativeCameraCreationFlowController.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import AVFoundation
import UIKit

class NativeCameraCreationFlowController: VCreationFlowController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VPassthroughContainerViewDelegate {
    private var audioSessionCategory = AVAudioSessionCategoryAmbient
    
    private var trackedAppear = false
    
    static let maxImageDimension: CGFloat = 640
    
    private var isRecordingVideo: Bool {
        return imagePickerController?.cameraCaptureMode == .Video
    }
    
    private lazy var imagePickerController: UIImagePickerController? = {
        let pickerSourceType = UIImagePickerControllerSourceType.Camera
        guard let mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickerSourceType) else {
            assertionFailure("Have no available media types for this device!")
            return nil
        }
        
        let nativeCamera = UIImagePickerController()
        nativeCamera.sourceType = pickerSourceType
        nativeCamera.videoQuality = .TypeHigh
        nativeCamera.showsCameraControls = true
        nativeCamera.allowsEditing = true
        nativeCamera.mediaTypes = mediaTypes
        nativeCamera.cameraCaptureMode = .Photo
        nativeCamera.delegate = self
        nativeCamera.transitioningDelegate = self
        
        //Add a passthrough view on top of the whole UIImagePickerController since it isn't kvo
        //compliant for key cameraCaptureMode, doesn't support subclassing, and leaves no other
        //means (that I can find) of updating "allowsEditing" based on current cameraCaptureMode
        let passthroughView = VPassthroughContainerView(frame: UIScreen.mainScreen().bounds)
        passthroughView.delegate = self
        nativeCamera.cameraOverlayView = passthroughView
        return nativeCamera
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func rootFlowController() -> UINavigationController! {
        if !trackedAppear {
            trackedAppear = true
            dependencyManager.trackViewWillAppear(self)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(enteredBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
            audioSessionCategory = AVAudioSession.sharedInstance().category
        }
        
        //Return image picker controller or empty creation flow (by returning self)
        return imagePickerController ?? self
    }
    
    override func mediaType() -> MediaType {
        return isRecordingVideo ? .Video : .Image
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dependencyManager.trackViewWillDisappear(self)
        let _ = try? AVAudioSession.sharedInstance().setCategory(audioSessionCategory)
        creationFlowDelegate.creationFlowControllerDidCancel?(self)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        defer {
            dependencyManager.trackViewWillDisappear(self)
            let _ = try? AVAudioSession.sharedInstance().setCategory(audioSessionCategory)
        }
        
        if let mediaURL = info[UIImagePickerControllerMediaURL] as? NSURL,
            let image = mediaURL.v_videoPreviewImage {
            
            //Video
            creationFlowDelegate.creationFlowController(self, finishedWithPreviewImage: image, capturedMediaURL: mediaURL)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let rotatedImage = image.fixOrientation(),
            let imageData = UIImageJPEGRepresentation(rotatedImage, VConstantJPEGCompressionQuality),
            let mediaURL = NSURL.v_temporaryFileURLWithExtension(VConstantMediaExtensionPNG, inDirectory: kThumbnailDirectory) {
            
            //Image
            imageData.writeToURL(mediaURL, atomically: true)
            creationFlowDelegate.creationFlowController(self, finishedWithPreviewImage: rotatedImage, capturedMediaURL: mediaURL)
        } else {
            creationFlowDelegate.creationFlowControllerDidCancel?(self)
        }
    }
    
    // MARK: - Notification Response
    
    dynamic private func enteredBackground() {
        audioSessionCategory = AVAudioSessionCategoryAmbient
    }
    
    // MARK: - Editing mode hack
    
    func passthroughViewRecievedTouch(passthroughContainerView: VPassthroughContainerView!) {
        let recordingVideo = isRecordingVideo
        if let imagePickerController = imagePickerController where imagePickerController.allowsEditing != recordingVideo {
            imagePickerController.allowsEditing = recordingVideo
        }
    }
}
