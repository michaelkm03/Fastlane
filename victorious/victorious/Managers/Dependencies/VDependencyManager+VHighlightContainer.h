//
//  VDependencyManager+VHighlightContainer.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VHighlightContainer.h"

static NSString * const kShowsHighlightedStateKey = @"showsHighlightedState";

@interface VDependencyManager (VHighlightContainer)

- (void)addHighlightViewToHost:(id <VHighlightContainer>)highlightHost;

- (void)setHighlighted:(BOOL)highlighted onHost:(id <VHighlightContainer>)highlightHost;

@end
