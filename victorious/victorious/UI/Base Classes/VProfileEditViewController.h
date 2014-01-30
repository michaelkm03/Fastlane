//
//  VProfileEditViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;

@interface VProfileEditViewController : UITableViewController   <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong)   VUser*          profile;
@end
