//
//  VActionSheetViewController.m
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionSheetViewController.h"

// Theme
#import "VThemeManager.h"

// Cells
#import "VActionItemTableViewCell.h"
#import "VDescriptionTableViewCell.h"

// Categories
#import "UIView+MotionEffects.h"
#import "UIView+VShadows.h"

typedef NS_ENUM(NSInteger, VActionSheetTableViewSecion)
{
    VActionSheetTableViewSecionDescription,
    VActionSheetTableViewSecionActions,
    VActionSheetTableViewSecionCount
};

@interface VActionSheetViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *addedItems;
@property (nonatomic, strong) NSArray *actionItems;
@property (nonatomic, strong) VActionItem *userItem;
@property (nonatomic, strong) VActionItem *descriptionItem;

@property (weak, nonatomic) IBOutlet UIView *blurringContainer;
@property (weak, nonatomic) IBOutlet UITableView *actionItemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *AvatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCaptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *gradientContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blurringContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSeparatorHeightConstraint;

@end

static const CGFloat kBlurrGradientHeight = 10.0f;
static const UIEdgeInsets kSeparatorInsets = {0.0f, 20.0f, 0.0f, 20.0f};

@implementation VActionSheetViewController

#pragma mark - Factory Methods

+ (VActionSheetViewController *)actionSheetViewController
{
    UIStoryboard *ourStoryboard = [UIStoryboard storyboardWithName:@"ActionSheet" bundle:nil];
    return [ourStoryboard instantiateInitialViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIToolbar *blurredView = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(self.blurringContainer.bounds),
                                                                         CGRectGetHeight(self.blurringContainer.bounds) * 2.0f)];
    blurredView.translucent = YES;
    blurredView.barStyle = UIBarStyleDefault;
    blurredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.blurringContainer insertSubview:blurredView
                                  atIndex:0];
    
    [self.AvatarImageView v_addMotionEffectsWithMagnitude:10.0f];
    self.AvatarImageView.layer.cornerRadius = CGRectGetWidth(self.AvatarImageView.bounds) * 0.5f;
    self.AvatarImageView.layer.masksToBounds = YES;
    self.AvatarImageView.layer.borderWidth = 2.0f;
    self.AvatarImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor].CGColor;

    self.tableView.separatorInset = kSeparatorInsets;
    
    // gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.tableView.frame;
    gradient.colors = @[(id)[UIColor blackColor].CGColor,
                        (id)[UIColor clearColor].CGColor
                        ];
    gradient.locations = @[
                           @(1 - (kBlurrGradientHeight / CGRectGetHeight(self.tableView.bounds))),
                           @1.0f,
                           ];
    [self.gradientContainer.layer insertSublayer:gradient atIndex:0];
    self.gradientContainer.layer.mask = gradient;
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.userCaptionLabel.font = [[[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font] fontWithSize:18.0f];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];

    self.topSeparatorHeightConstraint.constant = 1 / [UIScreen mainScreen].scale;
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
}

#pragma mark - Property Accessors

- (UIView *)avatarView
{
    return self.AvatarImageView;
}

- (CGFloat)totalHeight
{
    return CGRectGetHeight(self.blurringContainer.bounds) + (CGRectGetHeight(self.AvatarImageView.bounds) * 0.5f);
}

#pragma mark - IBActions

- (IBAction)pressedCancel:(id)sender
{
    if (self.cancelHandler)
    {
        self.cancelHandler();
    }
}

- (IBAction)pressedTapAwayButton:(id)sender
{
    if (self.cancelHandler)
    {
        self.cancelHandler();
    }
}

- (IBAction)pressedAvatarButton:(id)sender
{
    if (self.userItem.selectionHandler)
    {
        self.userItem.selectionHandler();
    }
}

#pragma mark - Public Methods

- (void)addActionItems:(NSArray *)actionItems
{
    self.addedItems = actionItems;
}

- (void)reloadData
{
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    [self.addedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (![obj isKindOfClass:[VActionItem class]])
         {
             NSAssert(false, @"All action items must be of class VActionItem");
         }
         VActionItem *actionItem = (VActionItem *)obj;
         switch (actionItem.type)
         {
             case VActionItemTypeDefault:
                 [actionItems addObject:actionItem];
                 break;
             case VActionItemTypeUser:
                 [self.AvatarImageView setImageWithURL:actionItem.avatarURL
                                      placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
                 self.usernameLabel.text = actionItem.title;
                 self.userCaptionLabel.text = [actionItem.detailText uppercaseStringWithLocale:[NSLocale currentLocale]];
                 self.userItem = actionItem;
                 break;
             case VActionItemTypeDescriptionWithHashTags:
                 self.descriptionItem = actionItem;
                 break;
         }
     }];
    self.actionItems = [NSArray arrayWithArray:actionItems];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VActionSheetTableViewSecionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case VActionSheetTableViewSecionDescription:
            return 1;
        case VActionSheetTableViewSecionActions:
            return (NSInteger)self.actionItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case VActionSheetTableViewSecionDescription:
        {
            VDescriptionTableViewCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"VDescriptionTableViewCell"];
            descriptionCell.descriptionText = self.descriptionItem.detailText;
            descriptionCell.hashTagSelectionBlock = ^void(NSString *hashTag)
            {
                if (self.descriptionItem.hashTagSelectionHandler)
                {
                    self.descriptionItem.hashTagSelectionHandler(hashTag);
                }
            };
            return descriptionCell;
        }
        case VActionSheetTableViewSecionActions:
        {
            VActionItemTableViewCell *actionitemCell = [tableView dequeueReusableCellWithIdentifier:@"VActionItemTableViewCell"];
            VActionItem *itemForCell = [self.actionItems objectAtIndex:indexPath.row];
            actionitemCell.title = itemForCell.title;
            actionitemCell.detailTitle = itemForCell.detailText;
            actionitemCell.actionIcon = itemForCell.icon;
            actionitemCell.separatorInsets = self.tableView.separatorInset;
            actionitemCell.accessorySelectionHandler = ^(void)
            {
                if (itemForCell.detailSelectionHandler)
                {
                    itemForCell.detailSelectionHandler();
                }
            };
            
            return actionitemCell;
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case VActionSheetTableViewSecionDescription:
        {
            CGFloat height = [VDescriptionTableViewCell desiredHeightWithTableViewWidth:CGRectGetWidth(tableView.bounds)
                                                                         text:self.descriptionItem.detailText];
            return height;
        }
        case VActionSheetTableViewSecionActions:
        {
            return 44.0f;
        }
    }
    return 44.0f;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case VActionSheetTableViewSecionDescription:
            return NO;
        case VActionSheetTableViewSecionActions:
        {
            VActionItem *actionItem = [self.actionItems objectAtIndex:indexPath.row];
            return actionItem.enabled;
        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VActionItem *actionItem = [self.actionItems objectAtIndex:indexPath.row];
    if (actionItem.selectionHandler)
    {
        actionItem.selectionHandler();
    }
}

@end
