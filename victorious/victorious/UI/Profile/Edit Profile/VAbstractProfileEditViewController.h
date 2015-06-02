//
//  VProfileEditViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

@class VUser;

@interface VAbstractProfileEditViewController : UITableViewController   <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, VHasManagedDependencies>

@property (nonatomic, strong)   VUser          *profile;

@property (nonatomic, strong)   NSURL          *updatedProfileImage;

@property (nonatomic, weak) IBOutlet UITextField   *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField   *locationTextField;
@property (nonatomic, weak) IBOutlet UITextView    *taglineTextView;

@end
