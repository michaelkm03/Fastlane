//
//  VSharedCollectionReusableViewMethods.h
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VSharedCollectionReusableViewMethods <NSObject>

/**
 *  A convenience for data sources to have a reuse identifier for a given reusable view.
 *
 *  @return An appropriate reusable view identifier.
 */
+ (NSString *)suggestedReuseIdentifier;

/**
 *  A convenience for data sources to have a nib for a given reusable view.
 *
 *  @return An appropriate nib for a given cell.
 */
+ (UINib *)nibForCell;

@end
