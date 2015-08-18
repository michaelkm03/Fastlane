//
//  CommentsViewController+KeyboardBar.swift
//  victorious
//
//  Created by Michael Sena on 8/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension CommentsViewController: VKeyboardInputAccessoryViewDelegate, VUserTaggingTextStorageDelegate {
    
    // MARK: - VKeyboardInputAccessoryViewDelegate
    
    func pressedSendOnKeyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView) {
        if let authorizedAction = authorizedAction {
            authorizedAction.performFromViewController(self,
                context: .AddComment,
                completion: { [weak self](authorized: Bool) -> Void in
                    if !authorized {
                        return
                    }
                    if let strongSelf = self, let sequence = strongSelf.sequence {
                        VObjectManager.sharedManager().addCommentWithText(inputAccessoryView.composedText,
                            publishParameters: strongSelf.publishParameters,
                            toSequence: sequence,
                            andParent: nil,
                            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) -> Void in
                                strongSelf.commentsDataSourceSwitcher.dataSource.loadFirstPage()
                            }, failBlock: nil)
                        
                        strongSelf.keyboardBar?.clearTextAndResign()
                        strongSelf.publishParameters?.mediaToUploadURL = nil
                    }
                })
        }
    }
    
    func keyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView, selectedAttachmentType attachmentType: VKeyboardBarAttachmentType) {
        
        inputAccessoryView.stopEditing()
        
        self.authorizedAction.performFromViewController(self, context: .AddComment) { [weak self](authorized: Bool) -> Void in
            if !authorized {
                return
            }
            if let strongSelf = self {
                strongSelf.addMediaToCommentWithAttachmentType(attachmentType)
            }
        }
    }
    
    func addMediaToCommentWithAttachmentType(attachmentType: VKeyboardBarAttachmentType) {
        
        mediaAttachmentPresenter = VMediaAttachmentPresenter(dependencymanager: dependencyManager)
        
        var mediaAttachmentOptions : VMediaAttachmentOptions
        switch attachmentType {
        case .Video:
            mediaAttachmentOptions = VMediaAttachmentOptions.Video
        case .GIF:
            mediaAttachmentOptions = VMediaAttachmentOptions.GIF
        case .Image:
            mediaAttachmentOptions = VMediaAttachmentOptions.Image
        }
        
        mediaAttachmentPresenter?.attachmentTypes = mediaAttachmentOptions
        mediaAttachmentPresenter?.resultHandler = { [weak self](success: Bool, publishParameters: VPublishParameters?) -> Void in
            if let strongSelf = self {
                strongSelf.publishParameters = publishParameters
                strongSelf.mediaAttachmentPresenter = nil
                strongSelf.keyboardBar?.setSelectedThumbnail(publishParameters?.previewImage)
                strongSelf.keyboardBar?.startEditing()
                strongSelf.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        mediaAttachmentPresenter?.presentOnViewController(self)
    }
    
    func keyboardInputAccessoryViewWantsToClearMedia(inputAccessoryView: VKeyboardInputAccessoryView) {
        
        let shouldResumeEditing = inputAccessoryView.isEditing()
        inputAccessoryView.stopEditing()
        
        let alertController = VCommentAlertHelper.alertForConfirmDiscardMediaWithDelete({ () -> Void in
            self.publishParameters?.mediaToUploadURL = nil
            inputAccessoryView.setSelectedThumbnail(nil)
            if shouldResumeEditing {
                inputAccessoryView.startEditing()
            }
            }, cancel: { () -> Void in
                if shouldResumeEditing {
                    inputAccessoryView.startEditing()
                }
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func keyboardInputAccessoryViewDidBeginEditing(inpoutAccessoryView: VKeyboardInputAccessoryView) {
        updateInsetForKeyboardBarState()
    }
    
    func keyboardInputAccessoryViewDidEndEditing(inpoutAccessoryView: VKeyboardInputAccessoryView) {
        updateInsetForKeyboardBarState()
    }
    
    // MARK: - VUserTaggingTextStorageDelegate
    
    func userTaggingTextStorage(textStorage: VUserTaggingTextStorage!, wantsToShowViewController viewController: UIViewController!) {
        
        keyboardBar?.attachmentsBarHidden = true
        
        var searchTableView = viewController.view
        searchTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(searchTableView)
        if let ownWindow = view.window, keyboardBar = keyboardBar {
            var obscuredRectInWindow = keyboardBar.obscuredRectInWindow(ownWindow)
            var obscuredRecInOwnView = ownWindow.convertRect(obscuredRectInWindow, toView: view)
            var obscuredBottom = CGRectGetHeight(view.bounds) - CGRectGetMinY(obscuredRecInOwnView)
            view.v_addFitToParentConstraintsToSubview(searchTableView, leading: 0, trailing: 0, top: topLayoutGuide.length, bottom: obscuredBottom)
        }
        
    }
    
    func userTaggingTextStorage(textStorage: VUserTaggingTextStorage!, wantsToDismissViewController viewController: UIViewController!) {
        
        viewController.view.removeFromSuperview()
        keyboardBar?.attachmentsBarHidden = false
    }
    
}
