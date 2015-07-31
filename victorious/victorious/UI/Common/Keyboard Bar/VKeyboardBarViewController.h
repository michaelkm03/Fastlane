//
//  VKeyboardBarViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VUserTaggingTextStorageDelegate.h"
#import "VPublishParameters.h"

@class VKeyboardBarViewController;

@protocol VKeyboardBarDelegate <NSObject, VUserTaggingTextStorageDelegate>
@required

- (CGFloat)initialHeightForKeyboardBar:(VKeyboardBarViewController *)keyboardBar;

@optional

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text publishParameters:(VPublishParameters *)publishParameters;
- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar wouldLikeToBeResizedToHeight:(CGFloat)height;
- (void)didCancelKeyboardBar:(VKeyboardBarViewController *)keyboardBar;
- (BOOL)canPerformAuthorizedAction;

@end

@interface VKeyboardBarViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong, readonly) UITextView *textView;
@property (nonatomic, weak)   id<VKeyboardBarDelegate>  delegate;
@property (nonatomic, strong) NSAttributedString       *textViewText;
@property (nonatomic, weak)   IBOutlet UILabel         *promptLabel;
@property (nonatomic)         BOOL                      sendButtonEnabled;
@property (nonatomic, strong) VUserTaggingTextStorage *textStorage;
@property (nonatomic, assign) NSUInteger               characterLimit; ///< Defaults to 0, no limit

/**
 If YES (default), text and media will be cleared automatically after the 
 keyboardBar:didComposeWithText:mediaURL: delegate method is called
 */
@property (nonatomic) BOOL shouldAutoClearOnCompose;

- (IBAction)cameraPressed:(id)sender;
- (void)clearKeyboardBar; ///< Clears all text and media from the keyboard bar
- (void)setHideAccessoryBar:(BOOL)hideAccessoryBar; ///< Hides or shows the input accessory view.
- (void)appendText:(NSString *)text; //< appends text the textview

@end
