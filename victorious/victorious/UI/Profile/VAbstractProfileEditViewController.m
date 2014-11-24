//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractProfileEditViewController.h"
#import "VCameraViewController.h"
#import "VUser.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"
#import "VThemeManager.h"
#import "VContentInputAccessoryView.h"
#import "VConstants.h"

@interface VAbstractProfileEditViewController () <VContentInputAccessoryViewDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell *captionCell;
@property (nonatomic, assign) NSInteger numberOfLines;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTaglineTextViewTopToContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTaglineTextViewBottomToContainer;

@end

@implementation VAbstractProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usernameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.taglineTextView.delegate = self;
    
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.clipsToBounds = YES;
    
    self.cameraButton.layer.masksToBounds = YES;
    self.cameraButton.layer.cornerRadius = CGRectGetHeight(self.cameraButton.bounds)/2;
    self.cameraButton.clipsToBounds = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.taglineTextView.inputAccessoryView =
    ({
        VContentInputAccessoryView *inputAccessoryView = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.0f)];
        inputAccessoryView.delegate = self;
        inputAccessoryView.textInputView = self.taglineTextView;
        inputAccessoryView.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
        inputAccessoryView;
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self restoreInsets];
    
    self.usernameTextField.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.locationTextField.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.taglineTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:3 inSection:0]])
    {
        return [self.taglineTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.taglineTextView.bounds), FLT_MAX)].height + fabsf(self.verticalSpaceTaglineTextViewBottomToContainer.constant) + fabsf(self.verticalSpaceTaglineTextViewTopToContainer.constant);
    }
    return [super tableView:tableView
    heightForRowAtIndexPath:indexPath];
}

#pragma mark - Property Accessors

- (void)setProfile:(VUser *)profile
{
    NSAssert([NSThread isMainThread], @"");
    _profile = profile;
 
    self.usernameTextField.text = profile.name;
    self.taglineTextView.text = profile.tagline;
    self.locationTextField.text = profile.location;
    
    self.tagLinePlaceholderLabel.hidden = (profile.tagline.length > 0);
    
    //  Set background image
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    [backgroundImageView setBlurredImageWithURL:[NSURL URLWithString:profile.pictureUrl]
                               placeholderImage:[UIImage imageNamed:@"profileGenericUser"]
                                      tintColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = backgroundImageView;

    
    NSURL  *imageURL    =   [NSURL URLWithString:profile.pictureUrl];
    [self.profileImageView setImageWithURL:imageURL placeholderImage:nil];
}

#pragma mark - Actions

- (IBAction)takePicture:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerLimitedToPhotos];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (finished && capturedMediaURL)
        {
            self.profileImageView.image = previewImage;
            self.updatedProfileImage = capturedMediaURL;
        }
    };
    [navigationController pushViewController:cameraViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)
    {
        [textView resignFirstResponder];
    }

    return YES;
}

#pragma mark - VContentInputAccessoryViewDelegate

- (BOOL)shouldLimitTextEntryForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return YES;
}

- (BOOL)shouldAddHashTagsForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return NO;
}

#pragma mark - Private Methods

- (void)restoreInsets
{
    UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetHeight(self.navigationController.navigationBar.bounds) +
                                           CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), 0, 0, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

@end
