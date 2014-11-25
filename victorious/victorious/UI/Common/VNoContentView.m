//
//  VNoContentView.m
//  victorious
//
//  Created by Will Long on 6/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNoContentView.h"
#import "VThemeManager.h"

@implementation VNoContentView

+ (instancetype)noContentViewWithFrame:(CGRect)frame
{
    VNoContentView *noContentView = [[[NSBundle mainBundle] loadNibNamed:@"VNoContentView" owner:self options:nil] objectAtIndex:0];
    
    noContentView.frame = frame;
    noContentView.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    noContentView.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    
    return noContentView;
}

@end
