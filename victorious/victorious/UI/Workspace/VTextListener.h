//
//  Header.h
//  victorious
//
//  Created by Patrick Lynch on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

@protocol VTextListener <NSObject>

- (void)textDidUpdate:(NSString *)text;

@end