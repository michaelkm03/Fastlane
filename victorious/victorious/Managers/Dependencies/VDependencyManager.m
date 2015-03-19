//
//  VDependencyManager.m
//  victorious
//
//  Created by Josh Hinman on 10/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"
#import "VSolidColorBackground.h"
#import "VURLMacroReplacement.h"

#if CGFLOAT_IS_DOUBLE
#define CGFLOAT_VALUE doubleValue
#else
#define CGFLOAT_VALUE floatValue
#endif

typedef BOOL (^TypeTest)(Class);

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

// Keys for image URLs
static NSString * const kImageCountKey = @"imageCount";
static NSString * const kImageMacroKey = @"imageMacro";
static NSString * const kScaleKey = @"scale";
static NSString * const kMacroReplacement = @"XXXXX";

@interface VDependencyManager ()

@property (nonatomic, strong) VDependencyManager *parentManager;
@property (nonatomic, strong) NSDictionary *configuration;
@property (nonatomic, copy) NSDictionary *classesByTemplateName;
@property (nonatomic, strong) NSMutableDictionary *singletonsByID; ///< This dictionary should only be accessed from the privateQueue
@property (nonatomic, strong) NSMutableDictionary *childDependencyManagersByID; ///< This dictionary should only be accessed from the privateQueue
@property (nonatomic, strong) NSMutableArray *imageURLs; ///< This array should only be accessed from the privateQueue
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
        
        if (_parentManager == nil)
        {
            _singletonsByID = [[NSMutableDictionary alloc] init];
            _childDependencyManagersByID = [[NSMutableDictionary alloc] init];
            _imageURLs = [[NSMutableArray alloc] init];
        }
        [self scanConfiguration:_configuration];

        if (classesByTemplateName == nil)
        {
            if ( _parentManager == nil )
            {
                _classesByTemplateName = [self defaultDictionaryOfClassesByTemplateName];
            }
            else
            {
                _classesByTemplateName = _parentManager.classesByTemplateName ?: [self defaultDictionaryOfClassesByTemplateName];
            }
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
    // TODO: special case: we switched from using a background color key to a background component,
    //       but not everything has been updated to use it yet. Until everything is updated,
    //       we return a background color extracted from the background component to anyone who
    //       asks for the old background color key.
    if ( [key isEqualToString:VDependencyManagerBackgroundColorKey] )
    {
        VSolidColorBackground *background = [self templateValueOfType:[VSolidColorBackground class] forKey:VDependencyManagerBackgroundKey];
        return background.backgroundColor;
    }
    
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
                                     alpha:[alpha CGFLOAT_VALUE] / 255.0f];
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
    TypeTest typeTest = [self typeTestForType:expectedType];
    return [self arrayOfValuesWhereTypePassesTest:typeTest
                                           forKey:key
                             withTranslationBlock:^id(VDependencyManager *dependencyManager)
    {
        return [self objectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
    }];
}

- (NSArray *)arrayOfSingletonValuesOfType:(Class)expectedType forKey:(NSString *)key
{
    TypeTest typeTest = [self typeTestForType:expectedType];
    return [self arrayOfValuesWhereTypePassesTest:typeTest
                                           forKey:key
                             withTranslationBlock:^id(VDependencyManager *dependencyManager)
    {
        return [self singletonObjectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
    }];
}

- (NSArray *)arrayOfValuesConformingToProtocol:(Protocol *)protocol forKey:(NSString *)key
{
    TypeTest typeTest = ^(Class type) { return [type conformsToProtocol:protocol]; };
    return [self arrayOfValuesWhereTypePassesTest:typeTest
                                           forKey:key
                             withTranslationBlock:^id(VDependencyManager *dependencyManager)
    {
        return [self objectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
    }];
}

- (NSArray *)arrayOfSingletonValuesConformingToProtocol:(Protocol *)protocol forKey:(NSString *)key
{
    TypeTest typeTest = ^(Class type) { return [type conformsToProtocol:protocol]; };
    return [self arrayOfValuesWhereTypePassesTest:typeTest
                                           forKey:key
                             withTranslationBlock:^id(VDependencyManager *dependencyManager)
    {
        return [self singletonObjectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
    }];
}

/**
 Returns an array of dependent objects created from a JSON array
 
 @param array An array pulled straight from within the template configuration
 @param translation A block that, given a dependency manager instance, will return an object generated with that dependency manager
 */
- (NSArray *)arrayOfValuesWhereTypePassesTest:(TypeTest)typeTest forKey:(NSString *)key withTranslationBlock:(id(^)(VDependencyManager *))translation
{
    NSParameterAssert(typeTest != nil);
    NSParameterAssert(translation != nil);
    NSArray *templateArray = [self arrayForKey:key];
    
    if ( templateArray.count == 0 )
    {
        return @[];
    }
    
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithCapacity:templateArray.count];
    for (id templateObject in templateArray)
    {
        VDependencyManager *dependencyManager = nil;
        
        if ( [templateObject isKindOfClass:[NSDictionary class]] && [(NSDictionary *)templateObject objectForKey:kReferenceIDKey] != nil )
        {
            dependencyManager = [self childDependencyManagerForID:[(NSDictionary *)templateObject objectForKey:kReferenceIDKey]];
        }
        else if ( !typeTest([NSDictionary class]) && [templateObject isKindOfClass:[NSDictionary class]] )
        {
            dependencyManager = [self childDependencyManagerForID:[(NSDictionary *)templateObject objectForKey:kIDKey]];
        }
        else if ( typeTest([templateObject class]) )
        {
            [returnValue addObject:templateObject];
            continue;
        }
        
        if ( dependencyManager != nil )
        {
            id realObject = translation(dependencyManager);
            if ( realObject != nil )
            {
                [returnValue addObject:realObject];
            }
        }
    }
    return [returnValue copy];
}

- (NSArray *)arrayOfImageURLsForKey:(NSString *)key
{
    NSDictionary *imageDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    if ( imageDictionary == nil )
    {
        return nil;
    }
    return [self arrayOfImageURLsWithDictionary:imageDictionary];
}

- (NSArray *)arrayOfImageURLsWithDictionary:(NSDictionary *)imageDictionary
{
    NSNumber *imageCount = imageDictionary[kImageCountKey];
    NSString *macro = imageDictionary[kImageMacroKey];
    
    if ( ![imageCount isKindOfClass:[NSNumber class]] || ![macro isKindOfClass:[NSString class]] )
    {
        return nil;
    }
    
    NSMutableArray *imageURLs = [[NSMutableArray alloc] initWithCapacity:[imageCount unsignedIntegerValue]];
    VURLMacroReplacement *macroReplacement = [[VURLMacroReplacement alloc] init];
    for (NSUInteger n = 0; n < [imageCount unsignedIntegerValue]; n++)
    {
        NSString *macroReplacementString = [NSString stringWithFormat:@"%.5lu", (unsigned long)n];
        [imageURLs addObject:[macroReplacement urlByReplacingMacrosFromDictionary:@{ kMacroReplacement: macroReplacementString}
                                                                      inURLString:macro]];
    }
    
    return imageURLs;
}

- (NSArray *)arrayOfAllImageURLs
{
    if ( self.imageURLs == nil )
    {
        return [self.parentManager arrayOfAllImageURLs];
    }
    
    __block NSArray *allImageURLs;
    dispatch_sync(self.privateQueue, ^(void)
    {
        allImageURLs = [self.imageURLs copy];
    });
    return allImageURLs;
}

#pragma mark - Singleton dependencies

- (id)singletonObjectOfType:(Class)expectedType forKey:(NSString *)key
{
    return [self singletonObjectWhereTypePassesTest:[self typeTestForType:expectedType] forKey:key];
}

- (id)singletonObjectWhereTypePassesTest:(TypeTest)typeTest forKey:(NSString *)key
{
    id value = self.configuration[key];
    
    if (value == nil)
    {
        return [self.parentManager singletonObjectWhereTypePassesTest:typeTest forKey:key];
    }
    
    if ( [value isKindOfClass:[NSDictionary class]] && [(NSDictionary *)value objectForKey:kReferenceIDKey] != nil )
    {
        VDependencyManager *dependencyManager = [self childDependencyManagerForID:[(NSDictionary *)value objectForKey:kReferenceIDKey]];
        return [self singletonObjectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
    }
    else if ( !typeTest([NSDictionary class]) && [value isKindOfClass:[NSDictionary class]] )
    {
        VDependencyManager *dependencyManager = [self childDependencyManagerForID:[(NSDictionary *)value valueForKey:kIDKey]];
        return [self singletonObjectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
    }
    else if ( typeTest([value class]) )
    {
        return value;
    }
    return nil;
}

/**
 This method will create and store a new singleton if one doesn't exist already.
 
 @seealso -singletonObjectForID:
 */
- (id)singletonObjectWhereTypePassesTest:(TypeTest)typeTest withDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *objectID = [dependencyManager stringForKey:kIDKey];
    if ( objectID == nil )
    {
        return nil;
    }
    id singleton = [self singletonObjectForID:objectID];
    
    if ( singleton == nil )
    {
        singleton = [self objectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
        if ( singleton != nil )
        {
            [self setSingletonObject:singleton forID:objectID];
        }
    }
    return singleton;
}

/**
 This method will return nil if a singleton has not yet been created for the specified ID.
 
 @seealso -singletonObjectOfType:withDependencyManager:
 */
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

/**
 Stores a newly-created singleton so it can be retrieved again later
 
 @seealso -singletonObjectForID:
 */
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
    return [self templateValueWhereTypePassesTest:[self typeTestForType:expectedType]
                                           forKey:key
                            withAddedDependencies:dependencies];
}

- (id)templateValueConformingToProtocol:(Protocol *)protocol forKey:(NSString *)key
{
    return [self templateValueConformingToProtocol:protocol forKey:key withAddedDependencies:nil];
}

- (id)templateValueConformingToProtocol:(Protocol *)protocol forKey:(NSString *)key withAddedDependencies:(NSDictionary *)dependencies
{
    return [self templateValueWhereTypePassesTest:^(Class type) { return [type conformsToProtocol:protocol]; }
                                           forKey:key
                            withAddedDependencies:dependencies];
}

- (id)templateValueWhereTypePassesTest:(TypeTest)typeTest forKey:(NSString *)key withAddedDependencies:(NSDictionary *)dependencies
{
    NSParameterAssert(typeTest != nil);
    id value = self.configuration[key];
    
    if (value == nil)
    {
        return [self.parentManager templateValueWhereTypePassesTest:typeTest forKey:key withAddedDependencies:dependencies];
    }
    
    if ( [value isKindOfClass:[NSDictionary class]] && [(NSDictionary *)value objectForKey:kReferenceIDKey] != nil )
    {
        VDependencyManager *dependencyManager = [self childDependencyManagerForID:[(NSDictionary *)value objectForKey:kReferenceIDKey]];
        return [self objectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
    }
    else if ( [value isKindOfClass:[NSDictionary class]] && !typeTest([NSDictionary class]) )
    {
        VDependencyManager *dependencyManager = [self childDependencyManagerForID:[value valueForKey:kIDKey]];
        if ( dependencies != nil )
        {
            dependencyManager = [dependencyManager childDependencyManagerWithAddedConfiguration:dependencies];
        }
        return [self objectWhereTypePassesTest:typeTest withDependencyManager:dependencyManager];
    }
    else if ( typeTest([value class]) )
    {
        return value;
    }
    
    return nil;
}

- (id)objectOfType:(Class)expectedType withDependencyManager:(VDependencyManager *)dependencyManager
{
    return [self objectWhereTypePassesTest:[self typeTestForType:expectedType] withDependencyManager:dependencyManager];
}

- (id)objectWhereTypePassesTest:(TypeTest)typeTest withDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(typeTest != nil);
    Class templateClass = [self classWithTemplateName:[dependencyManager stringForKey:kClassNameKey]];
    
    if (typeTest(templateClass))
    {
        id object;
        
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
    
    return nil;
}

/**
 Returns a block that accepts a type and returns 
 YES if that type matches an expected type
 */
- (BOOL(^)(Class))typeTestForType:(Class)expectedType
{
    return ^BOOL(Class type)
    {
        if ( [type isSubclassOfClass:[NSDictionary class]] )
        {
            // NSDictionary should only pass the test if it's explicitly asked for (i.e. if expectedType is NSObject and type is NSDictionary, we want to return NO)
            return [expectedType isSubclassOfClass:[NSDictionary class]];
        }
        else
        {
            return [type isSubclassOfClass:expectedType];
        }
    };
}

#pragma mark - Helpers

/**
 Scans and analyzes the configuration dictionary in the following ways:
 
 1. Finds all component definitions, creates child dependency
    managers for them, and adds those child DMs to the 
    self.childDependencyManagersByID dictionary
 2. Finds all image URLs and adds them to the self.imageURLs array
 */
- (void)scanConfiguration:(NSDictionary *)dictionary
{
    for ( id key in dictionary )
    {
        NSDictionary *value = dictionary[key];
        if ( [value isKindOfClass:[NSDictionary class]] )
        {
            if ( value[kClassNameKey] != nil )
            {
                if ( value[kIDKey] != nil )
                {
                    VDependencyManager *childDependencyManager = [self childDependencyManagerWithAddedConfiguration:value];
                    [self setChildDependencyManager:childDependencyManager forID:value[kIDKey]];
                }
            }
            else if ( value[kImageMacroKey] != nil )
            {
                NSArray *images = [self arrayOfImageURLsWithDictionary:value];
                [self addImageURLsWithArray:images];
            }
            else
            {
                [self scanConfiguration:value];
            }
        }
        else if ( [value isKindOfClass:[NSArray class]] )
        {
            [self createChildDependencyManagersFromArray:(NSArray *)value];
        }
    }
}

/**
 Finds all component definitions in the given array
 and creates child dependency managers for them.
 */
- (void)createChildDependencyManagersFromArray:(NSArray *)array
{
    for (NSDictionary *dictionary in array)
    {
        if ( [dictionary isKindOfClass:[NSDictionary class]] )
        {
            if ( dictionary[kClassNameKey] != nil )
            {
                if ( dictionary[kIDKey] != nil )
                {
                    VDependencyManager *childDependencyManager = [self childDependencyManagerWithAddedConfiguration:dictionary];
                    [self setChildDependencyManager:childDependencyManager forID:dictionary[kIDKey]];
                }
            }
            else
            {
                [self scanConfiguration:dictionary];
            }
        }
        else if ( [dictionary isKindOfClass:[NSArray class]] )
        {
            [self createChildDependencyManagersFromArray:(NSArray *)dictionary];
        }
    }
}

/**
 Adds a new (or modifies an existing) entry in the childDependencyManagersByID dictionary
 */
- (void)setChildDependencyManager:(VDependencyManager *)childDependencyManager forID:(NSString *)objectID
{
    if ( self.childDependencyManagersByID == nil )
    {
        [self.parentManager setChildDependencyManager:childDependencyManager forID:objectID];
        return;
    }
    dispatch_barrier_async(self.privateQueue, ^(void)
    {
        self.childDependencyManagersByID[objectID] = childDependencyManager;
    });
}

- (VDependencyManager *)childDependencyManagerForID:(NSString *)objectID
{
    if ( self.childDependencyManagersByID == nil )
    {
        return [self.parentManager childDependencyManagerForID:objectID];
    }
    
    __block VDependencyManager *childDependencyManager;
    dispatch_sync(self.privateQueue, ^(void)
    {
        childDependencyManager = self.childDependencyManagersByID[objectID];
    });
    return childDependencyManager;
}

- (void)addImageURL:(NSString *)imageURL
{
    if ( self.imageURLs == nil )
    {
        [self.parentManager addImageURL:imageURL];
        return;
    }
    dispatch_barrier_async(self.privateQueue, ^(void)
    {
        [self.imageURLs addObject:imageURL];
    });
}

- (void)addImageURLsWithArray:(NSArray *)imageArray
{
    if ( self.imageURLs == nil )
    {
        [self.parentManager addImageURLsWithArray:imageArray];
        return;
    }
    dispatch_barrier_async(self.privateQueue, ^(void)
    {
        [self.imageURLs addObjectsFromArray:imageArray];
    });
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
