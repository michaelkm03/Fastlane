//
//  VActionSheetTextView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VActionSheetTextView.h"

@implementation VActionSheetTextView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Overriding the default behavior so text view will scroll normally
    return YES;
}

@end
