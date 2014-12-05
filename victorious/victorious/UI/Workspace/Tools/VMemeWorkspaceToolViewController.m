//
//  VMemeWorkspaceToolViewController.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMemeWorkspaceToolViewController.h"

static NSString *kMemeFont = @"Impact";

static const CGFloat kPublishMaxMemeFontSize = 120.0f;
static const CGFloat kPublishMinMemeFontSize = 50.0f;

@interface VMemeWorkspaceToolViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *memeTextView;

@end

@implementation VMemeWorkspaceToolViewController

+ (instancetype)memeToolViewController
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    return [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

#pragma mark - UIViewController
#pragma mark Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.memeTextView.attributedText = [[NSAttributedString alloc] initWithString:@"TYPE YO MEME"
                                                                       attributes:[self memeAttributes]];
}

#pragma mark - VCanvasTool

- (BOOL)shouldPersistAfterDeselection
{
    return (self.memeTextView.text.length > 0);
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Internal Methods

- (NSDictionary *)memeAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    return @{
             NSParagraphStyleAttributeName : paragraphStyle,
             NSFontAttributeName : [UIFont fontWithName:kMemeFont size:kPublishMinMemeFontSize],
             NSForegroundColorAttributeName : [UIColor whiteColor],
             NSStrokeColorAttributeName : [UIColor blackColor],
             NSStrokeWidthAttributeName : @(-5.0)
             };
}

@end
