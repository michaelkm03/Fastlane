//
//  VStreamContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamContainerViewController.h"

#import "UIViewController+VSideMenuViewController.h"

#import "VStreamTableViewController+ContentCreation.h"
#import "VHomeStreamViewController.h"
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"

#import "VThemeManager.h"

#import "VConstants.h"

@interface VStreamContainerViewController ()

@property (nonatomic, strong) VStreamTableViewController* streamTable;

@property (nonatomic, weak) IBOutlet UIView* streamContainerView;
@property (nonatomic, weak) IBOutlet UIView* headerView;
@property (nonatomic, weak) IBOutlet UISegmentedControl* filterControls;
@property (nonatomic, weak) IBOutlet UILabel* headerLabel;
@property (nonatomic, weak) IBOutlet UIButton* menuButton;
@property (nonatomic, weak) IBOutlet UIButton* createButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* headerYConstraint;

@end

@implementation VStreamContainerViewController

+ (instancetype)containerForStreamTable:(VStreamTableViewController*)streamTable
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamContainerViewController* container = (VStreamContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamContainerID];
    container.streamTable = streamTable;
    streamTable.delegate = container;
    
    return container;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.streamContainerView addSubview:self.streamTable.view];
    [self addChildViewController:self.streamTable];
    [self.streamTable didMoveToParentViewController:self];

    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.headerView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.menuButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIImage* image = [self.menuButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.menuButton setImage:image forState:UIControlStateNormal];
    
    self.createButton.hidden = [self.streamTable isKindOfClass:[VOwnerStreamViewController class]];
    self.createButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    image = [self.createButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.createButton setImage:image forState:UIControlStateNormal];
    [self.createButton addTarget:self.streamTable action:@selector(createButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    
    self.headerLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.headerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.headerLabel.text = self.streamTable.navigationItem.title;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}
#pragma mark - Header
- (void)hideHeader
{
    if (!CGRectContainsRect(self.view.frame, self.headerView.frame))
        return;
    
    self.headerYConstraint.constant = -self.headerView.frame.size.height;
    [self.view layoutIfNeeded];
}

- (void)showHeader
{
    if (CGRectContainsRect(self.view.frame, self.headerView.frame))
        return;
    
    self.headerYConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark UITableViewDelegate

- (void)streamWillDisappear
{
    [UIView animateWithDuration:.2f
                     animations:^{
        [self hideHeader];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if (translation.y < 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self hideHeader];
         }];
    }
    else if (translation.y > 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self showHeader];
         }];
    }
}

@end
