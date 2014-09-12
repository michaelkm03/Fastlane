//
//  VSharedCollectionReusableViewMethods.h
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VSharedCollectionReusableViewMethods <NSObject>

+ (NSString *)suggestedReuseIdentifier;
+ (UINib *)nibForCell;

@end
