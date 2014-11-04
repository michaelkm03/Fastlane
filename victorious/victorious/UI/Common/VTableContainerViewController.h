//
//  VTableContainerViewController.h
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Height of standard table header
 */
extern const CGFloat VTableContainerViewControllerStandardHeaderHeight;

@interface VTableContainerViewController : UIViewController <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *filterControls;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerYConstraint;

@property (nonatomic, strong) UITableViewController *tableViewController;

@property (nonatomic, weak) IBOutlet UIView *tableContainerView;

- (void)v_hideHeader;
- (void)v_showHeader;
- (CGFloat)hiddenHeaderHeight; //< When the header hides, it will scoot up off-screen by this amount.
- (IBAction)changedFilterControls:(id)sender;

@end
