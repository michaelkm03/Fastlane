//
//  VContentViewImageLayout.h
//  victorious
//
//  Created by Michael Sena on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewBaseLayout.h"

@interface VContentViewImageLayout : VContentViewBaseLayout

/**
 *  The size of the header.
 */
@property (nonatomic, assign, readonly) CGFloat dropDownHeaderMiniumHeight;

/**
 *  The size of the contentView in it's full state. Note: does not update or reflect the current state when shrinking/floating.
 */
@property (nonatomic, assign, readonly) CGSize sizeForContentView;

@end
