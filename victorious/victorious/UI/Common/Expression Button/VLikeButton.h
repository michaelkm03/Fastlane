//
//  VExpressionButton.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VExpressions.h"

@interface VLikeButton : UIButton <VExpressionButton>

- (void)setSizeConstraints;

@end
