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
#import "VFirstTimeInstallHelper.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VObjectManager+Login.h"
#import "NSDictionary+VJSONLogging.h"

#define TEMPLATE_ICON_PREFIX @"D_"
#define SELECTED_ICON_SUFFIX @"_selected"

static NSString * const kIDKey = @"id";
static NSString * const kReferenceIDKey = @"referenceID";
static NSString * const kAppearanceKey = @"appearance";
static NSString * const kExperimentsKey = @"experiments";
static NSString * const kClassNameKey = @"name";

// Menu properties
static NSString * const kItemsKey = @"items";
static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";
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
static NSString * const kContentView = @"contentView";
static NSString * const kUserProfileView = @"userProfileView";

// Workspace properties
static NSString * const kToolsKey = @"tools";
static NSString * const kPickerKey = @"picker";
static NSString * const kFilterIndexKey = @"filterIndex";
static NSString * const kColorKey = @"color";
static NSString * const kColorOptionsKey = @"colorOptions";
static NSString * const kDefaultTextKey = @"defaultText";
static NSString * const kCharacterLimit = @"characterLimit";

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

// Profile properties
static NSString * const kProfileEditButtonStyle = @"editButtonStyle";

typedef NS_ENUM(NSUInteger, VTemplateType)
{
    VTemplateTypeA,
    VTemplateTypeC,
    VTemplateTypeD
};

// First-time User Video
static NSString * const kFirstTimeVideoView = @"firstTimeVideoView";


@interface VTemplateGenerator ()

@property (nonatomic, strong) NSDictionary *dataFromInitCall;
@property (nonatomic) VTemplateType enabledTemplate;
@property (nonatomic, strong) NSString *firstMenuItemID;
@property (nonatomic, strong) NSString *homeRecentID;
@property (nonatomic, strong) NSString *inboxRecentID;
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
        _inboxRecentID = [[NSUUID UUID] UUIDString];
        _communityRecentID = [[NSUUID UUID] UUIDString];
        
        //Adjust templateType (between C and D on dev) here
        self.enabledTemplate = VTemplateTypeD;
    }

    return self;
}

//Fetches from the (deprecated) api/init call and creates a templateGenerator from it
+ (void)logExampleTemplate
{
    [[VObjectManager sharedManager] appInitWithSuccessBlock:^(NSOperation *operation, id result, NSArray *resultObjects) {
        
        VTemplateGenerator *templateGen = [[VTemplateGenerator alloc] initWithInitData:result[@"payload"]];
        [templateGen.configurationDict logJSONStringWithTitle:@"FROM TEMPLATE GEN"];
        
    } failBlock:^(NSOperation *operation, NSError *error) {
        
        
    }];
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
         else if ( [key isEqual:kExperimentsKey] )
         {
             if ( [obj isKindOfClass:[NSDictionary class]] )
             {
                 [template addEntriesFromDictionary:obj];
             }
         }
         else
         {
             template[key] = obj;
         }
     }];
    if ( self.enabledTemplate == VTemplateTypeD )
    {
        template[VDependencyManagerScaffoldViewControllerKey] = @{
                                                                  kClassNameKey: @"tabMenu.scaffold",
                                                                  kItemsKey:[self bottomNavMenuItems],
                                                                  kUserProfileView: [self profileScreen],
                                                                  VScaffoldViewControllerFirstTimeContentKey: [self lightweightContentViewComponent],
                                                                  kSelectorKey: [self multiScreenSelectorKey],
                                                                  @"appearance": @{
                                                                          VDependencyManagerBackgroundKey: [self solidWhiteBackground],
                                                                          },
                                                                  VDependencyManagerAccentColorKey: @{
                                                                          kRedKey: @228,
                                                                          kGreenKey: @65,
                                                                          kBlueKey: @66,
                                                                          kAlphaKey: @1
                                                                          },
                                                                  kContentView: [self contentViewComponent],
                                                                  };
    }
    else
    {
        template[VDependencyManagerScaffoldViewControllerKey] = @{ kClassNameKey: @"sideMenu.scaffold",
                                                                   VHamburgerButtonIconKey: @{
                                                                           VDependencyManagerImageURLKey:(self.enabledTemplate == VTemplateTypeC ? @"menuC":@"Menu"),
                                                                           },
                                                                   VDependencyManagerInitialViewControllerKey: @{ kReferenceIDKey: self.firstMenuItemID },
                                                                   VScaffoldViewControllerMenuComponentKey: [self menuComponent],
                                                                   VStreamCollectionViewControllerCreateSequenceIconKey: (self.enabledTemplate == VTemplateTypeC ? [UIImage imageNamed:@"createContentButtonC"] : [UIImage imageNamed:@"createContentButton"]),
                                                                   kUserProfileView: [self profileScreen],
                                                                   VScaffoldViewControllerFirstTimeContentKey: [self lightweightContentViewComponent],
                                                                   kSelectorKey: [self multiScreenSelectorKey],
                                                                   kContentView: [self contentViewComponent],
                                                                   };
    }

    template[VDependencyManagerWorkspaceFlowKey] = [self workspaceFlowComponent];
    template[VDependencyManagerTextWorkspaceFlowKey] = [self textWorkspaceFlowComponent];
    template[VScaffoldViewControllerNavigationBarAppearanceKey] = [self navigationBarAppearance];
    template[VStreamCollectionViewControllerCellComponentKey] = [self cellComponent];
    template[@"vote_types"] = [self voteTypes];
    
    return template;
}

- (NSDictionary *)cellComponent
{
    NSString *className = @"titleOverlay.streamCell";
    if ( self.enabledTemplate == VTemplateTypeD )
    {
        className = @"sleek.streamCell";
    }
    else if ( self.enabledTemplate == VTemplateTypeC )
    {
        className = @"inset.streamCell";
    }
    
    return @{
             kClassNameKey: className
             };
}

- (NSDictionary *)multiScreenSelectorKey
{
    NSDictionary *kSelectorKey = @{
                                   kClassNameKey: @"basic.multiScreenSelector",
                                   };

    if ( self.enabledTemplate == VTemplateTypeD )
    {
        kSelectorKey =  @{
                          kClassNameKey: @"rounded.multiScreenSelector",
                          VDependencyManagerBackgroundColorKey:@{
                                  kRedKey: @255,
                                  kBlueKey: @255,
                                  kGreenKey: @255,
                                  kAlphaKey: @1
                                  }
                          };
    }
    else if ( self.enabledTemplate == VTemplateTypeC )
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

- (NSDictionary *)textWorkspaceFlowComponent
{
    return @{
             kClassNameKey: @"workspaceText",
             kCharacterLimit: @140,
             kDefaultTextKey: @"Type your text here!",
             VDependencyManagerEditTextWorkspaceKey: @{
                     kClassNameKey: @"workspace.screen",
                     kToolsKey: @[
                             [self hashtagTool],
                             [self colorTool]
                             ]
                     },
             };
}

- (NSDictionary *)contentViewComponent
{
    return @{
             kClassNameKey: @"standard.contentView",
             @"histogram_enabled": @NO,
             };
}

- (NSArray *)voteTypes
{
    NSMutableArray *voteTypes = [[NSMutableArray alloc] init];
    for ( NSDictionary *voteType in self.dataFromInitCall[@"votetypes"] )
    {
        NSMutableDictionary *templateVoteType = [@{
                               kClassNameKey: @"animated.voteType",
                               @"voteTypeID": voteType[@"id"],
                               @"voteTypeName": voteType[@"name"],
                               @"value": voteType[@"value"],
                               @"images": @{
                                       @"imageCount": @([voteType[@"frames"] integerValue]),
                                       @"imageMacro": voteType[@"image_macro"],
                                       @"scale": @([voteType[@"scale_factor"] integerValue]),
                                       },
                               @"animationDuration": @([voteType[@"animation_duration"] integerValue]),
                               @"displayOrder": @([voteType[@"display_order"] integerValue]),
                               @"flightDuration": @([voteType[@"flight_duration"] integerValue]),
                               @"icon": voteType[@"icon"],
                               @"isPaid": voteType[@"is_paid"],
                               @"appleProductID": voteType[@"apple_product_id"],
                               @"viewContentMode": voteType[@"view_content_mode"],
                               @"tracking": voteType[@"tracking"],
                               } mutableCopy];
        
        NSString *iconLarge = voteType[@"icon_large"];
        if ( [iconLarge isKindOfClass:[NSString class]] )
        {
            templateVoteType[@"iconLarge"] = iconLarge;
        }
        [voteTypes addObject:templateVoteType];
    }
    return voteTypes;
}

- (NSArray *)videoTools
{
    return @[
             @{
                 kClassNameKey: @"trim.video.tool",
                 kTitleKey: NSLocalizedString(@"VIDEO MODE", @"Title informing the user they have selected the video tool."),
                 kIconKey:@{
                         VDependencyManagerImageURLKey:@"video"
                         },
                 kSelectedIconKey:@{
                         VDependencyManagerImageURLKey:@"videoSelected",
                         },
                 kVideoFrameDurationValue: @1,
                 kVideoFrameDurationTimescale: @24,
                 kVideoMuted: @NO
                 },
             @{
                 kClassNameKey: @"trim.video.tool",
                 kTitleKey: NSLocalizedString(@"GIF MODE", @"Title informing the user they have selected the GIF tool."),
                 kIconKey:@{
                         VDependencyManagerImageURLKey:@"GIF"
                         },
                 kSelectedIconKey:@{
                         VDependencyManagerImageURLKey:@"GIFSelected"
                         },
                 kVideoFrameDurationValue: @1,
                 kVideoFrameDurationTimescale: @8,
                 kVideoMuted: @YES,
                 @"isGIF": @YES,
                 },
             @{
                 kClassNameKey: @"snapshot.video.tool",
                 kTitleKey: @"meme",
                 kIconKey:@{
                         VDependencyManagerImageURLKey:@"meme",
                         },
                 kSelectedIconKey:@{
                         VDependencyManagerImageURLKey:@"memeSelected",
                         },
                 },
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

- (NSDictionary *)hashtagTool
{
    return @{
             kClassNameKey: @"hashtag.tool",
             kTitleKey: @"hashtag",
             kFilterIndexKey: @0,
             kIconKey: @{
                     VDependencyManagerImageURLKey: @"hashtagIcon",
                     },
             kSelectedIconKey: @{
                     VDependencyManagerImageURLKey: @"hashtagIcon_selected",
                     },
             kPickerKey:
                 @{
                     kClassNameKey: @"vertical.multiplePicker"
                     }
             };
}

- (NSDictionary *)colorTool
{
    return @{
             kClassNameKey: @"textColor.tool",
             kTitleKey: @"color",
             kFilterIndexKey: @1,
             kIconKey: @{
                     VDependencyManagerImageURLKey: @"textColorIcon",
                     },
             kSelectedIconKey: @{
                     VDependencyManagerImageURLKey: @"textColorIcon_selected",
                     },
             kPickerKey:
                 @{
                     kClassNameKey: @"vertical.picker"
                     },
             kColorOptionsKey : @[
                     @{ kTitleKey : @"Red",
                        kColorKey: @{
                                kRedKey: @181,
                                kGreenKey: @35,
                                kBlueKey: @48,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Magenta",
                        kColorKey: @{
                                kRedKey: @233,
                                kGreenKey: @89,
                                kBlueKey: @106,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Orange",
                        kColorKey: @{
                                kRedKey: @233,
                                kGreenKey: @112,
                                kBlueKey: @71,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Peach",
                        kColorKey: @{
                                kRedKey: @247,
                                kGreenKey: @200,
                                kBlueKey: @99,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Yellow",
                        kColorKey: @{
                                kRedKey: @233,
                                kGreenKey: @167,
                                kBlueKey: @33,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Green",
                        kColorKey: @{
                                kRedKey: @134,
                                kGreenKey: @199,
                                kBlueKey: @121,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Teal",
                        kColorKey: @{
                                kRedKey: @22,
                                kGreenKey: @160,
                                kBlueKey: @160,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Blue",
                        kColorKey: @{
                                kRedKey: @60,
                                kGreenKey: @129,
                                kBlueKey: @195,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Purple",
                        kColorKey: @{
                                kRedKey: @102,
                                kGreenKey: @71,
                                kBlueKey: @156,
                                kAlphaKey: @1.0f }
                        },
                     @{ kTitleKey : @"Black",
                        kColorKey: @{
                                kRedKey: @44,
                                kGreenKey: @39,
                                kBlueKey: @35,
                                kAlphaKey: @1.0f }
                        }
                     ]
             };
}

- (NSDictionary *)preferredBackgroundColor
{
    if ( self.enabledTemplate != VTemplateTypeA )
    {
        return @{ kRedKey: @241, kGreenKey: @241, kBlueKey: @241, kAlphaKey: @1 };
    }
    else
    {
        return self.dataFromInitCall[@"appearance"][@"color.accent.secondary"];
    }
}

- (NSDictionary *)textTool
{
    return @{
             kClassNameKey: @"text.tool",
             kTitleKey: @"text",
             kFilterIndexKey: @2,
             kIconKey:@{
                     VDependencyManagerImageURLKey:@"text",
                     },
             kSelectedIconKey:@{
                     VDependencyManagerImageURLKey:@"textSelected",
                     },
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
             kIconKey:@{
                     VDependencyManagerImageURLKey:@"filter",
                     },
             kSelectedIconKey:@{
                     VDependencyManagerImageURLKey:@"filterSelected",
                     },
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
             kIconKey:@{
                     VDependencyManagerImageURLKey:@"crop",
                     },
             kSelectedIconKey:@{
                     VDependencyManagerImageURLKey:@"cropSelected",
                     },
             kFilterIndexKey: @1,
             };
}

- (NSDictionary *)navigationBarAppearance
{
    if ( self.enabledTemplate != VTemplateTypeA )
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

- (NSDictionary *)lightweightContentViewComponent
{
    NSString *sequenceID = self.dataFromInitCall[@"experiments"][@"ftue_welcome_sequence_id"];
    NSArray *trackingArray = self.dataFromInitCall[@"experiments"][@"ftue_welcome_tracking"][@"start"];
    return @{
             kClassNameKey: @"lightweight.contentView",
             @"sequenceURL": [NSString stringWithFormat:@"/api/sequence/fetch/%@", sequenceID],
             @"tracking":  trackingArray ?: @[]
             };
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
                                VStreamCollectionViewControllerStreamURLKey: @"/api/sequence/hot_detail_list_by_stream/ugc/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%",
                                kCanAddContentKey: @YES,
                                VStreamCollectionViewControllerCellComponentKey: [self cellComponent]
                            },
                            @{
                                kClassNameKey: @"stream.screen",
                                kIDKey: self.communityRecentID,
                                kTitleKey: NSLocalizedString(@"Recent", @""),
                                VStreamCollectionViewControllerStreamURLKey: [self urlPathForStreamCategories:VUGCCategories()],
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
                [self settingsMenuItem],
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
                     VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@home", TEMPLATE_ICON_PREFIX],
                     },
             kSelectedIconKey: @{
                     VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@home%@", TEMPLATE_ICON_PREFIX, SELECTED_ICON_SUFFIX],
                     }
             };
}

- (NSDictionary *)createMenuItem
{
    return @{
             kTitleKey: NSLocalizedString(@"Create", @""),
             kIconKey: @{
                     VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@create", TEMPLATE_ICON_PREFIX],
                     },
             kSelectedIconKey: @{
                     VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@create%@", TEMPLATE_ICON_PREFIX, SELECTED_ICON_SUFFIX],
                     },
             kDestinationKey: [self workspaceFlowComponent],
             };
}

- (NSDictionary *)profileMenuItem
{
    NSMutableDictionary *profileItem = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                         kIdentifierKey: @"Menu Profile",
                                                                                         kTitleKey: NSLocalizedString(@"Profile", @""),
                                                                                         kIconKey: @{
                                                                                                 VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@profile", TEMPLATE_ICON_PREFIX],
                                                                                                 },
                                                                                         kSelectedIconKey: @{
                                                                                                 VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@profile%@", TEMPLATE_ICON_PREFIX, SELECTED_ICON_SUFFIX],
                                                                                                 }
                              
                                                                                         }];
    NSMutableDictionary *fullProfileDetails = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                            kClassNameKey: @"currentUserProfile.screen",
                                                                                            }];
    [fullProfileDetails addEntriesFromDictionary:[self profileConfiguration]];
    profileItem[kDestinationKey] = fullProfileDetails;
    if ( self.enabledTemplate == VTemplateTypeD )
    {
        profileItem[VDependencyManagerAccessoryScreensKey] = @[[self settingsMenuItem]];
    }
    profileItem[kProfileEditButtonStyle] = self.enabledTemplate == VTemplateTypeD ? @"rounded" : @"default";
    
    return [NSDictionary dictionaryWithDictionary:profileItem];
}

- (NSDictionary *)inboxMenuItem
{
    
    return @{ kIdentifierKey: @"Menu Inbox",
              kTitleKey: NSLocalizedString(@"Inbox", @""),
              kIconKey: @{
                      VDependencyManagerImageURLKey: @"D_inbox",
                      },
              kCellComponentDirectoryItem: [self directoryCellComponentLight],
              kDestinationKey: @{
                      kClassNameKey: @"basic.multiScreen",
                      kTitleKey: NSLocalizedString(@"Inbox", @""),
                      kScreensKey: @[
                              @{
                                  kClassNameKey: @"inbox.screen",
                                  kTitleKey: NSLocalizedString(@"Messages", @""),
                                  },
                              @{
                                  kClassNameKey: @"notifications.screen",
                                  kTitleKey: NSLocalizedString(@"Notifications", @""),
                                  }
                              ]
                      },
              };
}

- (NSDictionary *)settingsMenuItem
{
    return @{
             kIdentifierKey: @"Menu Settings",
             kTitleKey: NSLocalizedString(@"Settings", @""),
             kDestinationKey: @{
                     kClassNameKey: @"settings.screen"
                     },
             kIconKey: @{
                     VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@settings", TEMPLATE_ICON_PREFIX],
                     },
             kSelectedIconKey: @{
                     VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@settings%@", TEMPLATE_ICON_PREFIX, SELECTED_ICON_SUFFIX],
                     },
             };
}

- (NSString *)urlPathForStreamCategories:(NSArray *)categories
{
    NSString *categoryString = [categories componentsJoinedByString:@","] ?: @"0";
    return [NSString stringWithFormat:@"/api/sequence/detail_list_by_category/%@/%%%%PAGE_NUM%%%%/%%%%ITEMS_PER_PAGE%%%%", categoryString];
}

- (NSDictionary *)profileConfiguration
{
    NSMutableDictionary *profileConfiguration = [[NSMutableDictionary alloc] init];
    if ( self.enabledTemplate == VTemplateTypeD )
    {
        profileConfiguration[VDependencyManagerLinkColorKey] = @{
                                                                 kRedKey: @30,
                                                                 kGreenKey: @173,
                                                                 kBlueKey: @217,
                                                                 kAlphaKey: @1
                                                                 };
        [profileConfiguration addEntriesFromDictionary:[self lightProfileDetails]];
    }
    else
    {
        [profileConfiguration addEntriesFromDictionary:[self lightProfileDetails]];
    }
    profileConfiguration[VStreamCollectionViewControllerCellComponentKey] = [self cellComponent];
    profileConfiguration[VDependencyManagerAccessoryScreensKey] = @[[self settingsMenuItem]];
    return [profileConfiguration copy];
}

- (NSDictionary *)darkProfileDetails
{
    return @{ VDependencyManagerBackgroundColorKey : @{
                                                             kRedKey: @20,
                                                             kGreenKey: @20,
                                                             kBlueKey: @20,
                                                             kAlphaKey: @1
                                                             },
              VDependencyManagerSecondaryBackgroundColorKey : @{
                                                                      kRedKey: @38,
                                                                      kGreenKey: @39,
                                                                      kBlueKey: @42,
                                                                      kAlphaKey: @1
                                                                      },
              VDependencyManagerContentTextColorKey : @{
                                                              kRedKey: @204,
                                                              kGreenKey: @204,
                                                              kBlueKey: @204,
                                                              kAlphaKey: @1
                                                              }
              };
}

- (NSDictionary *)lightProfileDetails
{
    return @{ VDependencyManagerBackgroundColorKey: @{
                      kRedKey: @241,
                      kGreenKey: @241,
                      kBlueKey: @241,
                      kAlphaKey: @1
                      },
              VDependencyManagerAccentColorKey: @{
                      kRedKey: @228,
                      kGreenKey: @65,
                      kBlueKey: @66,
                      kAlphaKey: @1
                      },
              VDependencyManagerContentTextColorKey: @{
                      kRedKey: @0,
                      kGreenKey: @0,
                      kBlueKey: @0,
                      kAlphaKey: @1
                      }
              };
}


- (NSDictionary *)profileScreen
{
    NSMutableDictionary *fullProfileDetails = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                kClassNameKey: @"userProfile.screen",
                                                                                                }];
    [fullProfileDetails addEntriesFromDictionary:[self profileConfiguration]];
    
    return [NSDictionary dictionaryWithDictionary:fullProfileDetails];
}

- (NSDictionary *)homeScreen
{
    NSMutableDictionary *homeScreen = [@{
        kIDKey: self.firstMenuItemID,
        kClassNameKey: @"basic.multiScreen",
        VDependencyManagerBackgroundColorKey: [self preferredBackgroundColor],
        kScreensKey: @[
                @{
                    kClassNameKey: @"stream.screen",
                    kTitleKey: NSLocalizedString(@"Featured", @""),
                    VStreamCollectionViewControllerStreamURLKey: @"/api/sequence/hot_detail_list_by_stream/home/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%",
                    kIsHomeKey: @YES,
                    kCanAddContentKey: @YES,
                    },
                @{
                    kIDKey: self.homeRecentID,
                    kClassNameKey: @"stream.screen",
                    kTitleKey: NSLocalizedString(@"Recent", @""),
                    VStreamCollectionViewControllerStreamURLKey: [self urlPathForStreamCategories:[VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]],
                    kCanAddContentKey: @YES,
                    kMarqueeKey: @YES,
                    },
                @{
                    kClassNameKey: @"followingStream.screen",
                    kTitleKey: NSLocalizedString(@"Following", @""),
                    VStreamCollectionViewControllerStreamURLKey: @"/api/sequence/follows_detail_list_by_stream/0/home/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%",
                    kCanAddContentKey: @YES,
                    }
                ],
        kInitialKey: @{
                kReferenceIDKey: self.homeRecentID,
                },
        VStreamCollectionViewControllerCellComponentKey: [self cellComponent]
        } mutableCopy];
    UIImage *headerImage = [self homeHeaderImage];
    if ( headerImage != nil )
    {
        homeScreen[kTitleImageKey] = headerImage;
    }
    
    if ( self.enabledTemplate == VTemplateTypeA )
    {
        //Add lots of white for template A
        homeScreen[VDependencyManagerLinkColorKey] = @{
                                                       kRedKey: @255,
                                                       kGreenKey: @255,
                                                       kBlueKey: @255,
                                                       kAlphaKey: @1
                                                       };
        homeScreen[VDependencyManagerContentTextColorKey] = @{
                                                              kRedKey: @255,
                                                              kGreenKey: @255,
                                                              kBlueKey: @255,
                                                              kAlphaKey: @1
                                                              };
        homeScreen[VDependencyManagerBackgroundColorKey] = @{
                                                             kRedKey: @255,
                                                             kGreenKey: @255,
                                                             kBlueKey: @255,
                                                             kAlphaKey: @1
                                                             };
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
      VStreamCollectionViewControllerStreamURLKey: [self urlPathForStreamCategories:[VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]]
    };

    NSNumber *marqueeEnabled = [self.dataFromInitCall valueForKeyPath:@"experiments.marquee_enabled"];
    if ( [marqueeEnabled isKindOfClass:[NSNumber class]] && [marqueeEnabled boolValue] )
    {
        NSMutableDictionary *mutableStream = [stream mutableCopy];
        mutableStream[kMarqueeKey] = @{ VStreamCollectionViewControllerStreamURLKey: @"/api/sequence/detail_list_by_stream/marquee" };
        return [mutableStream copy];
    }
    return stream;
}

- (NSDictionary *)ownerStreamMenuItem
{
    NSNumber *channelsEnabledObject = [self.dataFromInitCall valueForKeyPath:@"experiments.channels_enabled"];
    const BOOL channelsEnabled = [channelsEnabledObject isKindOfClass:[NSNumber class]] && [channelsEnabledObject boolValue];
    
    if ( self.enabledTemplate == VTemplateTypeD && channelsEnabled )
    {
        NSDictionary *componentBase = @{ kIdentifierKey: @"Menu Channels",
                                         kTitleKey: NSLocalizedString(@"Channels", @""),
                                         kIconKey: @{
                                                 VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@channels", TEMPLATE_ICON_PREFIX],
                                                 },
                                         kSelectedIconKey: @{
                                                 VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@channels%@", TEMPLATE_ICON_PREFIX, SELECTED_ICON_SUFFIX],
                                                 },
                                         kDestinationKey: @{
                                                 kClassNameKey: @"showcase.screen",
                                                 kTitleKey: NSLocalizedString(@"Channels", nil),
                                                 VStreamCollectionViewControllerStreamURLKey: @"/api/sequence/detail_list_by_stream/directory/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
                                                 }
                                         };
        NSMutableDictionary *completeComponent = [[NSMutableDictionary alloc] initWithDictionary:componentBase];
        [completeComponent addEntriesFromDictionary:[self directoryComponentLight]];
        return [NSDictionary dictionaryWithDictionary:completeComponent];
    }
    else if ( channelsEnabled )
    {
        return @{ kIdentifierKey: @"Menu Channels",
                  kTitleKey: NSLocalizedString(@"Channels", @""),
                  kIconKey: @{
                          VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@channels", TEMPLATE_ICON_PREFIX],
                          },
                  kSelectedIconKey: @{
                          VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@channels%@", TEMPLATE_ICON_PREFIX, SELECTED_ICON_SUFFIX],
                          },
                  kDestinationKey: @{
                          kClassNameKey: @"streamDirectory.screen",
                          kTitleKey: NSLocalizedString(@"Channels", nil),
                          VStreamCollectionViewControllerStreamURLKey: @"/api/sequence/detail_list_by_stream/directory/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
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
    else
    {
        return @{ kIdentifierKey: @"Menu Channel",
                  kTitleKey: NSLocalizedString(@"Channel", @""),
                  kIconKey: @{
                          VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@channels", TEMPLATE_ICON_PREFIX]
                          },
                  kSelectedIconKey: @{
                          VDependencyManagerImageURLKey: [NSString stringWithFormat:@"%@channels%@", TEMPLATE_ICON_PREFIX, SELECTED_ICON_SUFFIX]
                          },
                  kCellComponentDirectoryItem: [self directoryCellComponentLight],
                  kDestinationKey: @{
                          kClassNameKey: @"basic.multiScreen",
                          kTitleKey: NSLocalizedString(@"Owner", @""),
                          kScreensKey: @[
                                  @{
                                      kClassNameKey: @"stream.screen",
                                      kTitleKey: NSLocalizedString(@"Featured", @""),
                                      VStreamCollectionViewControllerStreamURLKey: @"/api/sequence/hot_detail_list_by_stream/owner/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%",
                                      VStreamCollectionViewControllerCellComponentKey: [self cellComponent]
                                      },
                                  @{
                                      kClassNameKey: @"stream.screen",
                                      kInitialKey: @YES,
                                      kTitleKey: NSLocalizedString(@"Recent", @""),
                                      VStreamCollectionViewControllerStreamURLKey: [self urlPathForStreamCategories:VOwnerCategories()],
                                      VStreamCollectionViewControllerCellComponentKey: [self cellComponent]
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

- (NSDictionary *)translucentDarkBackground
{
    return @{
             kClassNameKey:@"translucent.background",
             VTranslucentBackgroundBlurStyleKey: VTranslucentBackgroundBlurStyleDark,
             };
}

@end
