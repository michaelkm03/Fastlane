//
//  VCardDirectoryCollectionViewFlowLayout.m
//  victorious
//
//  Created by Sharif Ahmed on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCardDirectoryCollectionViewFlowLayout.h"

@implementation VCardDirectoryCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *directoryCellAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *attributes = [directoryCellAttributes mutableCopy];
    for ( NSUInteger i = 0; i < directoryCellAttributes.count; i++ )
    {
        UICollectionViewLayoutAttributes *currentAttributes = directoryCellAttributes[i];
        if ( [self isMarqueeCellAtIndexPath:currentAttributes.indexPath] )
        {
            //Don't update marquee cell
            continue;
        }
        
        NSIndexPath *indexPath = currentAttributes.indexPath;
        if ( indexPath.row % 2 == 0 && i + 1 < directoryCellAttributes.count )
        {
            //Perform update on every pair of directory cells, updating either frame as appropriate
            UICollectionViewLayoutAttributes *compareAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
            CGFloat compareY = CGRectGetMinY(compareAttributes.frame);
            CGFloat currentY = CGRectGetMinY(currentAttributes.frame);
            if ( compareY == currentY )
            {
                //Both cells have the same origin, there's no need to update either
                continue;
            }
            
            if ( compareY < currentY )
            {
                //compareY has the proper origin value, update currentAttributes
                CGRect updatedFrame = currentAttributes.frame;
                updatedFrame.origin.y = compareY;
                currentAttributes.frame = updatedFrame;
                attributes[i] = currentAttributes;
            }
            else
            {
                //currentY has the proper origin value, update compareAttributes
                CGRect updatedFrame = compareAttributes.frame;
                updatedFrame.origin.y = currentY;
                compareAttributes.frame = updatedFrame;
                attributes[i+1] = compareAttributes;
            }
        }
    }
    return [NSArray arrayWithArray:attributes];
}

@end
