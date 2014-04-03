//
//  VCreatePollViewController.h
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCreateSequenceDelegate.h"

#import "VCreateContentViewController.h"

@interface VCreatePollViewController : VCreateContentViewController

@property (weak, nonatomic) IBOutlet UIImageView *rightPreviewImageView;

@property (weak, nonatomic) IBOutlet UIButton *rightRemoveButton;

@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property (weak, nonatomic) IBOutlet UITextField *leftAnswerTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightAnswerTextField;

@property (weak, nonatomic) IBOutlet UIView* questionViews;

+ (instancetype)newCreatePollViewControllerForType:(VImagePickerViewControllerType)type
                                      withDelegate:(id<VCreateSequenceDelegate>)delegate;

@end
