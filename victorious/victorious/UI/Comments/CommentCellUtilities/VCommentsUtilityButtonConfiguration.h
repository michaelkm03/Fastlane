//
//  VCommentsUtilityButtonConfiguration.h
//  victorious
//
//  Created by Patrick Lynch on 12/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

typedef NS_ENUM( NSUInteger, VCommentCellUtilityType )
{
    VCommentCellUtilityTypeEdit,
    VCommentCellUtilityTypeDelete,
    VCommentCellUtilityTypeFlag
};

@interface VUtilityButtonConfig : NSObject

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) VCommentCellUtilityType type;

@end

/**
 An object that creates several configurations for utility button cells
 to be displayed in tableview or collection view cells that use VSwipeViewController.
 This is done for convenience as well as to share UIImage instances between buttons
 instead of using memory and performance to instantiate a new one for
 each button on each cell.
 */
@interface VCommentsUtilityButtonConfiguration : NSObject

+ (VCommentsUtilityButtonConfiguration *)sharedInstance;

@property (nonatomic, strong) VUtilityButtonConfig *editButtonConfig;
@property (nonatomic, strong) VUtilityButtonConfig *deleteButtonConfig;
@property (nonatomic, strong) VUtilityButtonConfig *flagButtonConfig;

@end