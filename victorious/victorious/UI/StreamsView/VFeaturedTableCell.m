//
//  VFeaturedTableCell.m
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFeaturedTableCell.h"

#import "VSequence+RestKit.h"
#import "VConstants.h"

#import "VStreamViewCell.h"

@implementation VFeaturedTableCell

- (NSFetchRequest*)fetchRequest
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VSequence entityName]];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"releasedAt" ascending:YES];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"category == %@", kFeaturedCategory]];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:5];
    
    return fetchRequest;
}

- (UIView*) viewForFetchedObject:(id)object
{
    VSequence* sequence = [object isKindOfClass:[VSequence class]] ? object : nil;
    
    VStreamViewCell *newView = [[[NSBundle mainBundle] loadNibNamed:kStreamYoutubeCellIdentifier owner:self options:nil] firstObject];
    newView.sequence = sequence;
    
    return newView;
}

@end
