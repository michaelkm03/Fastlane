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

@class VStreamItem, VStreamItemPreviewView;

/**
 *  Describes a block that will be called when a preview view has
 *  loaded all of its contents and is ready to display.
 *
 *  @param previewView The preview view that is now ready for display.
 */
typedef void (^VPreviewViewDisplayReadyBlock)(VStreamItemPreviewView *previewView);


/**
 *  VStreamItemPreviewView is a class cluster for previewing a stream item. A concrete subclass is provided
 *  from the "streamItemPreviewViewWithStreamItem:" constructor method. VStreamItemPreviewView conforms to
 *  VStreamCellComponentSpecialization and should be reused for sequences that return the same reuse
 *  identifier from: "reuseIdentifierForSequence:baseIdentifier:".
 */
@interface VStreamItemPreviewView : UIView <VHasManagedDependencies, VStreamCellComponentSpecialization>

/**
 *  The factory method for the VStreamItemPreviewView, will provide a concrete subclass specialized to
 *  the given streamItem.
 */
+ (VStreamItemPreviewView *)streamItemPreviewViewWithStreamItem:(VStreamItem *)streamItem;

/**
 *  Use to update a streamItem preview view for a new streamItem.
 */
@property (nonatomic, strong) VStreamItem *streamItem;

/**
 *  Returns YES if this instance of VStreamItemPreviewView can handle the given streamItem.
 */
- (BOOL)canHandleStreamItem:(VStreamItem *)streamItem;

/**
 *  A block that should be called when the preview view becomes ready to display.
 *  This block is called automatically when readyForDisplay is set to YES.
 */
@property (nonatomic, copy) VPreviewViewDisplayReadyBlock displayReadyBlock;

/**
 *  Subclasses set this to YES when they have loaded all the content
 *  they need to display properly. Setting to YES calls the displayReadyBlock if one exists.
 */
@property (nonatomic, assign) BOOL readyForDisplay;

/**
 *  Returns tracking info specific to things happening inside this preview view.
 */
- (NSDictionary *)trackingInfo;

@end
