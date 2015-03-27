//
//  VTextPostBackgroundModel.h
//  victorious
//
//  Created by Patrick Lynch on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTextPostBackgroundModel : NSObject

@property (nonatomic, readonly) NSArray *allFrames;

@property (nonatomic, readonly) NSArray *lines;

@property (nonatomic, readonly) NSUInteger lineCount;

- (NSArray *)framesForLineAtIndex:(NSUInteger)lineIndex;

- (void)setFrames:(NSArray *)frames forLineAtIndex:(NSUInteger)lineIndex;

- (void)addFrame:(CGRect)frame toLineAtIndex:(NSUInteger)lineIndex;

@end