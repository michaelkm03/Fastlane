//
//  VCreatePollViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VCreatePollViewController {
    
    func createPoll() {
        guard let questionText = self.questionTextView?.text,
            let leftAnswer = self.leftAnswerTextView?.text,
            let rightAnswer = self.rightAnswerTextView?.text else {
                return
        }
        
        let parameters = PollParameters(
            name: questionText,
            question: questionText,
            description: "<none>",
            answers: [
                PollAnswer(
                    label: leftAnswer,
                    mediaURL: self.firstMediaURL
                ),
                PollAnswer(
                    label: rightAnswer,
                    mediaURL: self.secondMediaURL
                )
            ]
        )
        
        let previewImage = leftPreviewImageView?.image ?? UIImage()
        let uploadManager = VUploadManager.sharedManager()
        guard let operation = CreatePollOperation(parameters: parameters, previewImage: previewImage, uploadManager: uploadManager) else {
            return
        }
        
        operation.queue()
    }
}
