//
//  VTemplatePackageManager.m
//  victorious
//
//  Created by Josh Hinman on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VTemplateImage.h"
#import "VTemplateImageMacro.h"
#import "VTemplateImageSet.h"
#import "VTemplatePackageManager.h"

@interface VTemplatePackageManager ()

@property (nonatomic, strong, readwrite) NSSet *dataURLs;

@end

@implementation VTemplatePackageManager

- (instancetype)initWithTemplateJSON:(NSDictionary *)templateJSON
{
    self = [super init];
    if ( self != nil )
    {
        _templateJSON = [templateJSON copy];
    }
    return self;
}

- (NSSet *)referencedURLs
{
    if ( _dataURLs == nil )
    {
        NSMutableSet *urls = [[NSMutableSet alloc] init];
        [self scanForURLsInCollection:self.templateJSON andAddToSet:urls];
        _dataURLs = [urls copy];
    }
    return _dataURLs;
}

- (void)scanForURLsInCollection:(id)collection andAddToSet:(NSMutableSet *)set
{
    if ( [collection isKindOfClass:[NSDictionary class]] )
    {
        NSDictionary *dict = (NSDictionary *)collection;
        
        if ( [VTemplateImage isImageJSON:dict] )
        {
            VTemplateImage *image = [[VTemplateImage alloc] initWithJSON:dict];
            if ( image.imageURL != nil && [[self validSchemes] containsObject:[image.imageURL.scheme lowercaseString]] )
            {
                [set addObject:image.imageURL];
            }
        }
        else if ( [VTemplateImageSet isImageSetJSON:dict] )
        {
            VTemplateImageSet *imageSet = [[VTemplateImageSet alloc] initWithJSON:dict];
            [set unionSet:[imageSet allImageURLs]];
        }
        else if ( [VTemplateImageMacro isImageMacroJSON:dict] )
        {
            VTemplateImageMacro *imageMacro = [[VTemplateImageMacro alloc] initWithJSON:dict];
            [set unionSet:[imageMacro allImageURLs]];
        }
        else
        {
            for (id key in dict.keyEnumerator)
            {
                [self scanForURLsInCollection:dict[key] andAddToSet:set];
            }
        }
    }
    else if ( [collection isKindOfClass:[NSArray class]] )
    {
        for (id value in collection)
        {
            [self scanForURLsInCollection:value andAddToSet:set];
        }
    }
}

- (NSSet *)validSchemes
{
    static NSSet *validSchemes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        validSchemes = [NSSet setWithObjects:@"http", @"https", nil];
    });
    return validSchemes;
}

@end
