//
//  VContentPollQuestionCell.h
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VContentPollQuestionCell : VBaseCollectionViewCell

/**
 *  Computes the needed size of the cell based on appropriate parameters.
 *
 *  @param quesiton  The quesiton this cell represents.
 *  @param attributes The attributes to use in sizing the text.
 *  @param maxSize   The maximum size that will be provided to this cell.
 *
 *  @return An appropriate size for the parameters.
 */
+ (CGSize)actualSizeWithQuestion:(NSString *)question
                      attributes:(NSDictionary *)attributes
                     maximumSize:(CGSize)maxSize;

/**
 *  An attributed string of the question this question cell represents.
 */
@property (nonatomic, copy) NSAttributedString *question;

@end
