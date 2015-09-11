//
//  PollSequencePreviewView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class PollSequencePreviewView : VSequencePreviewView {
    
    @IBOutlet private weak var answerContainerA: UIView!
    @IBOutlet private weak var answerContainerB: UIView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var answerLabelA: UILabel!
    @IBOutlet private weak var answerLabelB: UILabel!
    @IBOutlet private weak var questionMarkImage: UIImageView!
    
    @IBOutlet private weak var questionMarkImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var answersContainerToCotainerBottom: NSLayoutConstraint!
    @IBOutlet private weak var answersContainerToCaptionLabel: NSLayoutConstraint!
    
    weak var answerViewA: PollAnswerView!
    weak var answerViewB: PollAnswerView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        answerViewA = PollAnswerView.v_fromNib(nibNameOrNil: "PollSequencePreviewView" ) as PollAnswerView
        answerContainerA.addSubview( answerViewA )
        answerContainerA.v_addFitToParentConstraintsToSubview( answerViewA )
        
        answerViewB = PollAnswerView.v_fromNib(nibNameOrNil: "PollSequencePreviewView" ) as PollAnswerView
        answerContainerB.addSubview( answerViewB )
        answerContainerB.v_addFitToParentConstraintsToSubview( answerViewB )
        
        answersContainerToCotainerBottom.active = false
    }
    
    override func setSequence(sequence: VSequence!) {
        super.setSequence( sequence )
        
        let assetFinder = VImageAssetFinder()
        if let previewAssets = sequence.previewAssets,
            let answerA = assetFinder.answerAFromAssets( previewAssets ) ?? sequence.firstNode().answerA(),
            let answerB = assetFinder.answerBFromAssets( previewAssets ) ?? sequence.firstNode().answerB() {
                answerViewA.answer = answerA
                answerViewB.answer = answerB
        }
    }
    
    func expandToShowDetail() {
        countLabel.hidden = false
        answersContainerToCotainerBottom.active = false
        answersContainerToCaptionLabel.active = true
        answersContainerToCaptionLabel.constant = 0.0
        questionMarkImageBottomConstraint.constant = 0.0
    }
    
    func collapseToHideDetail() {
        countLabel.hidden = true
        answersContainerToCotainerBottom.active = true
        answersContainerToCotainerBottom.constant = 0.0
        answersContainerToCaptionLabel.active = false
        questionMarkImageBottomConstraint.constant = 100
    }
}

class PollAnswerView: UIView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var videoContainer: UIView!
    @IBOutlet private weak var button: UIView!
    @IBOutlet private weak var resultView: UIView!
    
    @IBOutlet private weak var resultConstraintLeft: NSLayoutConstraint!
    @IBOutlet private weak var resultConstraintRight: NSLayoutConstraint!
    
    var answer: VAnswer! {
        didSet {
            imageView.sd_setImageWithURL( answer.previewMediaURL() )
        }
    }
    
    // MARK: - Result View Alignment
    
    func alignResultRight() {
        updateResultConsraint( resultConstraintLeft )
    }
    
    func alignResultLeft() {
        updateResultConsraint( resultConstraintRight )
    }
    
    private func updateResultConsraint( constraint: NSLayoutConstraint ) {
        constraint.constant = self.frame.width - self.resultView.frame.width
        self.layoutIfNeeded()
    }
}