//
//  VCommentCellUtilitiesDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VComment;

@protocol VCommentCellUtilitiesDelegate <NSObject>

- (void)commentRemoved:(VComment *)comment;
- (void)editComment:(VComment *)comment;
- (void)didSelectActionRequiringLogin;

@end