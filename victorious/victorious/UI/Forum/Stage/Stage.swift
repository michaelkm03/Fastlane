//
//  Stage.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Stage: class, ForumEventReceiver, StageShrinkingAnimatorDelegate {
    weak var delegate: StageDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }

    /// Replaces the current content on the stage with the content present in the StageContent.
    /// StageContent may also contain meta data about the item on stage.
    func addStageContent(stageContent: StageContent)
    
    /// Shows the caption of the provided content in the caption bar (if provided in the template)
    func addCaptionContent(content: ContentModel)
    
    /// Removes the current content on the stage.
    func removeContent()
}

/// Conformers will recieve messages related to the stage resizing.
protocol StageDelegate: class {
    func stage(stage: Stage, wantsUpdateToContentHeight size: CGFloat)
}
