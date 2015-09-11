//
//  VFocusable.h
//  victorious
//
//  Created by Patrick Lynch on 9/8/2015
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VFocusType)
{
    VFocusTypeNone,
    VFocusTypeStream,
    VFocusTypeDetail
};

@protocol VFocusable <NSObject>

/**
 Informs the reciever of a change in focus type so that the receiver may update
 its UI and functionality accordingly.
 */
@property (nonatomic, assign) VFocusType focusType;

/**
 Returns the bounding rect for the content relative to the receiving container.
 */
- (CGRect)contentArea;

@end