//
//  VTemplateDecorator.m
//  victorious
//
//  Created by Patrick Lynch on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTemplateDecorator.h"

static NSString * const kJSONType = @"json";

@interface VTemplateDecorator()

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSDictionary *originalTemplate;
@property (nonatomic, strong, readwrite) NSMutableDictionary *workingTemplate;

@end


@implementation VTemplateDecorator

- (instancetype)initWithTemplateDictionary:(NSDictionary *)templateDictionary
{
    self = [super init];
    if (self)
    {
        _originalTemplate = [templateDictionary copy];
        _workingTemplate = [NSMutableDictionary dictionaryWithDictionary:_originalTemplate];
    }
    return self;
}

- (NSNumberFormatter *)numberFormatter
{
    if ( _numberFormatter == nil )
    {
        _numberFormatter = [[NSNumberFormatter alloc] init];
    }
    return _numberFormatter;
}

- (NSDictionary *)decoratedTemplate
{
    return [NSDictionary dictionaryWithDictionary:self.workingTemplate];
}

- (NSDictionary *)dictionaryFromJSONFile:(NSString *)filename
{
    NSString *pathInBundle = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:kJSONType];
    NSError *error = nil;
    
    NSAssert( pathInBundle != nil, @"Cannot find path in bundle for filename \"%@\". \
             Make sure the file is added to the project.", filename );
    
    NSData *data = [NSData dataWithContentsOfFile:pathInBundle options:kNilOptions error:&error];
    if ( data == nil )
    {
        return nil;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( dictionary == nil )
    {
        return nil;
    }
    
    return dictionary;
}

- (BOOL)concatonateTemplateWithFilename:(NSString *)filename
{
    NSDictionary *templateAddition = [self dictionaryFromJSONFile:filename];
    
    if ( templateAddition != nil )
    {
        return NO;
    }
    
    for ( NSString *key in templateAddition )
    {
        self.workingTemplate[ key ] = templateAddition[ key ];
    }
    
    return YES;
}

- (BOOL)setComponentForKeyPath:(NSString *)keyPath withComponentInFileNamed:(NSString *)filename
{
    NSDictionary *component = [self dictionaryFromJSONFile:filename];
    
    NSMutableArray *keyPathKeys = [[NSMutableArray alloc] initWithArray:[keyPath componentsSeparatedByString:@"/"]];
    BOOL didSetComponent = NO;
    self.workingTemplate = [self collectionFromCollection:self.workingTemplate
                                       bySettingComponent:component
                                           forKeyPathKeys:keyPathKeys
                                                   didSet:&didSetComponent];
    
    return YES;
}

- (id)collectionFromCollection:(id)source
            bySettingComponent:(NSDictionary *)component
                forKeyPathKeys:(NSMutableArray *)keyPathKeys
                        didSet:(BOOL *)didSetComponent
{
    NSString *currentKey = keyPathKeys.firstObject;
    [keyPathKeys removeObjectAtIndex:0];
    
    if ( [source isKindOfClass:[NSArray class]] && [self.numberFormatter numberFromString:currentKey] != nil )
    {
        NSInteger index = [self.numberFormatter numberFromString:currentKey].integerValue;
        NSMutableArray *sourceArray = (NSMutableArray *)source;
        NSMutableArray *destination = [[NSMutableArray alloc] initWithCapacity:sourceArray.count];
        for ( NSInteger i = 0; i < (NSInteger)sourceArray.count; i++ )
        {
            if ( i == index && !(*didSetComponent) )
            {
                if ( keyPathKeys.count == 0 )
                {
                    destination[i] = component;
                    *didSetComponent = YES;
                }
                else
                {
                    destination[i] = [self collectionFromCollection:source[i]
                                                 bySettingComponent:component
                                                     forKeyPathKeys:keyPathKeys
                                                             didSet:didSetComponent];
                }
            }
            else
            {
                destination[i] = source[i];
            }
        }
        
        if ( !(*didSetComponent) && keyPathKeys.count == 0 )
        {
            [destination addObject:component];
            *didSetComponent = YES;
        }
        
        return destination;
    }
    else
    {
        NSMutableDictionary *sourceDictionary = (NSMutableDictionary *)source;
        NSMutableDictionary *destination = [[NSMutableDictionary alloc] init];
        for ( NSString *key in sourceDictionary.allKeys )
        {
            if ( [key isEqualToString:currentKey] && !(*didSetComponent) )
            {
                if ( keyPathKeys.count == 0 )
                {
                    destination[ currentKey ] = component;
                    *didSetComponent = YES;
                }
                else
                {
                    destination[ key ] = [self collectionFromCollection:source[ key ]
                                                     bySettingComponent:component
                                                         forKeyPathKeys:keyPathKeys
                                                                 didSet:didSetComponent];
                }
            }
            else
            {
                // TODO: Test to make sure existing values are transfered
                destination[ key ] = source[ key ];
            }
        }
        
        if ( !(*didSetComponent) && keyPathKeys.count == 0 )
        {
            destination[ currentKey ] = component;
            *didSetComponent = YES;
        }
        
        return destination;
    }
}

- (NSMutableArray *)arrayFromArray:(NSArray *)source
                bySettingComponent:(NSDictionary *)component
                        forIndexes:(NSMutableArray *)indexes
                            didSet:(BOOL *)didSetComponent
{
    return nil;
}

@end
