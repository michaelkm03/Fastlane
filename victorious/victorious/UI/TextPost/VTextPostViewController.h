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
@property (nonatomic, strong) NSString *text;

/**
 Sets the background color of the text post.
 design.
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
 Updates the text to be displayed and renders is accoding to the rules of the
 design and using the provided attribtues.
 
 @param textAttributes A dictionary of attributes for normal text, i.e. text that
 not callout text.
 @param calloutAttribtues A dictionary of attribetus for callout text, which
 will represent things like hashtags and user tags.
 */
- (void)updateTextView:(VTextPostTextView *)textPostTextView
              withText:(NSString *)text
        textAttributes:(NSDictionary *)textAttributes
     calloutAttributes:(NSDictionary *)calloutAttributes;

@end
