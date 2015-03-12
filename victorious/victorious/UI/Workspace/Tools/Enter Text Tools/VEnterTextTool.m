//
//  VEnterTextTool.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEnterTextTool.h"
#import "VDependencyManager.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";

@interface VEnterTextTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;

@end

@implementation VEnterTextTool

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _icon = [UIImage imageNamed:@"textIcon"];
    }
    return self;
}

@end
