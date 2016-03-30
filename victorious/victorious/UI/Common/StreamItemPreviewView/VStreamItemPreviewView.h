//
//  VStreamItemPreviewView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VStreamCellSpecialization.h"
#import "VBackgroundContainer.h"

NS_ASSUME_NONNULL_BEGIN

@class VStreamItem, VStreamItemPreviewView;

/**
 *  Describes a block that will be called when a preview view has
 *  loaded all of its contents and is ready to display.
 *
 *  @param previewView The preview view that is now ready for display.
 */
typedef void (^VRenderablePreviewViewDisplayReadyBlock)(VStreamItemPreviewView *previewView);


/**
 *  VStreamItemPreviewView is a class cluster for previewing a stream item. A concrete subclass is provided
 *  from the "streamItemPreviewViewWithStreamItem:" constructor method. VStreamItemPreviewView conforms to
 *  VStreamCellComponentSpecialization and should be reused for sequences that return the same reuse
 *  identifier from: "reuseIdentifierForSequence:baseIdentifier:".
 */
@interface VStreamItemPreviewView : UIView <VHasManagedDependencies, VStreamCellComponentSpecialization, VBackgroundContainer>

/**
 *  The factory method for the VStreamItemPreviewView, will provide a concrete subclass specialized to
 *  the given streamItem.
 */
+ (VStreamItemPreviewView *)streamItemPreviewViewWithStreamItem:(VStreamItem *__nullable)streamItem;

/**
 *  Use to update a streamItem preview view for a new streamItem.
 *
 *  @param streamItem The stream item that should populate the preview view.
 */
- (void)updateToStreamItem:(VStreamItem *)streamItem;

/**
 *  For use by subclasses to maintain the currently displayed stream item.
 */
@property (nonatomic, strong, nullable) VStreamItem *streamItem;

/**
 *  Returns YES if this instance of VStreamItemPreviewView can handle the given streamItem.
 */
- (BOOL)canHandleStreamItem:(VStreamItem *__nullable)streamItem;

/**
 *  A block that should be called when the preview view becomes ready to display.
 *  This block is called automatically when readyForDisplay is set to YES.
 */
@property (nonatomic, copy, nullable) VRenderablePreviewViewDisplayReadyBlock displayReadyBlock;

/**
 *  Subclasses set this to YES when they have loaded all the content
 *  they need to display properly. Setting to YES calls the displayReadyBlock if one exists.
 */
@property (nonatomic, assign) BOOL readyForDisplay;

/**
 *  If YES, this preview view will only display the preview image for this content.
 */
@property (nonatomic, assign) BOOL onlyShowPreview;

/**
 *  The dependency manager used, by some preview views, for styling.
 */
@property (nonatomic, strong, nullable) VDependencyManager *dependencyManager;

/**
 *  The size used, by some preview views, for rendering preview images.
 */
@property (nonatomic, assign) CGSize displaySize;

/**
 *  Returns tracking info specific to things happening inside this preview view. 
 *  Subclasses can override to provide necessary tracking info for when action is
 *  taken on the cell (when the cell is tapped for example).
 */
- (NSDictionary *)trackingInfo;

/**
 A color to be shown in the background if the aspect ratio of the preview asset
 doesn't match the size in which it's being displayed. (i.e. letterboxing)
 */
@property (nonatomic, strong) UIColor *streamBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *defaultBackgroundColor;
@property (nonatomic, readonly) UIColor *updatedBackgroundColor;

@end

NS_ASSUME_NONNULL_END
