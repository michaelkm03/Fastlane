//
//  VPseudoProduct.h
//  victorious
//
//  Created by Josh Hinman on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPseudoProduct : VProduct

/**
 Creates a VPseudoProduct instance with the given property values
 */
- (instancetype)initWithProductIdentifier:(NSString *)productIdentifier price:(nullable NSString *)price localizedDescription:(nullable NSString *)localizedDescription localizedTitle:(nullable NSString *)localizedTitle;

@end

NS_ASSUME_NONNULL_END
