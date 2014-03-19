//
//  VKeyboardBarContainerViewController.h
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VKeyboardBarViewController;

@interface VKeyboardBarContainerViewController : UIViewController

@property (weak, nonatomic) VKeyboardBarViewController *keyboardBarViewController;
@property (strong, nonatomic) IBOutlet UIView* topConstraintView;
@property (strong, nonatomic) UITableViewController *conversationTableViewController;
@property (nonatomic) BOOL showKeyboard;

@end
