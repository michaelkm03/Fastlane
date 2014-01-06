//
//  VProfileViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileViewController.h"
#import "VMenuViewController.h"
#import "VMenuViewControllerTransition.h"
#import "UIImage+ImageEffects.h"

@interface VProfileViewController ()

@end

@implementation VProfileViewController
{
    NSArray*            _labels;
}

+ (VProfileViewController *)sharedProfileViewController
{
    static  VProfileViewController*   profileViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        profileViewController = (VProfileViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"profile"];
    });
    
    return profileViewController;
}

- (void)viewDidLoad
{
    // FIXME: SET USER LOGGED IN
    self.userIsLoggedInUser = YES;
    
    // FIXME: PRESENT DATA FIELDS
    _labels =   @[@"Name", @"E-Mail", @"Password"];
    self.profileDetails.delegate = self;
    self.profileDetails.dataSource = self;
    
    // FIXME: SET BACKGROUND
    [self.profileDetails layoutIfNeeded];
    UIImage* bg = [UIImage imageNamed:@"avatar.jpg"];
    self.bg.image = bg;
    self.bg.contentMode = UIViewContentModeScaleAspectFill;
    self.bg.image = [self.bg.image
                     applyDarkEffectWithMaskImage:[self maskImageWithHeight:self.profileDetails.contentSize.height]];
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if (!self.userIsLoggedInUser)
    {
        UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonPressed)];
        UIBarButtonItem* userActionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(userActionButtonPressed)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:composeButton, userActionButton, nil];
    }
    else
    {
        
    }
}

- (UIImage*)maskImageWithHeight:(CGFloat)height
{
    CGSize size = CGSizeMake(self.bg.frame.size.width, self.bg.frame.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8,
                                                     0,
                                                     CGColorSpaceCreateDeviceGray(),
                                                     kCGBitmapByteOrderDefault);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    [[UIColor blackColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, size.height - height, size.width, height)] fill];
    
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return testImg;
}


-(void)composeButtonPressed
{
    NSLog(@"Compose Button Clicked");
}

-(void)userActionButtonPressed
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Title"
                                                            delegate:self cancelButtonTitle:@"Cancel Button"
                                              destructiveButtonTitle:@"Destructive Button"
                                                   otherButtonTitles:@"Other Button 1",
                                 @"Other Button 2", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque; [popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(int)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"Destructive Button Clicked");
    } else if (buttonIndex == 1) {
        NSLog(@"Other Button 1 Clicked");
    } else if (buttonIndex == 2) {
        NSLog(@"Other Button 2 Clicked");
    } else if (buttonIndex == 3) {
        NSLog(@"Cancel Button Clicked");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Only 3 parameters for the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    // If we are editing, create an editable cell
    if (YES)
    {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = _labels[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

- (void)profileEditViewControllerDidCancel:(VProfileEditViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)profileEditViewControllerDidSave:(VProfileEditViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[VMenuViewController class]])
    {
        VMenuViewController *menuViewController = segue.destinationViewController;
        menuViewController.transitioningDelegate = (id <UIViewControllerTransitioningDelegate>)[VMenuViewControllerTransitionDelegate new];
        menuViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
}



@end
