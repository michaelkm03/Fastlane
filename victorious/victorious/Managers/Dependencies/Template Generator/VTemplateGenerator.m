//
//  VTemplateGenerator.m
//  victorious
//
//  Created by Josh Hinman on 11/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VDependencyManager.h"
#import "VTemplateGenerator.h"

static NSString * const kAppearanceKey = @"appearance";
static NSString * const kClassNameKey = @"name";

// Scaffold properties
static NSString * const kMenuKey = @"menu";

// Menu properties
static NSString * const kItemsKey = @"items";
static NSString * const kTitleKey = @"title";
static NSString * const kDestinationKey = @"destination";

// Stream properties
static NSString * const kStreamsKey = @"streams";
static NSString * const kInitialKey = @"initial";
static NSString * const kUrlPathKey = @"urlPath";

@interface VTemplateGenerator ()

@property (nonatomic, strong) NSDictionary *dataFromInitCall;

@end

@implementation VTemplateGenerator

- (instancetype)initWithInitData:(NSDictionary *)initData
{
    self = [super init];
    if (self)
    {
        _dataFromInitCall = initData;
    }
    return self;
}

- (NSDictionary *)configurationDict
{
    NSMutableDictionary *template = [[NSMutableDictionary alloc] init];
    [self.dataFromInitCall enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop)
    {
        if ([key isEqual:kAppearanceKey])
        {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                [template addEntriesFromDictionary:obj];
            }
        }
        else
        {
            template[key] = obj;
        }
    }];
    
    template[VDependencyManagerScaffoldViewControllerKey] = @{ kClassNameKey: @"sideMenu.scaffold", kMenuKey: [self menuComponent] };
    return template;
}

- (NSDictionary *)menuComponent
{
    return @{
        kClassNameKey: @"simple.menu",
        kItemsKey: @[
            @[
                @{
                    kTitleKey: @"Home",
                    kDestinationKey: @{
                        kClassNameKey: @"stream.screen",
                        kTitleKey: NSLocalizedString(@"Home", @""),
                        kStreamsKey: @[
                            @{
                                kTitleKey: NSLocalizedString(@"Featured", @""),
                                kUrlPathKey: @"/api/sequence/hot_detail_list_by_stream/home"
                            },
                            @{
                                kTitleKey: NSLocalizedString(@"Recent", @""),
                                kInitialKey: @YES,
                                kUrlPathKey: [self urlPathForStreamCategories:[VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]]
                            }
                        ]
                    }
                }
            ]
        ]
    };
}

- (NSString *)urlPathForStreamCategories:(NSArray *)categories
{
    NSString *categoryString = [categories componentsJoinedByString:@","];
    return [@"/api/sequence/detail_list_by_category/" stringByAppendingString: categoryString ?: @"0"];
}

@end
