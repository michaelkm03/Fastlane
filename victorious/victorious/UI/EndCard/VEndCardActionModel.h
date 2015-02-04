//
//  VEndCardActionModel.h
//  victorious
//
//  Created by Patrick Lynch on 2/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VEndCardActionIdentifierRepost;
extern NSString * const VEndCardActionIdentifierGIF;
extern NSString * const VEndCardActionIdentifierShare;
extern NSString * const VEndCardActionIdentifierMeme;

@interface VEndCardActionModel : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *textLabel;
@property (nonatomic, strong) NSString *textLabelSuccess;
@property (nonatomic, strong) NSString *iconImageName;
@property (nonatomic, strong) NSString *successImageName;

@end
