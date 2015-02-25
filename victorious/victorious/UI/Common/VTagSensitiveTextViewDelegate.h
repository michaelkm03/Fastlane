//
//  VTagSensitiveTextViewDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VTagSensitiveTextView, VTag;

@protocol VTagSensitiveTextViewDelegate <NSObject>

- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag;

@end
