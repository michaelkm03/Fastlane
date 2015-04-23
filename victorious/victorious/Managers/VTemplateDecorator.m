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

- (instancetype)init
{
    return [self initWithTemplateDictionary:nil];
}

- (instancetype)initWithTemplateDictionary:(NSDictionary *)templateDictionary
{
    NSParameterAssert( templateDictionary != nil );
    
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
    
    if ( templateAddition == nil )
    {
        return NO;
    }
    
    for ( NSString *key in templateAddition )
    {
        self.workingTemplate[ key ] = templateAddition[ key ];
    }
    
    return YES;
}


- (BOOL)setComponentWithFilename:(NSString *)filename forKeyPath:(NSString *)keyPath
{
    NSDictionary *component = [self dictionaryFromJSONFile:filename];
    if ( component != nil )
    {
        return [self setTemplateValue:component forKeyPath:keyPath];
    }
    return NO;
}

- (BOOL)setTemplateValue:(id)templateValue forKeyPath:(NSString *)keyPath
{
    NSMutableArray *keyPathKeys = [[NSMutableArray alloc] initWithArray:[keyPath componentsSeparatedByString:@"/"]];
    BOOL didSetTemplateValue = NO;
    self.workingTemplate = [self collectionFromCollection:self.workingTemplate
                                   bySettingTemplateValue:templateValue
                                           forKeyPathKeys:keyPathKeys
                                                   didSet:&didSetTemplateValue];
    
    return YES;
}

- (id)collectionFromCollection:(id)source
        bySettingTemplateValue:(id)templateValue
                forKeyPathKeys:(NSMutableArray *)keyPathKeys
                        didSet:(BOOL *)didSetTemplateValue
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
            if ( i == index && !(*didSetTemplateValue) )
            {
                if ( keyPathKeys.count == 0 )
                {
                    destination[i] = templateValue;
                    *didSetTemplateValue = YES;
                }
                else
                {
                    destination[i] = [self collectionFromCollection:source[i]
                                             bySettingTemplateValue:templateValue
                                                     forKeyPathKeys:keyPathKeys
                                                             didSet:didSetTemplateValue];
                }
            }
            else
            {
                destination[i] = source[i];
            }
        }
        
        if ( !(*didSetTemplateValue) && keyPathKeys.count == 0 )
        {
            [destination addObject:templateValue];
            *didSetTemplateValue = YES;
        }
        
        return destination;
    }
    else
    {
        NSMutableDictionary *sourceDictionary = (NSMutableDictionary *)source;
        NSMutableDictionary *destination = [[NSMutableDictionary alloc] init];
        for ( NSString *key in sourceDictionary.allKeys )
        {
            if ( [key isEqualToString:currentKey] && !(*didSetTemplateValue) )
            {
                if ( keyPathKeys.count == 0 )
                {
                    destination[ currentKey ] = templateValue;
                    *didSetTemplateValue = YES;
                }
                else
                {
                    destination[ key ] = [self collectionFromCollection:source[ key ]
                                                 bySettingTemplateValue:templateValue
                                                         forKeyPathKeys:keyPathKeys
                                                                 didSet:didSetTemplateValue];
                }
            }
            else
            {
                // TODO: Test to make sure existing values are transfered
                destination[ key ] = source[ key ];
            }
        }
        
        if ( !(*didSetTemplateValue) && keyPathKeys.count == 0 )
        {
            destination[ currentKey ] = templateValue;
            *didSetTemplateValue = YES;
        }
        
        return destination;
    }
}

@end
