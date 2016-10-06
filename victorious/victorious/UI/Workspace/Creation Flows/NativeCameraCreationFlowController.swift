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
    fileprivate var audioSessionCategory = AVAudioSessionCategoryAmbient
    
    fileprivate var trackedAppear = false
    
    static let maxImageDimension: CGFloat = 640
    
    fileprivate var isRecordingVideo: Bool {
        return imagePickerController?.cameraCaptureMode == .video
    }
    
    fileprivate lazy var imagePickerController: UIImagePickerController? = {
        let pickerSourceType = UIImagePickerControllerSourceType.camera
        guard let mediaTypes = UIImagePickerController.availableMediaTypes(for: pickerSourceType) else {
            assertionFailure("Have no available media types for this device!")
            return nil
        }
        
        let nativeCamera = UIImagePickerController()
        nativeCamera.sourceType = pickerSourceType
        nativeCamera.videoQuality = .typeHigh
        nativeCamera.showsCameraControls = true
        nativeCamera.allowsEditing = true
        nativeCamera.mediaTypes = mediaTypes
        nativeCamera.cameraCaptureMode = .photo
        nativeCamera.delegate = self
        nativeCamera.transitioningDelegate = self
        
        //Add a passthrough view on top of the whole UIImagePickerController since it isn't kvo
        //compliant for key cameraCaptureMode, doesn't support subclassing, and leaves no other
        //means (that I can find) of updating "allowsEditing" based on current cameraCaptureMode
        let passthroughView = VPassthroughContainerView(frame: UIScreen.main.bounds)
        passthroughView.delegate = self
        nativeCamera.cameraOverlayView = passthroughView
        return nativeCamera
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func rootFlowController() -> UINavigationController! {
        if !trackedAppear {
            trackedAppear = true
            dependencyManager.trackViewWillAppear(for: self)
            NotificationCenter.default.addObserver(self, selector: #selector(enteredBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            audioSessionCategory = AVAudioSession.sharedInstance().category
        }
        
        //Return image picker controller or empty creation flow (by returning self)
        return imagePickerController ?? self
    }
    
    override func mediaType() -> MediaType {
        return isRecordingVideo ? .video : .image
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dependencyManager.trackViewWillDisappear(for: self)
        let _ = try? AVAudioSession.sharedInstance().setCategory(audioSessionCategory)
        creationFlowDelegate.creationFlowControllerDidCancel?(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            dependencyManager.trackViewWillDisappear(for: self)
            let _ = try? AVAudioSession.sharedInstance().setCategory(audioSessionCategory)
        }
        
        if let mediaURL = info[UIImagePickerControllerMediaURL] as? URL,
            let image = mediaURL.v_videoPreviewImage {
            
            //Video
            creationFlowDelegate.creationFlowController(self, finishedWithPreviewImage: image, capturedMediaURL: mediaURL)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let rotatedImage = image.fixOrientation(),
            let imageData = UIImageJPEGRepresentation(rotatedImage, VConstantJPEGCompressionQuality),
            let mediaURL = NSURL.v_temporaryFileURL(withExtension: VConstantMediaExtensionPNG, inDirectory: kThumbnailDirectory) {
            
            //Image
            try? imageData.write(to: mediaURL, options: .atomic)
            creationFlowDelegate.creationFlowController(self, finishedWithPreviewImage: rotatedImage, capturedMediaURL: mediaURL)
        } else {
            creationFlowDelegate.creationFlowControllerDidCancel?(self)
        }
    }
    
    // MARK: - Notification Response
    
    dynamic fileprivate func enteredBackground() {
        audioSessionCategory = AVAudioSessionCategoryAmbient
    }
    
    // MARK: - Editing mode hack
    
    
    func passthroughViewRecievedTouch(_ passthroughContainerView: VPassthroughContainerView!) {
        let recordingVideo = isRecordingVideo
        if let imagePickerController = imagePickerController , imagePickerController.allowsEditing != recordingVideo {
            imagePickerController.allowsEditing = recordingVideo
        }
    }
}
