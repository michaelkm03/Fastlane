//
//  VHashtagSelectionResponder.h
//  victorious
//
//  Created by Patrick Lynch on 4/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A protocol that any UIResponder subclass can implement in order to receive respond to
 events that occur and are passed up along the responder chain.
 */
@protocol VHashtagSelectionResponder <NSObject>

/**
 Called when a user taps a hashtag in some text.
 */
- (void)hashtagSelected:(NSString *)text;

@end
