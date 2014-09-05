//
//  VTextViewWithCorrectIntrinsicContentSize.h
//  victorious
//
//  Created by Josh Hinman on 9/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A sbuclass of UITextView which correctly reports its
 intrinsicContentSize in iOS 7.0.x.
 
 Once we drop support for 7.0.x we can get rid of this class.
 (UITextView behaves properly in iOS 7.1)
 */
@interface VTextViewWithCorrectIntrinsicContentSize : UITextView

@end
