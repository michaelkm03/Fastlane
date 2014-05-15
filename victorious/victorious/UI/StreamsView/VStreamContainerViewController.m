//
//  VStreamContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamContainerViewController.h"

#import "UIViewController+VSideMenuViewController.h"

#import "VHomeStreamViewController.h"
#import "VOwnerStreamViewController.h"
#import "VCommunityStreamViewController.h"

#import "VConstants.h"

@interface VStreamContainerViewController ()

@property (nonatomic, strong) VStreamTableViewController* streamTable;
@property (nonatomic, weak) IBOutlet UIView* streamContainerView;
@property (nonatomic, weak) IBOutlet UIView* headerView;

@end

@implementation VStreamContainerViewController

+ (instancetype)containerForStreamTable:(VStreamTableViewController*)streamTable
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamContainerViewController* container = (VStreamContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamContainerID];
    container.streamTable = streamTable;
    
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
    // Do any additional setup after loading the view.
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

@end
