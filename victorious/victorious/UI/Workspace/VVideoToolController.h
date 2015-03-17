//
//  VVideoToolController.h
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolController.h"

extern NSString * const VVideoToolControllerInitalVideoEditStateKey;
typedef NS_ENUM(NSInteger, VVideoToolControllerInitialVideoEditState)
{
    VVideoToolControllerInitialVideoEditStateVideo,
    VVideoToolControllerInitialVideoEditStateGIF, // Default
    VVideoToolControllerInitialVideoEditStateMeme
};

@class VVideoToolController;

@protocol VVideoToolControllerDelegate <NSObject>

/**
 *  Informs the delegate that a snapshot of the video has been selected by a tool and would like an image workspace for working on it.
 *
 *  @param videoToolController The tool controller providing the snapshot.
 *  @param previewImage        A preview image.
 *  @param renderedMediaURL    A location on disk of the rendered snapshot.
 */
- (void)videoToolController:(VVideoToolController *)videoToolController
 selectedSnapshotForEditing:(UIImage *)previewImage
        renderedSnapshotURL:(NSURL *)renderedMediaURL;

@end

/**
 *  A VToolController subclass for managing video tools.
 */
@interface VVideoToolController : VToolController

/**
 *  A delegate to inform about certain events. Currently just snapshots.
 */
@property (nonatomic, weak) id<VVideoToolControllerDelegate> videoToolControllerDelegate;

/**
 *  The media URL to use for editing.
 */
@property (nonatomic, strong) NSURL *mediaURL;

/**
 *  The default video tool.
 */
@property (nonatomic, assign) VVideoToolControllerInitialVideoEditState defaultVideoTool;

/**
 *  Whether or not the selected tool is a gif.
 */
@property (nonatomic, readonly) BOOL isGIF;

/**
 *  Whether or not the user did use the trim tool.
 */
@property (nonatomic, readonly) BOOL didTrim;

@end
