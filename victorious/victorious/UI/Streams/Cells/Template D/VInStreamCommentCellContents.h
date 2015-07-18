//
//  VInStreamCommentCellContents.h
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VInStreamMediaLink, VComment;

@interface VInStreamCommentCellContents : NSObject

- (instancetype)initWithUsername:(NSString *)username
          usernameTextAttributes:(NSDictionary *)usernameTextAttributes
                     commentText:(NSString *)commentText
           commentTextAttributes:(NSDictionary *)commentTextAttributes
       highlightedTextAttributes:(NSDictionary *)highlightedTextAttributes
                    creationDate:(NSDate *)creationDate
         timestampTextAttributes:(NSDictionary *)timestampTextAttributes
               inStreamMediaLink:(VInStreamMediaLink *)inStreamMediaLink
           profileImageUrlString:(NSString *)profileImageUrlString
                         comment:(VComment *)comment;

+ (NSArray *)inStreamCommentsForComments:(NSArray *)comments andDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDictionary *usernameTextAttributes;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) NSDictionary *commentTextAttributes;
@property (nonatomic, strong) NSDictionary *highlightedTextAttributes;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDictionary *timestampTextAttributes;
@property (nonatomic, strong) VInStreamMediaLink *inStreamMediaLink;
@property (nonatomic, strong) NSString *profileImageUrlString;
@property (nonatomic, strong) VComment *comment;

@end
