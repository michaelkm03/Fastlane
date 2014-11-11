//
//  VHashTagTextView.h
//  victorious
//
//  Created by Michael Sena on 11/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "CCHLinkTextView.h"

/**
 * VHsahTagTextView is a convenience that provides hash tag detection and themed defaults. Overrides setAttributedText: to do hashTag detection and adds the "CCHLinkAttributeName" attribute with the hash tag text as the value. Implement the CCHLinkTextViewDelegate to be informed of hash tag taps. Provides Defaults for linkTextAttributes, and linkTextTouchAttributes and minimumPressDuration (removes the longPress effect).
 */
@interface VHashTagTextView : CCHLinkTextView

@end
