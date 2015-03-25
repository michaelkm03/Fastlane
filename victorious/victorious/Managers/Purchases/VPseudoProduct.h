//
//  VPseudoProduct.h
//  victorious
//
//  Created by Josh Hinman on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VProduct.h"

@interface VPseudoProduct : VProduct

/**
 Creates a VPseudoProduct instance with the given property values
 */
- (instancetype)initWithProductIdentifier:(NSString *)productIdentifier price:(NSString *)price localizedDescription:(NSString *)localizedDescription localizedTitle:(NSString *)localizedTitle;

@end
