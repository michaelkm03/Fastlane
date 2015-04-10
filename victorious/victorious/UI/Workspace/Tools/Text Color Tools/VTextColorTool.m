//
//  VTextColorTool.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextColorTool.h"
#import "VDependencyManager.h"
#import "VTextCanvasToolViewController.h"
#import "VTickerPickerViewController.h"
#import "VColorPickerDataSource.h"
#import "VColorType.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";
static NSString * const kImageURLKey = @"imageURL";
static NSString * const kPickerKey = @"picker";

@interface VTextColorTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, strong) VTextCanvasToolViewController *canvasToolViewController;
@property (nonatomic, strong, readwrite) VTickerPickerViewController *toolPicker;

@end

@implementation VTextColorTool

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _icon = [UIImage imageNamed:[dependencyManager templateValueOfType:[NSDictionary class] forKey:kIconKey][kImageURLKey]];
        _selectedIcon = [UIImage imageNamed:[dependencyManager templateValueOfType:[NSDictionary class] forKey:kSelectedIconKey][kImageURLKey]];
        _toolPicker = (VTickerPickerViewController *)[dependencyManager viewControllerForKey:kPickerKey];
        _toolPicker.dataSource = [[VColorPickerDataSource alloc] initWithDependencyManager:dependencyManager];
    }
    return self;
}

- (void)setSharedCanvasToolViewController:(UIViewController *)viewController
{
    _canvasToolViewController = (VTextCanvasToolViewController *)viewController;
}

- (UIViewController *)inspectorToolViewController
{
    return (UIViewController *)self.toolPicker;
}

@end
