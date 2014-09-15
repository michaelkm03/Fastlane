//
//  VNewContentViewController.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VContentViewViewModel.h"

@interface VNewContentViewController : UIViewController

+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel;

@property (nonatomic, strong, readonly) VContentViewViewModel *viewModel;

@end
