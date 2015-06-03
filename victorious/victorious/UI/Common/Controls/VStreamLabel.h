//
//  VStreamLabel.h
//  victorious
//
//  Created by Michael Sena on 5/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The state of the stream label. Transitions in to highlighted while a touch event is
 *  being recognized on this stream label.
 */
typedef NS_ENUM(NSInteger, VStreamLabelState)
{
    VStreamLabelStateDefault,
    VStreamLabelStateHighlighted,
};

@class VStreamLabel;

/**
 *  VStreamLabelDelegate informs a delegate about events from a stream label.
 */
@protocol VStreamLabelDelegate <NSObject>

/**
 *  Informs the delegate of label selection.
 */
- (void)selectedStreamLabel:(VStreamLabel *)streamLabel;

@end

/**
 *  VSTreamLabel wraps a UILabel and provides selection and gesture state management. 
 *  The stream label gesture will recognize simultaneously with any other gestrues and 
 *  cancel after a minimum amount of movement has occured. This makes it suitable for 
 *  use inside of UIScrollView.
 */
@interface VStreamLabel : UIView

/**
 *  The current state of the stream label.
 */
@property (nonatomic, readonly) VStreamLabelState state;

/**
 * Use this for the stream label to shrink/enlarge it's pointInside: rect.
 */
@property (nonatomic, assign) UIEdgeInsets hitInsets;

/**
 *  Use this for debug purposes to show the extra padding area that will be hit-tested. 
 *  Defaults to NO.
 */
@property (nonatomic, assign) BOOL showHitTestArea;

/**
 *  Delegate for the stream label.
 */
@property (nonatomic, weak) id <VStreamLabelDelegate> delegate;

/**
 *  When the stream label enters the particular state the internal label will be 
 *  updated with the passed in text.
 */
- (void)setAttributedText:(NSAttributedString *)attributedText
      forStreamLabelState:(VStreamLabelState)labelState;

@end

/**
 *  Methods in this category merely forward to their respective counterparts on the wrapped
 *  UILabel.
 *  NOTE for future maintainers: if you want to expose the internal UILabel, consider
 *  merely exposing the appropriate property/method via this category.
 */
@interface VStreamLabel (UILabelForwarding)

/**
 *  Forwards to the internal label.
 */
@property (nonatomic, assign) NSTextAlignment textAlignment;

/**
 *  Forwards to the internal label.
 */
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

/**
 *  Forwards the horizontal layout priority by calling setContentCompressionResistancePriority:forAxis: 
 *  with the given layout priority and UILayoutConstraintAxisHorizontal for axis.
 */
- (void)setHorizontalLayoutPriority:(UILayoutPriority)horizontalLayoutPriority;

@end
