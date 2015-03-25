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
#import "VTickerPickerViewController.h"
#import "VColorPickerDataSource.h"
#import "NSArray+VMap.h"
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
@property (nonatomic, strong) VEditTextToolViewController *canvasToolViewController;
@property (nonatomic, strong) VTickerPickerViewController *toolPicker;

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
        
#warning Get this from somewhere else, probably the template
        NSArray *testColors = @[ @{ @"title" : @"RED",       @"color" : [UIColor redColor] },
                                 @{ @"title" : @"ORANGE",    @"color" : [UIColor orangeColor] },
                                 @{ @"title" : @"YELLOW",    @"color" : [UIColor yellowColor] },
                                 @{ @"title" : @"GREEN",     @"color" : [UIColor greenColor] },
                                 @{ @"title" : @"BLUE",      @"color" : [UIColor blueColor] },
                                 @{ @"title" : @"PURPLE",    @"color" : [UIColor purpleColor] },
                                 @{ @"title" : @"GRAY",      @"color" : [UIColor grayColor] } ];
        
        NSArray *colorTypes = [testColors v_map:^VColorType *(NSDictionary *dictionary)
        {
            return [[VColorType alloc] initWithColor:dictionary[ @"color" ] title:dictionary[ @"title" ]];
        }];
        id<VToolPickerDataSource> dataSource = [[VColorPickerDataSource alloc] initWithDependencyManager:dependencyManager];
        dataSource.tools = colorTypes;
        _toolPicker = (VTickerPickerViewController *)[dependencyManager viewControllerForKey:kPickerKey];
        _toolPicker.dataSource = dataSource;
    }
    return self;
}

- (void)setSharedCanvasToolViewController:(UIViewController *)viewController
{
    _canvasToolViewController = (VEditTextToolViewController *)viewController;
}

- (UIViewController *)inspectorToolViewController
{
    return (UIViewController *)self.toolPicker;
}

@end
