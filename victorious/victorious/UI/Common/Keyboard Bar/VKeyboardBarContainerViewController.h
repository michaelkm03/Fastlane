//
//  VKeyboardBarContainerViewController.h
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#include "VKeyboardBarViewController.h"

@interface VKeyboardBarContainerViewController : UIViewController <VKeyboardBarDelegate>

@property (weak, nonatomic) VKeyboardBarViewController *keyboardBarViewController;
@property (strong, nonatomic) IBOutlet UIView *topConstraintView;
@property (strong, nonatomic) UITableViewController *conversationTableViewController;

@end
