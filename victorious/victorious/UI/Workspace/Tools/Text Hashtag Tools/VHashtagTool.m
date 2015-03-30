//
//  VHashtagTool.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagTool.h"
#import "VDependencyManager.h"
#import "VTextCanvasToolViewController.h"
#import "NSArray+VMap.h"
#import "VHashtagPickerDataSource.h"
#import "VHashtagType.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";
static NSString * const kImageURLKey = @"imageURL";
static NSString * const kPickerKey = @"picker";

@interface VHashtagTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, strong) VTextCanvasToolViewController *canvasToolViewController;
@property (nonatomic, readwrite) UIViewController <VToolPicker> *toolPicker;

@end

@implementation VHashtagTool

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _icon = [UIImage imageNamed:[dependencyManager templateValueOfType:[NSDictionary class] forKey:kIconKey][kImageURLKey]];
        _selectedIcon = [UIImage imageNamed:[dependencyManager templateValueOfType:[NSDictionary class] forKey:kSelectedIconKey][kImageURLKey]];
        
        VHashtagPickerDataSource *dataSource = [[VHashtagPickerDataSource alloc] initWithDependencyManager:dependencyManager];
        
        _toolPicker = (UIViewController<VToolPicker> *)[dependencyManager viewControllerForKey:kPickerKey];
        _toolPicker.dataSource = dataSource;
        
        [dataSource reloadWithCompletion:^(NSArray *hashtagTools)
         {
             NSArray *testingTags = @[ [[VHashtagType alloc] initWithHashtagText:@"test1"],
                                       [[VHashtagType alloc] initWithHashtagText:@"test2"],
                                       [[VHashtagType alloc] initWithHashtagText:@"test3"],
                                       [[VHashtagType alloc] initWithHashtagText:@"test4"],
                                       [[VHashtagType alloc] initWithHashtagText:@"test5"],
                                       [[VHashtagType alloc] initWithHashtagText:@"test6"],
                                       [[VHashtagType alloc] initWithHashtagText:@"test7"] ];
             hashtagTools = [hashtagTools arrayByAddingObjectsFromArray:testingTags];
             self.toolPicker.dataSource.tools = hashtagTools;
             [self.toolPicker reloadData];
         }];
        
        
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

- (void)selectDefault
{
    [_toolPicker selectToolAtIndex:0];
}

@end
