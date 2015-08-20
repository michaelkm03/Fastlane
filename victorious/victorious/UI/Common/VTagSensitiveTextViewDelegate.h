//
//  VTagSensitiveTextViewDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VTagSensitiveTextView, VTag;

NS_ASSUME_NONNULL_BEGIN

@protocol VTagSensitiveTextViewDelegate <NSObject>

- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag;

@end

NS_ASSUME_NONNULL_END
