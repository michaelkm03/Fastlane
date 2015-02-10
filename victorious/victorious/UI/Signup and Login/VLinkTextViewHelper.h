//
//  VLinkTextViewHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCHLinkTextView.h"

@interface VLinkTextViewHelper : NSObject

- (void)setupLinkTextView:(CCHLinkTextView *)linkTextView withText:(NSString *)text range:(NSRange)range;

@end
