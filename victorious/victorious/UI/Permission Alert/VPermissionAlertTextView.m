//
//  VPermissionAlertTextView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionAlertTextView.h"

@implementation VPermissionAlertTextView

// Stop text from being selectable
- (BOOL)canBecomeFirstResponder
{
    return NO;
}

@end
