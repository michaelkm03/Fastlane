//
//  Stage.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Stage: class, ForumEventReceiver {
    
    weak var delegate: StageDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    var canHandleCaptionContent: Bool { get }
    
    /// Replaces the current content on the stage with the new one.
    func addContent(stageContent: ContentModel)
    
    /// Shows the caption of the provided content in the caption bar (if provided in the template)
    func addCaptionContent(content: ContentModel)
    
    /// Removes the current content on the stage.
    func removeContent()
}

/// Conformers will recieve messages related to the stage resizing.
protocol StageDelegate: class {
    func stage(stage: Stage, wantsUpdateToContentHeight size: CGFloat)
}
