//
//  VTemplateGenerator.m
//  victorious
//
//  Created by Josh Hinman on 11/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VHamburgerButton.h"
#import "VScaffoldViewController.h"
#import "VStreamCollectionViewController.h"
#import "VTemplateGenerator.h"
#import "VThemeManager.h"
#import "VSettingManager.h"
#import "VTranslucentBackground.h"
#import "VSolidColorBackground.h"
#import "VTabMenuViewController.h"

#define BOTTOM_NAV_ENABLED 0

static NSString * const kIDKey = @"id";
static NSString * const kReferenceIDKey = @"referenceID";
static NSString * const kAppearanceKey = @"appearance";
static NSString * const kClassNameKey = @"name";

// Menu properties
static NSString * const kItemsKey = @"items";
static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kIdentifierKey = @"identifier";
static NSString * const kDestinationKey = @"destination";

// Stream properties
static NSString * const kIsHomeKey = @"isHome";
static NSString * const kMarqueeKey = @"marquee";
static NSString * const kCanAddContentKey = @"canAddContent";
static NSString * const kStreamsKey = @"streams";
static NSString * const kInitialKey = @"initial";
static NSString * const kUserSpecificKey = @"isUserSpecific";

// Directory Components
static NSString * const kBackgroundColor = @"color.background";
static NSString * const kAccentColor = @"color.accent";
static NSString * const kSecondaryAccentColor = @"color.accent.secondary";
static NSString * const kTextColor = @"color.text";
static NSString * const kTextContentColor = @"color.text.content";
static NSString * const kTextAccentColor = @"color.text.accent";
static NSString * const kCellComponentDirectoryGroup = @"cell.directory.group";
static NSString * const kCellComponentDirectoryItem = @"cell.directory.item";

static NSString * const kRedKey = @"red";
static NSString * const kGreenKey = @"green";
static NSString * const kBlueKey = @"blue";
static NSString * const kAlphaKey = @"alpha";

// Other misc. properties
static NSString * const kScreensKey = @"screens";
static NSString * const kSelectorKey =  @"selector";
static NSString * const kTitleImageKey = @"titleImage";

// Workspace properties
static NSString * const kToolsKey = @"tools";
static NSString * const kPickerKey = @"picker";
static NSString * const kFilterIndexKey = @"filterIndex";

// Text properties
static NSString * const kFontNameKey = @"fontName";
static NSString * const kFontSizeKey = @"fontSize";
static NSString * const kTextHorizontalAlignmentKey = @"horizontalAlignment";
static NSString * const kTextVerticalAlignmentKey = @"verticalAlignment";
static NSString * const kTextStrokeColorKey = @"strokeColor";
static NSString * const kTextStrokeWidthKey = @"strokeWidth";
static NSString * const kTextPlaceholderTextKey = @"placeholderText";
static NSString * const kshouldForceUppercaseKey = @"shouldForceUppercase";

// Video properties
static NSString * const kVideoFrameDurationValue = @"frameDurationValue";
static NSString * const kVideoFrameDurationTimescale = @"frameDurationTimescale";
static NSString * const kVideoMaxDuration = @"videoMaxDuration";
static NSString * const kVideoMinDuration = @"videoMinDuration";
static NSString * const kVideoMuted = @"videoMuted";

@interface VTemplateGenerator ()

@property (nonatomic, strong) NSDictionary *dataFromInitCall;
@property (nonatomic) BOOL templateCEnabled;
@property (nonatomic, strong) NSString *firstMenuItemID;
@property (nonatomic, strong) NSString *homeRecentID;
@property (nonatomic, strong) NSString *communityRecentID;
@property (nonatomic, strong) NSDictionary *accentColor;

@end

@implementation VTemplateGenerator

- (instancetype)initWithInitData:(NSDictionary *)initData
{
    self = [super init];
    if (self)
    {
        _dataFromInitCall = initData;
        _firstMenuItemID = [[NSUUID UUID] UUIDString];
        _homeRecentID = [[NSUUID UUID] UUIDString];
        _communityRecentID = [[NSUUID UUID] UUIDString];
        _templateCEnabled = [[_dataFromInitCall valueForKeyPath:@"experiments.template_c_enabled"] boolValue];
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
                 
                 NSDictionary *accentColor = obj[VDependencyManagerAccentColorKey];
                 
                 if ( accentColor == nil )
                 {
                     accentColor = @{
                                     kRedKey: @0,
                                     kBlueKey: @0,
                                     kGreenKey: @0,
                                     kAlphaKey: @1
                                     };
                 }
                 self.accentColor = accentColor;
             }
         }
         else
         {
             template[key] = obj;
         }
     }];
    
    if (BOTTOM_NAV_ENABLED)
    {
        template[VDependencyManagerScaffoldViewControllerKey] = @{
                                                                  kClassNameKey: @"tabMenu.scaffold",
                                                                  kItemsKey:[self bottomNavMenuItems],
                                                                  VScaffoldViewControllerUserProfileViewComponentKey: [self profileScreen],
                                                                  kSelectorKey: [self kSelectorKeyFromInitDictionary:self.dataFromInitCall],
                                                                  VTabMenuViewControllerMenuAppearanceKey: @{
                                                                          VDependencyManagerBackgroundKey: [self solidWhiteBackground],
                                                                          },
                                                                  };
    }
    else
    {
        template[VDependencyManagerScaffoldViewControllerKey] = @{ kClassNameKey: @"sideMenu.scaffold",
                                                                   VHamburgerButtonIconKey: @{
                                                                           VDependencyManagerImageURLKey:(self.templateCEnabled ? @"menuC":@"Menu"),
                                                                           },
                                                                   VDependencyManagerInitialViewControllerKey: @{ kReferenceIDKey: self.firstMenuItemID },
                                                                   VScaffoldViewControllerMenuComponentKey: [self menuComponent],
                                                                   VStreamCollectionViewControllerCreateSequenceIconKey: (self.templateCEnabled ? [UIImage imageNamed:@"createContentButtonC"] : [UIImage imageNamed:@"createContentButton"]),
                                                                   VScaffoldViewControllerUserProfileViewComponentKey: [self profileScreen],
                                                                   kSelectorKey: [self kSelectorKeyFromInitDictionary:self.dataFromInitCall],
                                                                   };
    }
    
    template[VDependencyManagerWorkspaceFlowKey] = [self workspaceFlowComponent];
    template[VScaffoldViewControllerNavigationBarAppearanceKey] = [self navigationBarAppearance];
    
    return template;
}

- (NSDictionary *)kSelectorKeyFromInitDictionary:(NSDictionary *)initDictionary
{
    NSDictionary *kSelectorKey = @{
                                   kClassNameKey: @"basic.multiScreenSelector",
                                   VDependencyManagerBackgroundColorKey: self.accentColor,
                                   };
    
    if ( [[(NSDictionary *)[initDictionary objectForKey:@"experiments"] objectForKey:@"template_c_enabled"] boolValue] )
    {
        kSelectorKey =  @{
                          kClassNameKey: @"textbar.multiScreenSelector",
                          VDependencyManagerBackgroundColorKey:@{
                                              kRedKey: @255,
                                              kBlueKey: @255,
                                              kGreenKey: @255,
                                              kAlphaKey: @1
                                              }
                          };
    }
    return kSelectorKey;
}

- (NSDictionary *)workspaceFlowComponent
{
    return @{
             kClassNameKey: @"workspace",
             VDependencyManagerImageWorkspaceKey: [self imageWorkspaceComponent],
             VDependencyManagerVideoWorkspaceKey: [self videoWorkspaceComponent]
             };
}

- (NSArray *)videoTools
{
    return @[
             @{
                 kClassNameKey: @"trim.video.tool",
                 kTitleKey: @"video",
                 kVideoFrameDurationValue: @1,
                 kVideoFrameDurationTimescale: @24,
                 kVideoMuted: @NO
                 },
             @{
                 kClassNameKey: @"trim.video.tool",
                 kTitleKey: @"gif",
                 kVideoFrameDurationValue: @1,
                 kVideoFrameDurationTimescale: @4,
                 kVideoMuted: @YES
                 },
             @{
                 kClassNameKey: @"snapshot.video.tool",
                 kTitleKey: @"meme",
                 }
             ];
}

- (NSDictionary *)videoWorkspaceComponent
{
    return @{
             kClassNameKey: @"workspace.screen",
             kToolsKey: [self videoTools],
             kVideoMinDuration: @3,
             kVideoMaxDuration: @15,
             };
}

- (NSDictionary *)imageWorkspaceComponent
{
    return @{
             kClassNameKey: @"workspace.screen",
             kToolsKey:
                 @[
                     [self textTool],
                     [self filterTool],
                     [self cropTool],
                     ]
             };
}

- (NSDictionary *)textTool
{
    return @{
             kClassNameKey: @"text.tool",
             kTitleKey: @"text",
             kFilterIndexKey: @2,
             kPickerKey:
                 @{
                     kClassNameKey: @"vertical.picker",
                     },
             kToolsKey:
                 @[
                     @{
                         kClassNameKey: @"textType.tool",
                         kTitleKey: @"meme",
                         kTextHorizontalAlignmentKey: @"center",
                         kTextVerticalAlignmentKey: @"bottom",
                         kTextPlaceholderTextKey: @"create a meme",
                         kshouldForceUppercaseKey: @YES,
                         VDependencyManagerParagraphFontKey:
                             @{
                                 kFontNameKey: @"Impact",
                                 kFontSizeKey: @50,
                                 },
                         VDependencyManagerMainTextColorKey:
                             @{
                                 kRedKey: @255,
                                 kGreenKey: @255,
                                 kBlueKey: @255,
                                 kAlphaKey: @1.0f,
                                 },
                         kTextStrokeColorKey:
                             @{
                                 kRedKey: @0,
                                 kGreenKey: @0,
                                 kBlueKey: @0,
                                 kAlphaKey: @1.0f,
                                 },
                         kTextStrokeWidthKey: @-5.0f,
                         },
                     @{
                         kClassNameKey: @"textType.tool",
                         kTitleKey: @"quote",
                         kTextHorizontalAlignmentKey: @"center",
                         kTextVerticalAlignmentKey: @"center",
                         kTextPlaceholderTextKey: @"create a quote",
                         VDependencyManagerParagraphFontKey:
                             @{
                                 kFontNameKey: @"PTSans-Narrow",
                                 kFontSizeKey: @23,
                                 },
                         VDependencyManagerMainTextColorKey:
                             @{
                                 kRedKey: @255,
                                 kGreenKey: @255,
                                 kBlueKey: @255,
                                 kAlphaKey: @1.0f,
                                 },
                         kTextStrokeColorKey:
                             @{
                                 kRedKey: @255,
                                 kGreenKey: @255,
                                 kBlueKey: @255,
                                 kAlphaKey: @1.0f,
                                 },
                         kTextStrokeWidthKey: @0.0f,
                         },
                     ]
             };
}

- (NSDictionary *)filterTool
{
    return @{
             kClassNameKey: @"filter.tool",
             kTitleKey: @"filters",
             kFilterIndexKey: @0,
             kPickerKey:
                 @{
                     kClassNameKey: @"vertical.picker",
                     },
             kToolsKey:
                 @[
                     ]
             };
}

- (NSDictionary *)cropTool
{
    return @{
             kClassNameKey: @"crop.tool",
             kTitleKey: @"crop",
             kFilterIndexKey: @1,
             };
}

- (NSDictionary *)navigationBarAppearance
{
    if ( self.templateCEnabled )
    {
        return @{
                 VDependencyManagerBackgroundColorKey: @{
                         kRedKey: @255,
                         kGreenKey: @255,
                         kBlueKey: @255,
                         kAlphaKey: @1
                         },
                 VDependencyManagerMainTextColorKey: @{
                         kRedKey: @0,
                         kGreenKey: @0,
                         kBlueKey: @0,
                         kAlphaKey: @1
                         }
                 };
    }
    else
    {
        return @{
                 VDependencyManagerBackgroundColorKey: self.dataFromInitCall[@"appearance"][@"color.accent"]
                 };
    }
}

- (NSDictionary *)menuComponent
{
    return @{
        kClassNameKey: @"simple.menu",
        kItemsKey: @[
            @[
                [self homeMenuItem],
                [self ownerStreamMenuItem],
                @{
                    kIdentifierKey: @"Menu Community",
                    kTitleKey: NSLocalizedString(@"Community", @""),
                    kDestinationKey: @{
                        kClassNameKey: @"basic.multiScreen",
                        kTitleKey: NSLocalizedString(@"Community", @""),
                        kCanAddContentKey: @YES,
                        kInitialKey: @{ kReferenceIDKey: self.communityRecentID },
                        kScreensKey: @[
                            @{
                                kClassNameKey: @"stream.screen",
                                kTitleKey: NSLocalizedString(@"Featured", @""),
                                VStreamCollectionViewControllerStreamURLPathKey: @"/api/sequence/hot_detail_list_by_stream/ugc/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%",
                                kCanAddContentKey: @YES,
                            },
                            @{
                                kClassNameKey: @"stream.screen",
                                kIDKey: self.communityRecentID,
                                kTitleKey: NSLocalizedString(@"Recent", @""),
                                VStreamCollectionViewControllerStreamURLPathKey: [self urlPathForStreamCategories:VUGCCategories()],
                                kCanAddContentKey: @YES,
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
                [self inboxMenuItem],
                [self profileMenuItem],
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

- (NSArray *)bottomNavMenuItems
{
    return @[
             [self homeMenuItem],
             [self ownerStreamMenuItem],
             [self createMenuItem],
             [self profileMenuItem],
             [self inboxMenuItem],
             ];
}

- (NSDictionary *)homeMenuItem
{
    return @{
             kIdentifierKey: @"Menu Home",
             kTitleKey: NSLocalizedString(@"Home", @""),
             kDestinationKey: [self homeScreen],
             kIconKey: @{
                     VDependencyManagerImageURLKey: @"home",
                     }
             };
}

- (NSDictionary *)createMenuItem
{
    return @{
             kTitleKey: NSLocalizedString(@"Create", @""),
             kIconKey: @{
                     VDependencyManagerImageURLKey: @"create",
                     },
             kDestinationKey: [self workspaceFlowComponent],
             };
}

- (NSDictionary *)profileMenuItem
{
    return @{
             kIdentifierKey: @"Menu Profile",
             kTitleKey: NSLocalizedString(@"Profile", @""),
             kIconKey: @{
                     VDependencyManagerImageURLKey: @"profile",
                     },
             kDestinationKey: @{
                     kClassNameKey: @"currentUserProfile.screen"
                     }
             };
}

- (NSDictionary *)inboxMenuItem
{
    return @{
             kIdentifierKey: @"Menu Inbox",
             kTitleKey: NSLocalizedString(@"Inbox", @""),
             kIconKey: @{
                     VDependencyManagerImageURLKey: @"inbox",
                     },
             kDestinationKey: @{
                     kClassNameKey: @"inbox.screen"
                     }
             };
}

- (NSString *)urlPathForStreamCategories:(NSArray *)categories
{
    NSString *categoryString = [categories componentsJoinedByString:@","] ?: @"0";
    return [NSString stringWithFormat:@"/api/sequence/detail_list_by_category/%@/%%%%PAGE_NUM%%%%/%%%%ITEMS_PER_PAGE%%%%", categoryString];
}

- (NSDictionary *)profileScreen
{
    return @{ kClassNameKey: @"userProfile.screen" };
}
                
- (NSDictionary *)homeScreen
{
    NSMutableDictionary *homeScreen = [@{
        kIDKey: self.firstMenuItemID,
        kClassNameKey: @"basic.multiScreen",
        kScreensKey: @[
                @{
                    kClassNameKey: @"stream.screen",
                    kTitleKey: NSLocalizedString(@"Featured", @""),
                    VStreamCollectionViewControllerStreamURLPathKey: @"/api/sequence/hot_detail_list_by_stream/home/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%",
                    kIsHomeKey: @YES,
                    kCanAddContentKey: @YES,
                    },
                @{
                    kIDKey: self.homeRecentID,
                    kClassNameKey: @"stream.screen",
                    kTitleKey: NSLocalizedString(@"Recent", @""),
                    VStreamCollectionViewControllerStreamURLPathKey: [self urlPathForStreamCategories:[VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]],
                    kCanAddContentKey: @YES,
                    kMarqueeKey: @YES,
                    },
                @{
                    kClassNameKey: @"followingStream.screen",
                    kTitleKey: NSLocalizedString(@"Following", @""),
                    VStreamCollectionViewControllerStreamURLPathKey: @"/api/sequence/follows_detail_list_by_stream/0/home/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%",
                    kCanAddContentKey: @YES,
                    }
                ],
        kInitialKey: @{
                kReferenceIDKey: self.homeRecentID,
                },
        } mutableCopy];
    
    UIImage *headerImage = [self homeHeaderImage];
    if ( headerImage != nil )
    {
        homeScreen[kTitleImageKey] = headerImage;
    }
    
    return homeScreen;
}

- (UIImage *)homeHeaderImage
{
    // This is a terrible hack. By default the header image is a 1x1 pt image. If this is what we get back in themedImageForKey return nil.
    UIImage *headerImage = [UIImage imageNamed:VThemeManagerHomeHeaderImageKey];
    if ((headerImage.size.width == 1) && (headerImage.size.height == 1))
    {
        return nil;
    }
    return headerImage;
}

- (NSDictionary *)homeRecentStream
{
    NSDictionary *stream = @{
      kTitleKey: NSLocalizedString(@"Recent", @""),
      kInitialKey: @YES,
      VStreamCollectionViewControllerStreamURLPathKey: [self urlPathForStreamCategories:[VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]]
    };
    
    NSNumber *marqueeEnabled = [self.dataFromInitCall valueForKeyPath:@"experiments.marquee_enabled"];
    if ( [marqueeEnabled isKindOfClass:[NSNumber class]] && [marqueeEnabled boolValue] )
    {
        NSMutableDictionary *mutableStream = [stream mutableCopy];
        mutableStream[kMarqueeKey] = @{ VStreamCollectionViewControllerStreamURLPathKey: @"/api/sequence/detail_list_by_stream/marquee" };
        return [mutableStream copy];
    }
    return stream;
}

- (NSDictionary *)ownerStreamMenuItem
{
    NSNumber *channelsEnabled = [self.dataFromInitCall valueForKeyPath:@"experiments.channels_enabled"];
    if ([channelsEnabled isKindOfClass:[NSNumber class]] && [channelsEnabled boolValue])
    {
        if ( NO )
        {
            NSDictionary *componentBase = @{ kIdentifierKey: @"Menu Channels",
                                             kTitleKey: NSLocalizedString(@"Channels", @""),
                                             kDestinationKey: @{
                                                     kClassNameKey: @"groupedStream.screen",
                                                     kTitleKey: NSLocalizedString(@"Channels", nil),
                                                     VStreamCollectionViewControllerStreamURLPathKey: @"/api/sequence/detail_list_by_stream/directory/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
                                                     }
                                             };
            NSMutableDictionary *completeComponent = [[NSMutableDictionary alloc] initWithDictionary:componentBase];
            [completeComponent addEntriesFromDictionary:[self directoryComponentLight]];
            return [NSDictionary dictionaryWithDictionary:completeComponent];
        }
        else
        {
            return @{ kIdentifierKey: @"Menu Channels",
                      kTitleKey: NSLocalizedString(@"Channels", @""),
                      kDestinationKey: @{
                              kClassNameKey: @"directory.screen",
                              kTitleKey: NSLocalizedString(@"Channels", nil),
                              VStreamCollectionViewControllerStreamURLPathKey: @"/api/sequence/detail_list_by_stream/directory/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
                              },
                      kBackgroundColor: @{
                              kRedKey: @0,
                              kGreenKey: @0,
                              kBlueKey: @0,
                              kAlphaKey: @1
                              },
                      kCellComponentDirectoryItem: [self directoryCellComponentDark]
                      };
        }
    }
    else
    {
        return @{
            kIdentifierKey: @"Menu Channel",
            kTitleKey: NSLocalizedString(@"Channel", @""),
            kIconKey: @"channels",
            kCellComponentDirectoryItem: [self directoryCellComponentLight],
            kDestinationKey: @{
                kClassNameKey: @"basic.multiScreen",
                kTitleKey: NSLocalizedString(@"Owner", @""),
                kScreensKey: @[
                    @{
                        kClassNameKey: @"stream.screen",
                        kTitleKey: NSLocalizedString(@"Featured", @""),
                        VStreamCollectionViewControllerStreamURLPathKey: @"/api/sequence/hot_detail_list_by_stream/owner/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
                    },
                    @{
                        kClassNameKey: @"stream.screen",
                        kInitialKey: @YES,
                        kTitleKey: NSLocalizedString(@"Recent", @""),
                        VStreamCollectionViewControllerStreamURLPathKey: [self urlPathForStreamCategories:VOwnerCategories()],
                    }
                ]
            }
        };
    }
}

- (NSDictionary *)directoryComponentLight
{
    return @{ kBackgroundColor: @{
                      kRedKey: @238,
                      kGreenKey: @238,
                      kBlueKey: @238,
                      kAlphaKey: @1
                      },
              kCellComponentDirectoryGroup: @{
                      kTextColor: @{
                              kRedKey: @128,
                              kGreenKey: @128,
                              kBlueKey: @128,
                              kAlphaKey: @1
                              },
                      kCellComponentDirectoryItem: [self directoryCellComponentLight]
                      }
              };
}

- (NSDictionary *)directoryComponentDark
{
    return @{ kBackgroundColor: @{
                      kRedKey: @20,
                      kGreenKey: @20,
                      kBlueKey: @20,
                      kAlphaKey: @1
                      },
              kCellComponentDirectoryGroup: @{
                      kTextColor: @{
                              kRedKey: @128,
                              kGreenKey: @128,
                              kBlueKey: @128,
                              kAlphaKey: @1
                              },
                      kCellComponentDirectoryItem: [self directoryCellComponentLight]
                      }
              };
}

- (NSDictionary *)directoryCellComponentLight
{
    return @{ kSecondaryAccentColor: @{ //< see more arrow
                      kRedKey: @200,
                      kGreenKey: @200,
                      kBlueKey: @200,
                      kAlphaKey: @1
                      },
              kTextContentColor: @{ //< see more text
                      kRedKey: @160,
                      kGreenKey: @160,
                      kBlueKey: @160,
                      kAlphaKey: @1
                      },
              kTextAccentColor: @{ //< quantity labe
                      kRedKey: @153,
                      kGreenKey: @153,
                      kBlueKey: @153,
                      kAlphaKey: @1
                      },
              kTextColor: @{ //< name label
                      kRedKey: @51,
                      kGreenKey: @51,
                      kBlueKey: @51,
                      kAlphaKey: @1
                      },
              kAccentColor: @{ //< border color
                      kRedKey: @204,
                      kGreenKey: @204,
                      kBlueKey: @204,
                      kAlphaKey: @1
                      },
              kBackgroundColor: @{ // stacked background
                      kRedKey: @255,
                      kGreenKey: @255,
                      kBlueKey: @255,
                      kAlphaKey: @1
                      },
              };
}

- (NSDictionary *)directoryCellComponentDark
{
    return  @{ kSecondaryAccentColor: @{ //< see more arrow
                       kRedKey: @95,
                       kGreenKey: @95,
                       kBlueKey: @95,
                       kAlphaKey: @1
                       },
               kTextContentColor: @{ //< see more text
                       kRedKey: @170,
                       kGreenKey: @170,
                       kBlueKey: @170,
                       kAlphaKey: @1
                       },
               kTextAccentColor: @{ //< quantity label
                       kRedKey: @150,
                       kGreenKey: @150,
                       kBlueKey: @150,
                       kAlphaKey: @1
                       },
               kTextColor: @{ //< name label
                       kRedKey: @255,
                       kGreenKey: @255,
                       kBlueKey: @255,
                       kAlphaKey: @1
                       },
               kAccentColor: @{ //< border color
                       kRedKey: @0,
                       kGreenKey: @0,
                       kBlueKey: @0,
                       kAlphaKey: @1
                       },
               kBackgroundColor: @{ // stacked background
                       kRedKey: @40,
                       kGreenKey: @40,
                       kBlueKey: @40,
                       kAlphaKey: @1
                       },
               };
}

#pragma mark - Background

- (NSDictionary *)solidWhiteBackground
{
    return @{ kClassNameKey:@"solidColor.background",
              VSolidColorBackgroundColorKey: @{
                      kRedKey: @255,
                      kGreenKey: @255,
                      kBlueKey: @255,
                      kAlphaKey: @1
                      },
              };
}

@end
