//
//  VProfileEditViewController.h
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VProfileEditViewController;

@protocol VProfileEditViewControllerDelegate <NSObject>

- (void)profileEditViewControllerDidCancel:(VProfileEditViewController *)controller;
- (void)profileEditViewControllerDidSave:(VProfileEditViewController *)controller;

@end

@interface VProfileEditViewController : UIViewController

@property (nonatomic, weak) id <VProfileEditViewControllerDelegate> delegate;

@property (nonatomic, readwrite) IBOutlet UIImageView* bg;
@property (nonatomic, readwrite) IBOutlet UITableView* editProfileDetails;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
