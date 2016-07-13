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
    
    /// This will allow callers to change the opacity of overlays in the stage (caption/attribution/refresh pill).
    var overlayUIAlpha: CGFloat { get set }
    
    var canHandleCaptionContent: Bool { get }
    
    /// Replaces the current content on the stage with the new one. StageMetaData provides additional information about the content on stage. Send in nil to clear out the meta data.
    func addContent(stageContent: ContentModel, stageMetaData: StageMetaData?)
    
    /// Shows the caption of the provided content in the caption bar (if provided in the template)
    func addCaptionContent(content: ContentModel)
    
    /// Removes the current content on the stage.
    func removeContent()
    
    /// Determines whether the stage component is enabled to show up.
    func setStageEnabled(enabled: Bool, animated: Bool)
}

/// Conformers will recieve messages related to the stage resizing.
protocol StageDelegate: class {
    func stage(stage: Stage, wantsUpdateToContentHeight size: CGFloat)
}
