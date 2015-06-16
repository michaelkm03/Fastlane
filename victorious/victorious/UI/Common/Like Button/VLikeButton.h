//
//  VBinaryExpressionControl.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBinaryExpressionControl.h"
#import "VBinaryExpressionCountDisplay.h"

@interface VLikeButton : UIButton <VBinaryExpressionControl, VBinaryExpressionCountDisplay>

@end
