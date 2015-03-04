//
//  VDependencyManager.m
//  victorious
//
//  Created by Josh Hinman on 10/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"

#if CGFLOAT_IS_DOUBLE
#define CGFLOAT_VALUE doubleValue
#else
#define CGFLOAT_VALUE floatValue
#endif

static NSString * const kTemplateClassesFilename = @"TemplateClasses";
static NSString * const kPlistFileExtension = @"plist";

// multi-purpose keys
NSString * const VDependencyManagerTitleKey = @"title";
NSString * const VDependencyManagerBackgroundKey = @"background";
NSString * const VDependencyManagerImageURLKey = @"imageURL";

// Keys for colors
NSString * const VDependencyManagerBackgroundColorKey = @"color.background";
NSString * const VDependencyManagerSecondaryBackgroundColorKey = @"color.background.secondary";
NSString * const VDependencyManagerMainTextColorKey = @"color.text";
NSString * const VDependencyManagerContentTextColorKey = @"color.text.content";
NSString * const VDependencyManagerAccentColorKey = @"color.accent";
NSString * const VDependencyManagerSecondaryAccentColorKey = @"color.accent.secondary";
NSString * const VDependencyManagerLinkColorKey = @"color.link";
NSString * const VDependencyManagerSecondaryLinkColorKey = @"color.link.secondary";

static NSString * const kRedKey = @"red";
static NSString * const kGreenKey = @"green";
static NSString * const kBlueKey = @"blue";
static NSString * const kAlphaKey = @"alpha";

// Keys for fonts
NSString * const VDependencyManagerHeaderFontKey = @"font.header";
NSString * const VDependencyManagerHeading1FontKey = @"font.heading1";
NSString * const VDependencyManagerHeading2FontKey = @"font.heading2";
NSString * const VDependencyManagerHeading3FontKey = @"font.heading3";
NSString * const VDependencyManagerHeading4FontKey = @"font.heading4";
NSString * const VDependencyManagerParagraphFontKey = @"font.paragraph";
NSString * const VDependencyManagerLabel1FontKey = @"font.label1";
NSString * const VDependencyManagerLabel2FontKey = @"font.label2";
NSString * const VDependencyManagerLabel3FontKey = @"font.label3";
NSString * const VDependencyManagerLabel4FontKey = @"font.label4";
NSString * const VDependencyManagerButton1FontKey = @"font.button1";
NSString * const VDependencyManagerButton2FontKey = @"font.button2";

// Keys for dependency metadata
static NSString * const kIDKey = @"id";
static NSString * const kReferenceIDKey = @"referenceID";
static NSString * const kClassNameKey = @"name";
static NSString * const kFontNameKey = @"fontName";
static NSString * const kFontSizeKey = @"fontSize";
static NSString * const kImageURLKey = @"imageURL";

// Keys for experiments
NSString * const VDependencyManagerHistogramEnabledKey = @"histogram_enabled";
NSString * const VDependencyManagerProfileImageRequiredKey = @"require_profile_image";

// Keys for view controllers
NSString * const VDependencyManagerScaffoldViewControllerKey = @"scaffold";
NSString * const VDependencyManagerInitialViewControllerKey = @"initialScreen";

// Keys for Workspace
NSString * const VDependencyManagerWorkspaceFlowKey = @"workspaceFlow";
NSString * const VDependencyManagerImageWorkspaceKey = @"imageWorkspace";
NSString * const VDependencyManagerVideoWorkspaceKey = @"videoWorkspace";

@interface VDependencyManager ()

@property (nonatomic, strong) VDependencyManager *parentManager;
@property (nonatomic, strong) NSDictionary *configuration;
@property (nonatomic, copy) NSDictionary *classesByTemplateName;
@property (nonatomic, strong) NSMutableDictionary *singletonsByID; ///< This dictionary should only be accessed from the privateQueue
@property (nonatomic, strong) NSDictionary *configurationDictionariesByID;
@property (nonatomic) dispatch_queue_t privateQueue;

@end

@implementation VDependencyManager

- (instancetype)initWithParentManager:(VDependencyManager *)parentManager
                        configuration:(NSDictionary *)configuration
    dictionaryOfClassesByTemplateName:(NSDictionary *)classesByTemplateName
{
    self = [super init];
    if (self)
    {
        _parentManager = parentManager;
        _configuration = [self preparedConfigurationWithUnpreparedDictionary:configuration];
        _privateQueue = dispatch_queue_create("com.getvictorious.VDependencyManager", DISPATCH_QUEUE_CONCURRENT);
        _configurationDictionariesByID = [self findConfigurationDictionariesByIDInTemplateDictionary:_configuration];
        
        if (_parentManager == nil)
        {
            _singletonsByID = [[NSMutableDictionary alloc] init];
        }
        
        if (classesByTemplateName == nil)
        {
            _classesByTemplateName = [self defaultDictionaryOfClassesByTemplateName];
        }
        else
        {
            _classesByTemplateName = classesByTemplateName;
        }
    }
    return self;
}

#pragma mark - High-level dependency getters

- (UIColor *)colorForKey:(NSString *)key
{
    NSDictionary *colorDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    
    if (![colorDictionary isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    NSNumber *red = colorDictionary[kRedKey];
    NSNumber *green = colorDictionary[kGreenKey];
    NSNumber *blue = colorDictionary[kBlueKey];
    NSNumber *alpha = colorDictionary[kAlphaKey];
    
    if (![red isKindOfClass:[NSNumber class]] ||
        ![green isKindOfClass:[NSNumber class]] ||
        ![blue isKindOfClass:[NSNumber class]] ||
        ![alpha isKindOfClass:[NSNumber class]])
    {
        return nil;
    }
    
    UIColor *color = [UIColor colorWithRed:[red CGFLOAT_VALUE] / 255.0f
                                     green:[green CGFLOAT_VALUE] / 255.0f
                                      blue:[blue CGFLOAT_VALUE] / 255.0f
                                     alpha:[alpha CGFLOAT_VALUE]];
    return color;
}

- (UIFont *)fontForKey:(NSString *)key
{
    NSDictionary *fontDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    
    NSString *fontName = fontDictionary[kFontNameKey];
    NSNumber *fontSize = fontDictionary[kFontSizeKey];
    
    if (![fontName isKindOfClass:[NSString class]] ||
        ![fontSize isKindOfClass:[NSNumber class]])
    {
        return nil;
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:[fontSize CGFLOAT_VALUE]];
    return font;
}

- (NSString *)stringForKey:(NSString *)key
{
    return [self templateValueOfType:[NSString class] forKey:key];
}

- (NSNumber *)numberForKey:(NSString *)key
{
    return [self templateValueOfType:[NSNumber class] forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *image = nil;
    NSDictionary *imageDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    
    if ( imageDictionary != nil )
    {
        NSString *imageURL = imageDictionary[kImageURLKey];
        
        if (![imageURL isKindOfClass:[NSString class]])
        {
            return nil;
        }
        image = [UIImage imageNamed:imageURL];
    }
    else
    {
        image = [self templateValueOfType:[UIImage class] forKey:key];
    }
    return image;
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    return [self templateValueOfType:[UIViewController class] forKey:key];
}

- (UIViewController *)singletonViewControllerForKey:(NSString *)key
{
    return [self singletonObjectOfType:[UIViewController class] forKey:key];
}

#pragma mark - Arrays of dependencies

- (NSArray *)arrayForKey:(NSString *)key
{
    return [self templateValueOfType:[NSArray class] forKey:key];
}

- (NSArray *)arrayOfValuesOfType:(Class)expectedType forKey:(NSString *)key
{
    return [self arrayOfValuesOfType:expectedType
                              forKey:key
                withTranslationBlock:^id(__unsafe_unretained Class expectedType, NSDictionary *dict)
    {
        return [self objectOfType:expectedType fromDictionary:dict];
    }];
}

- (NSArray *)arrayOfSingletonValuesOfType:(Class)expectedType forKey:(NSString *)key
{
    return [self arrayOfValuesOfType:expectedType
                              forKey:key
                withTranslationBlock:^id(__unsafe_unretained Class expectedType, NSDictionary *dict)
    {
        return [self singletonObjectOfType:expectedType fromDictionary:dict];
    }];
}

/**
 Returns an array of dependent objects created from a JSON array
 
 @param array An array pulled straight from within the template configuration
 @param translation A block that, given an expected type and a configuration dictionary, will return an object described by that dictionary
 */
- (NSArray *)arrayOfValuesOfType:(Class)expectedType forKey:(NSString *)key withTranslationBlock:(id(^)(Class, NSDictionary *))translation
{
    NSParameterAssert(translation != nil);
    NSArray *templateArray = [self arrayForKey:key];
    
    if ( templateArray.count == 0 )
    {
        return @[];
    }
    
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithCapacity:templateArray.count];
    for (id templateObject in templateArray)
    {
        if ( [templateObject isKindOfClass:expectedType] )
        {
            [returnValue addObject:templateObject];
        }
        else if ( [templateObject isKindOfClass:[NSDictionary class]] )
        {
            id realObject = translation(expectedType, templateObject);
            
            if ( realObject != nil )
            {
                [returnValue addObject:realObject];
            }
        }
    }
    return [returnValue copy];
}

#pragma mark - Singleton dependencies

- (id)singletonObjectOfType:(Class)expectedType forKey:(NSString *)key
{
    id value = self.configuration[key];
    
    if (value == nil)
    {
        return [self.parentManager singletonObjectOfType:expectedType forKey:key];
    }
    
    if ([value isKindOfClass:[NSDictionary class]] && value[kReferenceIDKey] != nil)
    {
        value = [self configurationDictionaryForID:value[kReferenceIDKey]];
    }
    
    if ([value isKindOfClass:expectedType])
    {
        return value;
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        return [self singletonObjectOfType:expectedType fromDictionary:value];
    }
    
    return nil;
}

- (id)singletonObjectOfType:(Class)expectedType fromDictionary:(NSDictionary *)configurationDictionary
{
    NSString *objID = configurationDictionary[kIDKey];
    
    if (objID == nil)
    {
        return nil;
    }
    id singletonObject = [self singletonObjectForID:objID];
    
    if (singletonObject == nil)
    {
        singletonObject = [self objectOfType:expectedType fromDictionary:configurationDictionary];
        
        if (singletonObject != nil)
        {
            [self setSingletonObject:singletonObject forID:objID];
        }
    }
    return singletonObject;
}

- (id)singletonObjectForID:(NSString *)objectID
{
    if (self.singletonsByID == nil)
    {
        return [self.parentManager singletonObjectForID:objectID];
    }
    
    __block id singletonObject = nil;
    dispatch_sync(self.privateQueue, ^(void)
    {
        singletonObject = self.singletonsByID[objectID];
    });
    
    if (singletonObject == nil)
    {
        singletonObject = [self.parentManager singletonObjectForID:objectID];
    }
    return singletonObject;
}

- (void)setSingletonObject:(id)singletonObject forID:(NSString *)objectID
{
    NSParameterAssert(singletonObject != nil);
    NSParameterAssert(objectID != nil);

    if (self.singletonsByID != nil)
    {
        dispatch_barrier_async(self.privateQueue, ^(void)
        {
            self.singletonsByID[objectID] = singletonObject;
        });
    }
    else
    {
        [self.parentManager setSingletonObject:singletonObject forID:objectID];
    }
}

#pragma mark - Dependency getter primatives

- (id)templateValueOfType:(Class)expectedType forKey:(NSString *)key
{
    return [self templateValueOfType:expectedType forKey:key withAddedDependencies:nil];
}

- (id)templateValueOfType:(Class)expectedType forKey:(NSString *)key withAddedDependencies:(NSDictionary *)dependencies
{
    id value = self.configuration[key];
    
    if (value == nil)
    {
        return [self.parentManager templateValueOfType:expectedType forKey:key withAddedDependencies:dependencies];
    }
    
    if ([value isKindOfClass:[NSDictionary class]] && value[kReferenceIDKey] != nil)
    {
        value = [self configurationDictionaryForID:value[kReferenceIDKey]];
    }
    
    if ([value isKindOfClass:expectedType])
    {
        return value;
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *configurationDictionary = value;
        if ( dependencies != nil )
        {
            NSMutableDictionary *configurationDictionaryWithAddedDependencies = [configurationDictionary mutableCopy];
            [configurationDictionaryWithAddedDependencies addEntriesFromDictionary:dependencies];
            configurationDictionary = [configurationDictionaryWithAddedDependencies copy];
        }
        return [self objectOfType:expectedType fromDictionary:configurationDictionary];
    }
    
    return nil;
}

- (id)objectOfType:(Class)expectedType fromDictionary:(NSDictionary *)configurationDictionary
{
    Class templateClass = [self classWithTemplateName:configurationDictionary[kClassNameKey]];
    
    if ([templateClass isSubclassOfClass:expectedType])
    {
        id object;
        VDependencyManager *dependencyManager = [self childDependencyManagerWithAddedConfiguration:configurationDictionary];
        
        if ([templateClass instancesRespondToSelector:@selector(initWithDependencyManager:)])
        {
            object = [[templateClass alloc] initWithDependencyManager:dependencyManager];
        }
        else if ([templateClass respondsToSelector:@selector(newWithDependencyManager:)])
        {
            object = [templateClass newWithDependencyManager:dependencyManager];
        }
        else
        {
            object = [[templateClass alloc] init];
            
            if ([object respondsToSelector:@selector(setDependencyManager:)])
            {
                [object setDependencyManager:dependencyManager];
            }
        }
        return object;
    }
    else if ( [expectedType isSubclassOfClass:[NSDictionary class]] )
    {
        return configurationDictionary;
    }
    
    return nil;
}

- (NSDictionary *)configurationDictionaryForID:(NSString *)objectID
{
    NSDictionary *configurationDictionary = self.configurationDictionariesByID[objectID];
    
    if (configurationDictionary == nil)
    {
        return [self.parentManager configurationDictionaryForID:objectID];
    }
    return configurationDictionary;
}

#pragma mark - Helpers

/**
 Scans the given template dictionary for configurations that specify an ID,
 and returns a dictionary where the key is an ID and the value is the 
 dictionary that specifies that key.
 */
- (NSDictionary *)findConfigurationDictionariesByIDInTemplateDictionary:(NSDictionary *)template
{
    NSMutableDictionary *configurationDictionariesByID = [[NSMutableDictionary alloc] init];
    void (^__block __weak weakEnumerationBlock)(id);
    void (^enumerationBlock)(id) = ^(id obj)
    {
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *objID = obj[kIDKey];
            if (objID != nil)
            {
                configurationDictionariesByID[objID] = obj;
            }
            [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
            {
                weakEnumerationBlock(obj);
            }];
        }
        else if ([obj isKindOfClass:[NSArray class]])
        {
            [(NSArray *)obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
            {
                weakEnumerationBlock(obj);
            }];
        }
    };
    weakEnumerationBlock = enumerationBlock;
    
    [template enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        weakEnumerationBlock(obj);
    }];
    return configurationDictionariesByID;
}

/**
 Takes a configuration dictionary and returns it after adding IDs to any components that are missing one.
 */
- (NSDictionary *)preparedConfigurationWithUnpreparedDictionary:(NSDictionary *)configurationDictionary
{
    NSMutableDictionary *preparedDictionary = [configurationDictionary mutableCopy];
    
    NSArray *keys = preparedDictionary.allKeys;
    for (id key in keys)
    {
        id value = preparedDictionary[key];
        if ( [value isKindOfClass:[NSDictionary class]] )
        {
            NSDictionary *component = (NSDictionary *)value;
            if ( [self isDictionaryAComponentWithoutAnID:component] )
            {
                preparedDictionary[key] = [self componentByAddingIDToComponent:component];
            }
        }
        else if ( [value isKindOfClass:[NSArray class]] )
        {
            NSMutableArray *preparedArray = [value mutableCopy];
            NSUInteger count = preparedArray.count;
            for (NSUInteger n = 0; n < count; n++)
            {
                NSDictionary *component = preparedArray[n];
                if ( [component isKindOfClass:[NSDictionary class]] && [self isDictionaryAComponentWithoutAnID:component] )
                {
                    preparedArray[n] = [self componentByAddingIDToComponent:component];
                }
            }
            preparedDictionary[key] = preparedArray;
        }
    }
    return preparedDictionary;
}

- (NSDictionary *)componentByAddingIDToComponent:(NSDictionary *)component
{
    NSMutableDictionary *preparedComponent = [component mutableCopy];
    preparedComponent[kIDKey] = [[NSUUID UUID] UUIDString];
    return preparedComponent;
}

- (BOOL)isDictionaryAComponentWithoutAnID:(NSDictionary *)possibleComponent
{
    return possibleComponent[kClassNameKey] != nil && possibleComponent[kIDKey] == nil;
}

- (VDependencyManager *)childDependencyManagerWithAddedConfiguration:(NSDictionary *)configuration
{
    return [[VDependencyManager alloc] initWithParentManager:self configuration:configuration dictionaryOfClassesByTemplateName:self.classesByTemplateName];
}

#pragma mark - Class name resolution

- (NSDictionary *)defaultDictionaryOfClassesByTemplateName
{
    NSURL *plistFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:kTemplateClassesFilename withExtension:kPlistFileExtension];
    if (plistFileURL == nil)
    {
        return nil;
    }
    
    NSData *plistData = [NSData dataWithContentsOfURL:plistFileURL];
    if (plistData == nil)
    {
        return nil;
    }
    
    return [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:nil error:nil];
}

/**
 Returns the class that matches the specified
 name from a template file.
 */
- (Class)classWithTemplateName:(NSString *)identifier
{
    return NSClassFromString(self.classesByTemplateName[identifier]);
}

@end
