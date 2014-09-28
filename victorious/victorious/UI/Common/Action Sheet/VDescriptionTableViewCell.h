//
//  VDescriptionTableViewCell.h
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDescriptionTableViewCell : UITableViewCell

+ (CGFloat)desiredHeightWithTableViewWidth:(CGFloat)width
                                      text:(NSString *)text;

@property (nonatomic, copy) NSString *descriptionText;

@property (nonatomic, copy) void (^hashTagSelectionBlock)(NSString *hashTag);

@end
