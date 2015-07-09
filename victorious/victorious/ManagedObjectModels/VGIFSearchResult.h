//
//  VGIFSearchResult.h
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface VGIFSearchResult : NSManagedObject

@property (nonatomic, strong) NSString *gifUrl;
@property (nonatomic, strong) NSNumber *gifSize;
@property (nonatomic, strong) NSString *mp4Url;
@property (nonatomic, strong) NSNumber *mp4Size;
@property (nonatomic, strong) NSNumber *frames;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *thumbnailStillUrl;

NS_ASSUME_NONNULL_END

@end
