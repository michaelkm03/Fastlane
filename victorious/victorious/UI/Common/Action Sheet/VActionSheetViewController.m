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
#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"

// Cells
#import "VActionItemTableViewCell.h"
#import "VDescriptionTableViewCell.h"

// Categories
#import "UIView+MotionEffects.h"

// Gesture Recognizers
#import "CCHLinkGestureRecognizer.h"
#import "VHashTagTextView.h"

#import "VDependencyManager.h"


@interface VActionSheetViewController () <UITableViewDelegate, UITableViewDataSource, CCHLinkTextViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSArray *addedItems;
@property (nonatomic, strong) NSArray *actionItems;
@property (nonatomic, strong) VActionItem *userItem;
@property (nonatomic, strong) VActionItem *descriptionItem;

@property (weak, nonatomic) IBOutlet UIView *blurringContainer;
@property (weak, nonatomic) IBOutlet UITableView *actionItemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCaptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *gradientContainer;
@property (weak, nonatomic) IBOutlet VHashTagTextView *titleTextView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapAwayGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIView *emptySpaceContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpace;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blurringContainerHeightConstraint;
@property (nonatomic, strong) CAGradientLayer *gradient;

@end

static const CGFloat kBlurrGradientHeight = 10.0f;
static const UIEdgeInsets kSeparatorInsets = {0.0f, 20.0f, 0.0f, 20.0f};

@implementation VActionSheetViewController

#pragma mark - Initializers

- (instancetype)init
{
    UIStoryboard *ourStoryboard = [UIStoryboard storyboardWithName:@"ActionSheet" bundle:nil];
    return [ourStoryboard instantiateInitialViewController];
}

#pragma mark - dealloc

- (void)dealloc
{
    _tapAwayGestureRecognizer.delegate = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleTextView.text = nil;
    self.usernameLabel.text = nil;
    self.userCaptionLabel.text = nil;
    
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
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.userCaptionLabel.font = [[[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font] fontWithSize:9];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    
    self.titleTextView.dependencyManager = self.dependencyManager;
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.userInteractionEnabled = YES;
    
    self.tapAwayGestureRecognizer.delegate = self;
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self setupTitleTextView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Properties

- (UIView *)avatarView
{
    return self.profileButton;
}

- (CGFloat)totalHeight
{
    return CGRectGetHeight(self.blurringContainer.bounds) + (CGRectGetHeight(self.profileButton.bounds) * 0.5f);
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if (dependencyManager != nil)
    {
        [self.titleTextView setDependencyManager:dependencyManager];
    }
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
        self.userItem.selectionHandler( self.userItem );
    }
}

#pragma mark - Public Methods

- (void)setLoading:(BOOL)loading forItem:(VActionItem *)item
{
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(VActionItemTableViewCell *cell, NSUInteger index, BOOL *stop)
    {
        if ( [cell.title isEqualToString:item.title] )
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            VActionItemTableViewCell *cell = (VActionItemTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell setLoading:YES animated:YES];
            
            *stop = YES;
        }
    }];
}

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
    [self.view layoutIfNeeded];
    
    //Need to refresh the gradient layer after adjusting the height constraint to properly mask at the proper spot on the table view
    [self refreshGradientLayer];
}

- (void)refreshGradientLayer
{
    // gradient
    [self.gradient removeFromSuperlayer];
    if ( !self.gradient )
    {
        self.gradient = [CAGradientLayer layer];
    }
    self.gradient.frame = self.gradientContainer.bounds;
    self.gradient.colors = @[(id)[UIColor blackColor].CGColor,
                             (id)[UIColor clearColor].CGColor
                             ];
    self.gradient.locations = @[
                                @(1 - (kBlurrGradientHeight / CGRectGetHeight(self.tableView.bounds))),
                                @1.0f,
                                ];
    [self.gradientContainer.layer insertSublayer:self.gradient atIndex:0];
    self.gradientContainer.layer.mask = self.gradient;
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
            itemForCell.detailSelectionHandler( itemForCell );
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
        actionItem.selectionHandler( actionItem );
    }
}

#pragma mark - Private Methods

- (void)setupTitleTextView
{
    if (self.descriptionItem.title == nil)
    {
        return;
    }
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    {
        UIFont *themedFont = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
        if (themedFont != nil)
        {
            attributes[NSFontAttributeName] = themedFont;
        }
        
        UIColor *textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        if (textColor != nil)
        {
            attributes[NSForegroundColorAttributeName] = textColor;
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.descriptionItem.title
                                                                                                attributes:attributes];
    
    self.titleTextView.attributedText = mutableAttributedString;
    self.titleTextView.linkDelegate = self;
}

- (void)viewDidLayoutSubviews
{
    // Turn scrolling on on our text view if necessary
    CGRect rect = [self.titleTextView.attributedText boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.bounds) - self.horizontalSpace.constant * 2, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                  context:nil];
    if (ceilf(CGRectGetHeight(rect)) > CGRectGetMaxY(self.emptySpaceContainer.frame) - self.textViewBottomSpace.constant - self.textViewTopSpace.constant)
    {
        self.titleTextView.scrollEnabled = YES;
    }
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    if (self.descriptionItem.hashTagSelectionHandler)
    {
        self.descriptionItem.hashTagSelectionHandler(value);
    }
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.titleTextView];
    __block BOOL shouldRecognize = YES;
    [self.titleTextView enumerateLinkRangesContainingLocation:location usingBlock:^(NSRange range)
    {
        shouldRecognize = NO;
    }];
    return shouldRecognize;
}

@end
