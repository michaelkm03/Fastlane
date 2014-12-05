//
//  VCropWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropWorkspaceTool.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

#import "VCropWorkspaceToolViewController.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kToolInterfaceKey = @"toolInterface";

@interface VCropWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong, readwrite) VCropWorkspaceToolViewController *cropViewController;

@end

@implementation VCropWorkspaceTool

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _cropViewController = (VCropWorkspaceToolViewController *)[dependencyManager viewControllerForKey:kToolInterfaceKey];
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setAssetSize:(CGSize)assetSize
{
    _cropViewController.assetSize = assetSize;
}

- (CGSize)assetSize
{
    return _cropViewController.assetSize;
}

- (void)setOnCropBoundsChange:(void (^)(CGRect))onCropBoundsChange
{
    _cropViewController.onCropBoundsChange = onCropBoundsChange;
}

- (void (^)(CGRect cropBounds))onCropBoundsChange
{
    return _cropViewController.onCropBoundsChange;
}

#pragma mark - VWorkspaceTool

- (UIViewController *)canvasToolViewController
{
    return _cropViewController;
}

- (UIViewController *)inspectorToolViewController
{
    return nil;
}

- (NSString *)title
{
    return _title;
}

- (UIImage *)icon
{
    return _icon;
}

@end
