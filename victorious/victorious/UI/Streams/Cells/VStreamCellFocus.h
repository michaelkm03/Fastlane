//
//  VStreamCellFocus.h
//  victorious
//
//  Created by Michael Sena on 5/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VStreamCellFocus <NSObject>

/**
 *  Informs the reciever that is thas the focus of the user and should do any 
 *  appropriate user facing actions.
 */
- (void)setHasFocus:(BOOL)hasFocus;

/**
 *  Returns the bounding rect for the content relative to the receiving container.
 */
- (CGRect)contentArea;

@end
