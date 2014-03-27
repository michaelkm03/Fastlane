//
//  VProfileEditViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;

@interface VAbstractProfileEditViewController : UITableViewController   <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong)   VUser*          profile;

@property (nonatomic, weak) IBOutlet UITextField*   usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField*   locationTextField;
@property (nonatomic, weak) IBOutlet UITextView*    taglineTextView;
@property (nonatomic, weak) IBOutlet UILabel*       tagLinePlaceholderLabel;

@property (nonatomic, weak) IBOutlet UIImageView*    profileImageView;
@property (nonatomic, weak) IBOutlet UIButton*       cameraButton;
@end
