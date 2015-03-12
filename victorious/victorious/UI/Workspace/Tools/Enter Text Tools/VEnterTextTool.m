//
//  VEnterTextTool.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEnterTextTool.h"
#import "VDependencyManager.h"
#import "VTextInputViewController.h"

@interface VEnterTextTool ()

@property (nonatomic, strong) VTextInputViewController *canvasToolViewController;

@end

@implementation VEnterTextTool

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _canvasToolViewController = [VTextInputViewController newWithDependencyManager:dependencyManager];
    }
    return self;
}

@end
