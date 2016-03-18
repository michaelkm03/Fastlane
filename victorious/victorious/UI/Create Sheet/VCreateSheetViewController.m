//
//  VCreateSheetViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreateSheetViewController.h"
#import "VCreateSheetCollectionViewCell.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VNavigationMenuItem.h"
#import "VCreateSheetTransitionDelegate.h"
#import "VDependencyManager+VStatusBarStyle.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "victorious-Swift.h"

static NSString * const kStoryboardName = @"CreateSheet";
static NSString * const kDismissButtonTitle = @"title.button1";

static const CGFloat kLineSpacing = 40.0f;

@interface VCreateSheetViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (strong, nonatomic) VCreateSheetTransitionDelegate *transitionDelegate;
@property (strong, nonatomic) NSArray *menuItems;

@end

@implementation VCreateSheetViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:nil];
    VCreateSheetViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setModalPresentationStyle:UIModalPresentationCustom];
        _transitionDelegate = [[VCreateSheetTransitionDelegate alloc] init];
        [self setTransitioningDelegate:_transitionDelegate];
    }
    return self;
}

- (void)dealloc
{
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set delegate and data source
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // Make cells respond immediately to touch
    self.collectionView.delaysContentTouches = NO;
    
    // So cells don't get cut off while animating
    self.collectionView.clipsToBounds = NO;
    
    // Setup dismiss button
    [self.dismissButton setTitle:[self.dependencyManager stringForKey:kDismissButtonTitle] forState:UIControlStateNormal];
    [self.dismissButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey]];
    [self.dismissButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey] forState:UIControlStateNormal];
    [self.dismissButton setBackgroundColor:[self.dependencyManager colorForKey:VDependencyManagerAccentColorKey]];
    
    // Top line for dismiss button
    UIView *line = [UIView new];
    [line setBackgroundColor:[UIColor blackColor]];
    [line setAlpha:0.25f];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dismissButton addSubview:line];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[line(1)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(line)];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[line]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(line)];
    [self.dismissButton addConstraints:verticalConstraints];
    [self.dismissButton addConstraints:horizontalConstraints];
    
    // Set line height and item size for flow layout
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [layout setMinimumLineSpacing:kLineSpacing];
    
    // Collection view background
    UIView *collectionViewBackground = [UIView new];
    collectionViewBackground.backgroundColor = [UIColor clearColor];
    [self.collectionView setBackgroundView:collectionViewBackground];
    [self.collectionView.backgroundView setUserInteractionEnabled:YES];
    
    // Tap gesture for dismissal
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackground:)];
    [self.collectionView.backgroundView addGestureRecognizer:tapGesture];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIColor *navigationBarTextColor = [[self.dependencyManager dependencyManagerForNavigationBar] colorForKey:VDependencyManagerMainTextColorKey];
    return [StatusBarUtilities statusBarStyleWithColor:navigationBarTextColor];
}

#pragma mark - Properties

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    // Setup menu items
    self.menuItems = [dependencyManager menuItems];
    [self.transitionDelegate setDependencyManager:dependencyManager];
}

#pragma mark - Actions

- (IBAction)pressedDismiss:(id)sender
{
    if (self.completionHandler != nil)
    {
        self.completionHandler(self, VCreationTypeUnknown);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tappedBackground:(UITapGestureRecognizer *)tap
{
    if (self.completionHandler != nil)
    {
        self.completionHandler(self, VCreationTypeUnknown);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNavigationMenuItem *menuItem = self.menuItems[indexPath.row];
    
    VCreateSheetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"createSheetCell" forIndexPath:indexPath];
    cell.itemLabel.text = menuItem.title;
    cell.itemLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    cell.itemLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    [cell.iconImageView setImage:[menuItem.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    cell.iconImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    cell.accessibilityIdentifier = menuItem.identifier;
        
    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNavigationMenuItem *menuItem = self.menuItems[indexPath.row];
    
    if (self.completionHandler != nil)
    {
        self.completionHandler(self, [VCreationTypeHelper creationTypeForIdentifier:menuItem.identifier]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNavigationMenuItem *menuItem = self.menuItems[indexPath.row];
    return CGSizeMake(CGRectGetWidth(self.view.bounds) - 80, [self heightForMenuItemTitle:menuItem.title]);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger numberOfCells = [self.menuItems count];
    
    CGFloat totalCellHeight = 0;
    for (VNavigationMenuItem *item in self.menuItems)
    {
        totalCellHeight += [self heightForMenuItemTitle:item.title];
    }
    
    CGFloat contentHeight = totalCellHeight + (numberOfCells - 1) * kLineSpacing;
    
    if (contentHeight >= CGRectGetHeight(collectionView.frame))
    {
        // Add some padding if collection view contents are larger than screen bounds
        return UIEdgeInsetsMake(40, 0, 20, 0);
    }
    
    // Center content in middle of collection view
    CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    NSInteger verticalInset = (CGRectGetHeight(collectionView.bounds) - contentHeight - statusBarHeight) / 2;
    return UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0);
}

#pragma mark - Helpers

- (CGFloat)heightForMenuItemTitle:(NSString *)text
{
    UIFont *font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    CGRect minimumFrame = [text boundingRectWithSize:CGSizeMake(CGRectGetHeight(self.view.bounds), CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{ NSFontAttributeName : font }
                                             context:nil];
    return VCEIL(CGRectGetHeight(minimumFrame));
}

@end
