//
//  VFocusable.h
//  victorious
//
//  Created by Patrick Lynch on 9/8/2015
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A type that distinguishes various levels of "focus" that can selectively
 change the functionality of UI elements.
 */
typedef NS_ENUM(NSInteger, VFocusType)
{
    VFocusTypeNone,
    VFocusTypeStream,
    VFocusTypeDetail
};

/**
 Defines an object whose `focusType` property can be read and written,
 thereby requesting that the object update to reflect changes in its focusType.
 */
@protocol VFocusable <NSObject>

/**
 Informs the reciever of a change in focus type so that the receiver may update
 its UI and functionality accordingly.
 */
@property (nonatomic, assign) VFocusType focusType;

@optional

/**
 Returns the bounding rect for the content rect to be used for focus calculations.
 */
- (CGRect)contentArea;

@end
