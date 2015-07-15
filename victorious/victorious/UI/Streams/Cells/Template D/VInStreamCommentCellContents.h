//
//  VInStreamCommentCellContents.h
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VInStreamMediaLink;

@interface VInStreamCommentCellContents : NSObject

- (instancetype)initWithUsername:(NSString *)username
          usernameTextAttributes:(NSDictionary *)usernameTextAttributes
                         comment:(NSString *)comment
           commentTextAttributes:(NSDictionary *)commentTextAttributes
       highlightedTextAttributes:(NSDictionary *)highlightedTextAttributes
                    creationDate:(NSDate *)creationDate
         timestampTextAttributes:(NSDictionary *)timestampTextAttributes
               inStreamMediaLink:(VInStreamMediaLink *)inStreamMediaLink
           profileImageUrlString:(NSString *)profileImageUrlString
                       commentId:(NSNumber *)commentId;

+ (NSArray *)inStreamCommentsForComments:(NSArray *)comments andDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDictionary *usernameTextAttributes;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDictionary *commentTextAttributes;
@property (nonatomic, strong) NSDictionary *highlightedTextAttributes;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDictionary *timestampTextAttributes;
@property (nonatomic, strong) VInStreamMediaLink *inStreamMediaLink;
@property (nonatomic, strong) NSString *profileImageUrlString;
@property (nonatomic, strong) NSNumber *commentId;

@end
