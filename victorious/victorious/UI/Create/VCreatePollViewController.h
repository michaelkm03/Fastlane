//
//  VCreatePollViewController.h
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCreateSequenceDelegate.h"

@interface VCreatePollViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *rightPreviewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@property (weak, nonatomic) IBOutlet UIButton *removeMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *rightRemoveButton;
@property (weak, nonatomic) IBOutlet UIButton *searchImageButton;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property (weak, nonatomic) IBOutlet UITextField *leftAnswerTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightAnswerTextField;

@property (weak, nonatomic) IBOutlet UIView* questionViews;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;

@property (weak, nonatomic) IBOutlet UIView *addMediaView;

@property (weak, nonatomic) id<VCreateSequenceDelegate> delegate;

+ (instancetype)newCreatePollViewControllerWithDelegate:(id<VCreateSequenceDelegate>)delegate;

@end
