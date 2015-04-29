//
//  VCommandHandler.h
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCommandHandler : UIResponder

/**
 *  Designated initializer for VCommandHandlers. 
 *
 *  @param nextResponder Responder chain events that this command doesn't care about will be forwarded to this responder. Weakly held.
 */
- (instancetype)initWithNextResponder:(UIResponder *)nextResponder NS_DESIGNATED_INITIALIZER;

@end
