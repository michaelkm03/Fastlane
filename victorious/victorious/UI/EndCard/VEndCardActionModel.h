//
//  VEndCardActionModel.h
//  victorious
//
//  Created by Patrick Lynch on 2/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Some common, expected strings used to identify which cell was tapped
 in the collection view delegate.
 */
extern NSString * const VEndCardActionIdentifierRepost;
extern NSString * const VEndCardActionIdentifierGIF;
extern NSString * const VEndCardActionIdentifierShare;
extern NSString * const VEndCardActionIdentifierMeme;

/**
 Model object used to configure `VEndCardActionCell`s.
 */
@interface VEndCardActionModel : NSObject

/**
 An identifier that is not displayed to the user and used to
 identify which cell was selected in the collection view delegate.
 */
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) NSString *textLabelDefault;
@property (nonatomic, strong) NSString *textLabelSuccess;
@property (nonatomic, strong) NSString *iconImageNameDefault;
@property (nonatomic, strong) NSString *iconImageNameSuccess;

@end
