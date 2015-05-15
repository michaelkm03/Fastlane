//
//  VDependencyManager+VDefaultTemplate.m
//  victorious
//
//  Created by Josh Hinman on 4/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VDefaultTemplate.h"

static NSString * const kDefaultTemplateFilename = @"defaultTemplate";
static NSString * const kJSON = @"json";

@implementation VDependencyManager (VDefaultTemplate)

+ (VDependencyManager *)dependencyManagerWithDefaultValuesForColorsAndFonts
{
    NSURL *jsonFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:kDefaultTemplateFilename withExtension:kJSON];
    if ( jsonFileURL == nil )
    {
        return nil;
    }

    NSData *defaultTemplateData = [NSData dataWithContentsOfURL:jsonFileURL];
    if (defaultTemplateData == nil)
    {
        return nil;
    }
    
    NSDictionary *defaultConfiguration = [NSJSONSerialization JSONObjectWithData:defaultTemplateData options:kNilOptions error:nil];
    if ( ![defaultConfiguration isKindOfClass:[NSDictionary class]] )
    {
        return nil;
    }
    
    return [[VDependencyManager alloc] initWithParentManager:nil
                                               configuration:defaultConfiguration
                           dictionaryOfClassesByTemplateName:nil];
}

@end
