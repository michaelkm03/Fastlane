//
//  VTextColorTool.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextColorTool.h"
#import "VDependencyManager.h"
#import "VEditTextToolViewController.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";

@interface VTextColorTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *iconSelected;
@property (nonatomic, strong) VEditTextToolViewController *canvasToolViewController;

@end

@implementation VTextColorTool

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _icon = [UIImage imageNamed:@"textColorIcon"];
        _iconSelected = [UIImage imageNamed:@"textColorIcon_selected"];
        _canvasToolViewController = [VEditTextToolViewController newWithDependencyManager:dependencyManager];
    }
    return self;
}

@end
