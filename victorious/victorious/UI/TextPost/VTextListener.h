//
//  Header.h
//  victorious
//
//  Created by Patrick Lynch on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

/**
 A simple protocol that provides a method where a conforming object and
 list to changes in a text post while it is being created.
 */
@protocol VTextListener <NSObject>

- (void)textDidUpdate:(NSString *)text;

@end
