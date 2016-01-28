//
//  VSequenceLiker.h
//  victorious
//
//  Created by Patrick Lynch on 1/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence, VUser;

NS_ASSUME_NONNULL_BEGIN

@interface VSequenceLiker : NSManagedObject

@property (null_unspecified, nonatomic, retain) NSNumber *displayOrder;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) VUser *user;

@end

NS_ASSUME_NONNULL_END
