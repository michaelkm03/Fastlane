//
//  VHashtagTool.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagTool.h"
#import "VDependencyManager.h"
#import "VEditTextToolViewController.h"
#import "VToolPicker.h"
#import "NSArray+VMap.h"
#import "VHashtagPickerDataSource.h"
#import "VObjectManager+Discover.h"
#import "NSArray+VMap.h"
#import "VHashtag.h"
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
@property (nonatomic, strong) VEditTextToolViewController *canvasToolViewController;
@property (nonatomic, strong) UIViewController <VToolPicker> *toolPicker;

@end

@implementation VHashtagTool

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _icon = [UIImage imageNamed:[dependencyManager templateValueOfType:[NSDictionary class] forKey:kIconKey][kImageURLKey]];
        _selectedIcon = [UIImage imageNamed:[dependencyManager templateValueOfType:[NSDictionary class] forKey:kSelectedIconKey][kImageURLKey]];
        
        _toolPicker = (UIViewController<VToolPicker> *)[dependencyManager viewControllerForKey:kPickerKey];
        _toolPicker.dataSource = [[VHashtagPickerDataSource alloc] initWithDependencyManager:dependencyManager];
        
        [self loadTrendingHashtags];
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

- (void)updateTools:(NSArray *)hashtagTools
{
    VHashtagType *defaultNoHashtag = [[VHashtagType alloc] initWithHashtagText:@"(None)" isDefault:YES];
    NSArray *toolsWithDefault = [@[defaultNoHashtag] arrayByAddingObjectsFromArray:hashtagTools];
    
    _toolPicker.dataSource.tools = toolsWithDefault;
    [_toolPicker reloadData];
}

#pragma mark - Loading Remote Data

- (void)loadTrendingHashtags
{
    [[VObjectManager sharedManager] getSuggestedHashtags:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         NSArray *hashtagTools = [resultObjects v_map:^VHashtagType *(VHashtag *hashtag)
         {
             if ( [hashtag isKindOfClass:[VHashtag class]] )
             {
                 VHashtagType *hashtagType = [[VHashtagType alloc] initWithHashtagText:hashtag.tag isDefault:NO];
                 return hashtagType;
             }
             else
             {
                 return nil;
             }
         }];
         
         [self updateTools:hashtagTools];
     }
                                               failBlock:nil];
}

@end
