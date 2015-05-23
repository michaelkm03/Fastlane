//
//  VTextPostViewController.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VTextPostViewModel, VTextPostTextView;

/**
 The view controller that renders text posts, both when displaying static posts
 as well as when displaying editable (@see VEditableTextPostViewController).
 */
@interface VTextPostViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Sets the text to display.  This is an overridden setter that also calls any
 required calculation and drawing routines to render the text according to the
 design.
 */
@property (nonatomic, copy) NSString *text;

/**
 Sets the background iamge URL, which will load asynchronously and then
 display using the same `backgroundImage` property setter.
 */
@property (nonatomic, copy) NSURL *imageURL;

/**
 Sets the background color.
 */
@property (nonatomic, strong) UIColor *color;

/**
 An object that encapsulates various configuration properties of how the text post
 is rendered, including text attributes and background frame properties.
 */
@property (nonatomic, strong, readonly) IBOutlet VTextPostViewModel *viewModel;

/**
 Allows text to be selectable (though still not editable).
 */
@property (nonatomic, assign) BOOL isTextSelectable;

/**
 The custom text view used to render the text post.  This property is provided
 primary for access to subclasses (i.e. protected) and should not be messed
 with by calling code unless you know what you're doing.
 */
@property (nonatomic, readonly) VTextPostTextView *textView;

/**
 The image background view, exposed here for subclasses.  Don't mess with this
 unless you know exactly what you're doing.
 */
@property (nonatomic, weak, readonly) IBOutlet UIImageView *backgroundImageView;

/**
 Sets the background image, which will display and size accodingly.
 */
- (void)setBackgroundImage:(UIImage *)backgroundImage;

@end
