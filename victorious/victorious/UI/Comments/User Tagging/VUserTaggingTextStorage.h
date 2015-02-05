//
//  VUserTaggingTextStorage.h
//  victorious
//
//  Created by Josh Hinman on 2/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VUserTaggingTextStorageDelegate <NSTextStorageDelegate>



@end

/**
 An NSTextStorage subclass that supports
 searching and tagging users.
 */
@interface VUserTaggingTextStorage : NSTextStorage

@end
