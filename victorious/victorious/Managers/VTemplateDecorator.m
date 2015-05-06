//
//  VTemplateDecorator.m
//  victorious
//
//  Created by Patrick Lynch on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTemplateDecorator.h"

static NSString * const kJSONType = @"json";
static NSString * const kKeyPathDelimiter = @"/";

@interface VTemplateDecorator()

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSDictionary *originalTemplate;
@property (nonatomic, strong, readwrite) NSMutableDictionary *workingTemplate;

@end

@implementation VTemplateDecorator

+ (NSDictionary *)dictionaryFromJSONFile:(NSString *)filename
{
    NSString *pathInBundle = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:kJSONType];
    NSError *error = nil;
    
    NSAssert( pathInBundle != nil, @"VTemplateDecorator cannot find path in bundle for filename \"%@\". \
             Make sure the file is added to the project and do not included the \".json\" extension.", filename );
    
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

+ (NSString *)JSONStringFromDictionary:(NSDictionary *)dictionary
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (instancetype)init
{
    return [self initWithTemplateDictionary:nil];
}

- (instancetype)initWithTemplateDictionary:(NSDictionary *)templateDictionary
{
    NSParameterAssert( templateDictionary != nil );
    
    self = [super init];
    if ( self != nil )
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

- (BOOL)concatenateTemplateWithFilename:(NSString *)filename
{
    NSDictionary *templateAddition = [VTemplateDecorator dictionaryFromJSONFile:filename];
    
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
    NSDictionary *component = [VTemplateDecorator dictionaryFromJSONFile:filename];
    if ( component != nil )
    {
        return [self setTemplateValue:component forKeyPath:keyPath];
    }
    return NO;
}

- (BOOL)setTemplateValue:(id)templateValue forKeyPath:(NSString *)keyPath
{
    NSMutableArray *keyPathKeys = [[NSMutableArray alloc] initWithArray:[keyPath componentsSeparatedByString:kKeyPathDelimiter]];
    BOOL didSetTemplateValue = NO;
    self.workingTemplate = [self collectionFromCollection:self.workingTemplate
                                   bySettingTemplateValue:templateValue
                                           forKeyPathKeys:keyPathKeys
                                                   didSet:&didSetTemplateValue];
    
    return didSetTemplateValue;
}

- (id)collectionFromCollection:(id)source
        bySettingTemplateValue:(id)templateValue
                forKeyPathKeys:(NSMutableArray *)keyPathKeys
                        didSet:(BOOL *)didSetTemplateValue
{
    if ( keyPathKeys.count == 0 )
    {
        return nil;
    }
    
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

- (id)templateValueForKeyPath:(NSString *)keyPath
{
    NSMutableArray *keyPathKeys = [[NSMutableArray alloc] initWithArray:[keyPath componentsSeparatedByString:kKeyPathDelimiter]];
    NSDictionary *source = [NSDictionary dictionaryWithDictionary:self.workingTemplate];
    return [self valueInCollection:source forKeyPathKeys:keyPathKeys];
}

- (id)valueInCollection:(id)source forKeyPathKeys:(NSMutableArray *)keyPathKeys
{
    if ( keyPathKeys.count == 0 )
    {
        return nil;
    }
    
    NSString *currentKey = keyPathKeys.firstObject;
    [keyPathKeys removeObjectAtIndex:0];
    
    if ( [source isKindOfClass:[NSArray class]] && [self.numberFormatter numberFromString:currentKey] != nil )
    {
        NSInteger index = [self.numberFormatter numberFromString:currentKey].integerValue;
        NSMutableArray *sourceArray = (NSMutableArray *)source;
        id value = index >= 0 && index < (NSInteger)sourceArray.count ? sourceArray[ index ] : nil;
        if ( value != nil )
        {
            if ( keyPathKeys.count == 0 )
            {
                return value;
            }
            else if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] )
            {
                return [self valueInCollection:value forKeyPathKeys:keyPathKeys];
            }
        }
    }
    else if ( [source isKindOfClass:[NSDictionary class]] )
    {
        id value = ((NSDictionary *)source)[ currentKey ];
        if ( value != nil )
        {
            if ( keyPathKeys.count == 0 )
            {
                return value;
            }
            else if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] )
            {
                return [self valueInCollection:value forKeyPathKeys:keyPathKeys];
            }
        }
    }
    return nil;
}

- (void)setValue:(id)templateValue forAllOccurencesOfKey:(NSString *)key
{
    NSParameterAssert( templateValue != nil );
    
    self.workingTemplate = [self setValue:templateValue forAllOccurencesOfKey:key inCollection:self.workingTemplate];
}

- (id)setValue:(id)templateValue forAllOccurencesOfKey:(NSString *)key inCollection:(id)source
{
    NSParameterAssert( [source isKindOfClass:[NSArray class]] || [source isKindOfClass:[NSDictionary class]] );
    
    if ( [source isKindOfClass:[NSArray class]] )
    {
        NSMutableArray *destination = [[NSMutableArray alloc] init];
        NSMutableArray *sourceArray = (NSMutableArray *)source;
        for ( NSInteger i = 0; i < (NSInteger)sourceArray.count; i++ )
        {
            id value = sourceArray[ i ];
            if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] )
            {
                destination[ i ] = [self setValue:templateValue forAllOccurencesOfKey:key inCollection:value];
            }
            else
            {
                destination[ i ] = value;
            }
        }
        return destination;
    }
    else if ( [source isKindOfClass:[NSDictionary class]] )
    {
        NSMutableDictionary *destination = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *sourceDictionary = (NSMutableDictionary *)source;
        for ( NSString *templateKey in sourceDictionary.allKeys )
        {
            id value = ((NSDictionary *)source)[ templateKey ];
            if ( [templateKey isEqualToString:key] )
            {
                destination[ templateKey ] = templateValue;
            }
            else
            {
                if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] )
                {
                    destination[ templateKey ] = [self setValue:templateValue forAllOccurencesOfKey:key inCollection:value];
                }
                else
                {
                    destination[ templateKey ] = source[ templateKey ];
                }
            }
        }
        return destination;
    }
    
    return nil;
}

- (NSArray *)keyPathsForKey:(NSString *)key
{
    NSParameterAssert( key != nil );
    
    NSMutableArray *completedKeyPaths = [[NSMutableArray alloc] init];
    NSMutableArray *workingKeyPath = [[NSMutableArray alloc] init];
    [self searchCollection:self.workingTemplate forKey:key workingKeyPath:&workingKeyPath completedKeyPaths:&completedKeyPaths];
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    for ( NSArray *keyPathArray in completedKeyPaths )
    {
        NSMutableString *mutableKeyPath = [[NSMutableString alloc] init];
        for ( NSString *key in keyPathArray )
        {
            if ( ![mutableKeyPath isEqualToString:@""] )
            {
                [mutableKeyPath appendString:kKeyPathDelimiter];
            }
            [mutableKeyPath appendString:key];
        }
        [output addObject:[[NSString alloc] initWithString:mutableKeyPath]];
    }
    
    return [[NSArray alloc] initWithArray:output];
}

- (void)searchCollection:(id)collection
                  forKey:(NSString *)key
          workingKeyPath:(NSMutableArray **)workingKeyPath
       completedKeyPaths:(NSMutableArray **)completedKeyPaths
{
    if ( [collection isKindOfClass:[NSArray class]] )
    {
        NSArray *collectionArray = (NSArray *)collection;
        for ( NSInteger i = 0; i < (NSInteger)collectionArray.count; i++ )
        {
            id value = collectionArray[ i ];
            if ( [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]] )
            {
                [*workingKeyPath addObject:@(i).stringValue];
                [self searchCollection:value forKey:key workingKeyPath:workingKeyPath completedKeyPaths:completedKeyPaths];
                [*workingKeyPath removeLastObject];
            }
        }
    }
    else if ( [collection isKindOfClass:[NSDictionary class]] )
    {
        NSDictionary *collectionDictionary = (NSDictionary *)collection;
        for ( NSString *templateKey in collectionDictionary.allKeys )
        {
            id value = collectionDictionary[ templateKey ];
            if ( [templateKey isEqualToString:key] )
            {
                [*workingKeyPath addObject:templateKey];
                [*completedKeyPaths addObject:[NSArray arrayWithArray:*workingKeyPath]];
                [*workingKeyPath removeLastObject];
            }
            
            if ( [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]] )
            {
                [*workingKeyPath addObject:templateKey];
                [self searchCollection:value forKey:key workingKeyPath:workingKeyPath completedKeyPaths:completedKeyPaths];
                [*workingKeyPath removeLastObject];
            }
        }
    }
}

@end
