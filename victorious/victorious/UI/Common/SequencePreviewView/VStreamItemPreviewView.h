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

typedef void (^VPreviewViewDisplayReadyBlock)(BOOL success, VStreamItemPreviewView *previewView);
#warning DOCS

@interface VStreamItemPreviewView : UIView <VHasManagedDependencies, VStreamCellComponentSpecialization>

/**
 *  The factory method for the VStreamItemPreviewView, will provide a concrete subclass specialized to
 *  the given stream item.
 */
+ (VStreamItemPreviewView *)streamItemPreviewViewWithStreamItem:(VStreamItem *)streamItem;

/**
 *  Use to update a sequence preview view for a new sequence.
 */
- (void)setStreamItem:(VStreamItem *)streamItem;

/**
 *  Returns YES if this instance of VStreamItemPreviewView can handle the given seuqence.
 */
- (BOOL)canHandleStreamItem:(VStreamItem *)streamItem;

@property (nonatomic, copy) VPreviewViewDisplayReadyBlock displayReadyBlock;

@property (nonatomic, assign) BOOL readyForDisplay;

@end
