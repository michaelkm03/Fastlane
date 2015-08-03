//
//  VExperimentSettings.m
//  victorious
//
//  Created by Patrick Lynch on 8/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VExperimentSettings.h"

static NSString * const kActiveExperimentsKey = @"com.getvictorious.experiments.active_experiments";

@implementation VExperimentSettings

@synthesize activeExperiments = _activeExperiments;

- (void)setActiveExperiments:(NSSet *)activeExperiments
{
    _activeExperiments = activeExperiments;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_activeExperiments.allObjects forKey:kActiveExperimentsKey];
    [defaults synchronize];
}

- (NSSet *)activeExperiments
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:kActiveExperimentsKey];
    _activeExperiments = array == nil ? nil : [[NSSet alloc] initWithArray:array];
    return _activeExperiments;
}

- (void)reset
{
    _activeExperiments = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kActiveExperimentsKey];
    [defaults synchronize];
}

- (NSString *)commaSeparatedList
{
    if ( self.activeExperiments != nil && self.activeExperiments.count == 0 )
    {
        // An empty string used in a header indicates to the backend that the user has
        // manually opted out of all experiments
        return @"";
    }
    else if ( self.activeExperiments == nil )
    {
        // A nil value used in a header indicates to the backend that the user does not wish
        // to deviate from the default experiment membership
        return nil;
    }
    
    return [self.activeExperiments.allObjects componentsJoinedByString:@","];
}

@end
