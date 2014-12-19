//
//  VCapitalizingTextStorage.h
//  victorious
//
//  Created by Michael Sena on 12/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  VCapitalizingTextStorage will manage storing text for a UITextView's LayoutManager. It capitalizes all text entered into the text view while also maintaining a copy of the originally entered text.
 */
@interface VCapitalizingTextStorage : NSTextStorage

@property (nonatomic, assign) BOOL shouldForceUppercase; ///< Set to YES for the text storage to only return upper case text. NO returns the original text entered.

@property (nonatomic, strong, readonly) NSMutableAttributedString *enteredText; ///< The original text entered regardless of shouldForceUppercase.

@end
