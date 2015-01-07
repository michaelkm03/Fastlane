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

static NSString * const kIDKey = @"id";
static NSString * const kReferenceIDKey = @"referenceID";
static NSString * const kAppearanceKey = @"appearance";
static NSString * const kClassNameKey = @"name";

// Scaffold properties
static NSString * const kMenuKey = @"menu";

// Menu properties
static NSString * const kItemsKey = @"items";
static NSString * const kTitleKey = @"title";
static NSString * const kIdentifierKey = @"identifier";
static NSString * const kDestinationKey = @"destination";

// Stream properties
static NSString * const kIsHomeKey = @"isHome";
static NSString * const kMarqueeKey = @"marquee";
static NSString * const kCanAddContentKey = @"canAddContent";
static NSString * const kStreamsKey = @"streams";
static NSString * const kInitialKey = @"initial";
static NSString * const kStreamUrlPathKey = @"streamUrlPath";
static NSString * const kUserSpecificKey = @"isUserSpecific";

@interface VTemplateGenerator ()

@property (nonatomic, strong) NSDictionary *dataFromInitCall;
@property (nonatomic, strong) NSString *firstMenuItemID;

@end

@implementation VTemplateGenerator

- (instancetype)initWithInitData:(NSDictionary *)initData
{
    self = [super init];
    if (self)
    {
        _dataFromInitCall = initData;
        _firstMenuItemID = [[NSUUID UUID] UUIDString];
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
    
    template[VDependencyManagerScaffoldViewControllerKey] = @{ kClassNameKey: @"sideMenu.scaffold",
                                                               VDependencyManagerInitialViewControllerKey: @{ kReferenceIDKey: self.firstMenuItemID },
                                                               kMenuKey: [self menuComponent] };
    return template;
}

- (NSDictionary *)menuComponent
{
    return @{
        kClassNameKey: @"simple.menu",
        kItemsKey: @[
            @[
                @{
                    kIdentifierKey: @"Menu Home",
                    kTitleKey: NSLocalizedString(@"Home", @""),
                    kDestinationKey: @{
                        kIDKey: self.firstMenuItemID,
                        kClassNameKey: @"stream.screen",
                        kTitleKey: NSLocalizedString(@"Home", @""),
                        kIsHomeKey: @YES,
                        kCanAddContentKey: @YES,
                        kStreamsKey: @[
                            @{
                                kTitleKey: NSLocalizedString(@"Featured", @""),
                                kStreamUrlPathKey: @"/api/sequence/hot_detail_list_by_stream/home"
                            },
                            @{
                                kTitleKey: NSLocalizedString(@"Recent", @""),
                                kInitialKey: @YES,
                                kStreamUrlPathKey: [self urlPathForStreamCategories:[VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]]
                            },
                            @{
                                kTitleKey: NSLocalizedString(@"Following", @""),
                                kUserSpecificKey: @YES,
                                kStreamUrlPathKey: @"/api/sequence/follows_detail_list_by_stream/0/home"
                            }
                        ]
                    }
                },
                [self ownerStreamMenuItem],
                @{
                    kIdentifierKey: @"Menu Community",
                    kTitleKey: NSLocalizedString(@"Community", @""),
                    kDestinationKey: @{
                        kClassNameKey: @"stream.screen",
                        kTitleKey: NSLocalizedString(@"Community", @""),
                        kCanAddContentKey: @YES,
                        kStreamsKey: @[
                            @{
                                kTitleKey: NSLocalizedString(@"Featured", @""),
                                kStreamUrlPathKey: @"/api/sequence/hot_detail_list_by_stream/ugc"
                            },
                            @{
                                kInitialKey: @YES,
                                kTitleKey: NSLocalizedString(@"Recent", @""),
                                kStreamUrlPathKey: [self urlPathForStreamCategories:VUGCCategories()],
                            },
                        ]
                    }
                },
                @{
                    kIdentifierKey: @"Menu Discover",
                    kTitleKey: NSLocalizedString(@"Discover", @""),
                    kDestinationKey: @{
                        kClassNameKey: @"discover.screen"
                    }
                }
            ],
            @[
                @{
                    kIdentifierKey: @"Menu Inbox",
                    kTitleKey: NSLocalizedString(@"Inbox", @""),
                    kDestinationKey: @{
                        kClassNameKey: @"inbox.screen"
                    }
                },
                @{
                    kIdentifierKey: @"Menu Profile",
                    kTitleKey: NSLocalizedString(@"Profile", @""),
                    kDestinationKey: @{
                        kClassNameKey: @"currentUserProfile.screen"
                    }
                },
                @{
                    kIdentifierKey: @"Menu Settings",
                    kTitleKey: NSLocalizedString(@"Settings", @""),
                    kDestinationKey: @{
                        kClassNameKey: @"settings.screen"
                    }
                }
            ]
        ]
    };
}

- (NSString *)urlPathForStreamCategories:(NSArray *)categories
{
    NSString *categoryString = [categories componentsJoinedByString:@","];
    return [@"/api/sequence/detail_list_by_category/" stringByAppendingString:(categoryString ?: @"0")];
}

- (NSDictionary *)homeRecentStream
{
    NSDictionary *stream = @{
      kTitleKey: NSLocalizedString(@"Recent", @""),
      kInitialKey: @YES,
      kStreamUrlPathKey: [self urlPathForStreamCategories:[VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]]
    };
    
    NSNumber *marqueeEnabled = [self.dataFromInitCall valueForKeyPath:@"experiments.marquee_enabled"];
    if ( [marqueeEnabled isKindOfClass:[NSNumber class]] && [marqueeEnabled boolValue] )
    {
        NSMutableDictionary *mutableStream = [stream mutableCopy];
        mutableStream[kMarqueeKey] = @{ kStreamUrlPathKey: @"/api/sequence/detail_list_by_stream/marquee" };
        return [mutableStream copy];
    }
    return stream;
}

- (NSDictionary *)ownerStreamMenuItem
{
    NSNumber *channelsEnabled = [self.dataFromInitCall valueForKeyPath:@"experiments.channels_enabled"];
    if ([channelsEnabled isKindOfClass:[NSNumber class]] && [channelsEnabled boolValue])
    {
        return @{
            kIdentifierKey: @"Menu Channels",
            kTitleKey: NSLocalizedString(@"Channels", @""),
            kDestinationKey: @{
                kClassNameKey: @"streamDirectory.screen",
                kTitleKey: NSLocalizedString(@"Channels", nil),
                kStreamUrlPathKey: @"/api/sequence/detail_list_by_stream/directory"
            }
        };
    }
    else
    {
        return @{
            kIdentifierKey: @"Menu Channel",
            kTitleKey: NSLocalizedString(@"Channel", @""),
            kDestinationKey: @{
                kClassNameKey: @"stream.screen",
                kTitleKey: NSLocalizedString(@"Owner", @""),
                kStreamsKey: @[
                    @{
                        kTitleKey: NSLocalizedString(@"Featured", @""),
                        kStreamUrlPathKey: @"/api/sequence/hot_detail_list_by_stream/owner"
                    },
                    @{
                        kInitialKey: @YES,
                        kTitleKey: NSLocalizedString(@"Recent", @""),
                        kStreamUrlPathKey: [self urlPathForStreamCategories:VOwnerCategories()],
                    }
                ]
            }
        };
    }
}

@end