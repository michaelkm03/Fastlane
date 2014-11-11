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

// SubViews
#import "VDefaultProfileImageView.h"
#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"

// Cells
#import "VActionItemTableViewCell.h"
#import "VDescriptionTableViewCell.h"

// Categories
#import "UIView+MotionEffects.h"
#import "UIView+VShadows.h"

// Gesture Recognizers
#import "CCHLinkGestureRecognizer.h"

@interface VActionSheetViewController () <UITableViewDelegate, UITableViewDataSource, CCHLinkTextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *addedItems;
@property (nonatomic, strong) NSArray *actionItems;
@property (nonatomic, strong) VActionItem *userItem;
@property (nonatomic, strong) VActionItem *descriptionItem;

@property (weak, nonatomic) IBOutlet UIView *blurringContainer;
@property (weak, nonatomic) IBOutlet UITableView *actionItemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet VDefaultProfileImageView *AvatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCaptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *gradientContainer;
@property (weak, nonatomic) IBOutlet CCHLinkTextView *titleTextView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapAwayGestureRecognizer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blurringContainerHeightConstraint;

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

    self.tableView.separatorInset = kSeparatorInsets;
    
    // gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.gradientContainer.bounds;
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
    self.userCaptionLabel.font = [[[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font] fontWithSize:9];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupTitleTextView];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressedTapAwayButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    __block CGFloat blurredContainerHeight = CGRectGetHeight(self.blurringContainer.bounds) - CGRectGetHeight(self.tableView.bounds);
    
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
                 blurredContainerHeight = blurredContainerHeight + 44.0f;
                 break;
             case VActionItemTypeUser:
                 [self.AvatarImageView setProfileImageURL:actionItem.avatarURL];
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
    self.blurringContainerHeightConstraint.constant = fminf(blurredContainerHeight, CGRectGetHeight(self.view.bounds) * 0.75f);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.actionItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VActionItemTableViewCell *actionitemCell = [tableView dequeueReusableCellWithIdentifier:@"VActionItemTableViewCell"];
    VActionItem *itemForCell = [self.actionItems objectAtIndex:indexPath.row];
    actionitemCell.title = itemForCell.title;
    actionitemCell.detailTitle = itemForCell.detailText;
    actionitemCell.actionIcon = itemForCell.icon;
    actionitemCell.separatorInsets = self.tableView.separatorInset;
    actionitemCell.enabled = itemForCell.enabled;
    actionitemCell.accessorySelectionHandler = ^(void)
    {
        if (itemForCell.detailSelectionHandler)
        {
            itemForCell.detailSelectionHandler();
        }
    };
    
    return actionitemCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.indexPathForSelectedRow)
    {
        return NO;
    }
    
    VActionItem *actionItem = [self.actionItems objectAtIndex:indexPath.row];
    return actionItem.enabled;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VActionItem *actionItem = [self.actionItems objectAtIndex:indexPath.row];
    self.view.userInteractionEnabled = NO;
    if (actionItem.selectionHandler)
    {
        actionItem.selectionHandler();
    }
}

#pragma mark - Private Methods

- (void)setupTitleTextView
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:self.descriptionItem.title
                                                                                               attributes:@{NSFontAttributeName:[[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font],
                                                                                                            NSParagraphStyleAttributeName:paragraphStyle,
                                                                                                            NSForegroundColorAttributeName:[[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor]}];
    [self.tapAwayGestureRecognizer requireGestureRecognizerToFail:self.titleTextView.linkGestureRecognizer];
    self.titleTextView.attributedText = mutableAttributedString;
    self.titleTextView.linkDelegate = self;
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    if (self.descriptionItem.hashTagSelectionHandler)
    {
        self.descriptionItem.hashTagSelectionHandler(value);
    }
}

@end
