//
//  VPassthroughContainerView.h
//  victorious
//
//  Created by Patrick Lynch on 4/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Overrides `hitTest:withEvent:` to only allow subviews to receive touches
 and not this view itself, essentially allowing touches to "pass through" its
 background.
 */
@interface VPassthroughContainerView : UIView

@end