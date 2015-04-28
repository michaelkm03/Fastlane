//
//  VLinkSelectionResponder.h
//  victorious
//
//  Created by Patrick Lynch on 4/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A protocol that view controllers can implement in order to receive this event
 from pass up the responder chain.
 */
@protocol VLinkSelectionResponder <NSObject>

/**
 Called when a user taps the displayed callout text.
 */
- (void)linkWithTextSelected:(NSString *)text;

@end