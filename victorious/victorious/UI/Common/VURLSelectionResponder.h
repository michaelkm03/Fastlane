//
//  VURLSelectionResponder.h
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
@protocol VURLSelectionResponder <NSObject>

/**
 Called when a user taps a URL in some text.
 */
- (void)URLSelected:(NSURL *)URL;

@end
