//
//  VDependencyManager.m
//  victorious
//
//  Created by Josh Hinman on 10/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "NSURL+VDataCacheID.h"
#import "VDataCache.h"
#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"
#import "VJSONHelper.h"
#import "VSolidColorBackground.h"
#import "VTemplateImage.h"
#import "VTemplateImageMacro.h"
#import "VTemplateImageSet.h"
#import "VTemplatePackageManager.h"
#import "victorious-Swift.h"

typedef BOOL (^TypeTest)(Class);

static NSString * const kTemplateClassesFilename = @"TemplateClasses";
static NSString * const kPlistFileExtension = @"plist";

// multi-purpose keys
NSString * const VDependencyManagerTitleKey = @"title";
NSString * const VDependencyManagerBackgroundKey = @"background";
NSString * const VDependencyManagerCellBackgroundKey = @"background.cell";

// Keys for colors
NSString * const VDependencyManagerBackgroundColorKey = @"color.background";
NSString * const VDependencyManagerMainTextColorKey = @"color.text";
NSString * const VDependencyManagerContentTextColorKey = @"color.text.content";
NSString * const VDependencyManagerSecondaryTextColorKey = @"color.text.secondary";
NSString * const VDependencyManagerPlaceholderTextColorKey = @"color.text.placeholder";
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
NSString * const VDependencyManagerIDKey = @"id";
static NSString * const kReferenceIDKey = @"referenceID";
static NSString * const kClassNameKey = @"name";
static NSString * const kFontNameKey = @"fontName";
static NSString * const kFontSizeKey = @"fontSize";

// Keys for experiments
NSString * const VDependencyManagerProfileImageRequiredKey = @"requireProfileImage";
NSString * const VDependencyManagerLikeButtonEnabledKey = @"likeButtonEnabled";
NSString * const VDependencyManagerExperimentKeyIDs = @"experiment_ids";

// Keys for view controllers
NSString * const VDependencyManagerScaffoldViewControllerKey = @"scaffold";
NSString * const VDependencyManagerInitialViewControllerKey = @"initialScreen";

// Keys for Workspace
NSString * const VDependencyManagerWorkspaceFlowKey = @"workspaceFlow";
NSString * const VDependencyManagerTextWorkspaceFlowKey = @"textCreateFlow";
NSString * const VDependencyManagerImageWorkspaceKey = @"imageWorkspace";
NSString * const VDependencyManagerEditTextWorkspaceKey = @"editTextWorkspace";
NSString * const VDependencyManagerVideoWorkspaceKey = @"videoWorkspace";
NSString * const VDependencyManagerNativeWorkspaceKey = @"nativeWorkspace";

@interface VDependencyManager ()

@property (nonatomic, strong) VDependencyManager *parentManager;
@property (nonatomic, strong) NSDictionary *configuration;
@property (nonatomic, copy) NSDictionary *classesByTemplateName;
@property (nonatomic, strong) NSMutableDictionary *singletonsByID; ///< This dictionary should only be accessed from the privateQueue
@property (nonatomic, strong) NSMutableDictionary *childDependencyManagersByID; ///< This dictionary should only be accessed from the privateQueue
@property (nonatomic) dispatch_queue_t privateQueue;

@end

@implementation VDependencyManager

- (instancetype)initWithParentManager:(VDependencyManager *)parentManager
                        configuration:(NSDictionary *)configuration
    dictionaryOfClassesByTemplateName:(NSDictionary *)classesByTemplateName
{
    self = [super init];
    if ( self != nil )
    {
        _parentManager = parentManager;
        _configuration = [self preparedConfigurationWithUnpreparedDictionary:configuration];
        _privateQueue = dispatch_queue_create("com.getvictorious.VDependencyManager", DISPATCH_QUEUE_CONCURRENT);
        
        if (_parentManager == nil)
        {
            _singletonsByID = [[NSMutableDictionary alloc] init];
            _childDependencyManagersByID = [[NSMutableDictionary alloc] init];
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

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\n%@", NSStringFromClass([self class]), self.configuration];
}

- (BOOL)containsKey:(NSString *)key
{
    return self.configuration[ key ] != nil;
}

#pragma mark - High-level dependency getters

- (UIColor *)colorForKey:(NSString *)key
{
    NSDictionary *colorDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    UIColor *color = [[self class] colorFromDictionary:colorDictionary];
    
    if ( color == nil )
    {
        return [self.parentManager colorForKey:key];
    }
    else
    {
        return color;
    }
}

+ (UIColor *)colorFromDictionary:(NSDictionary *)colorDictionary
{
    if (![colorDictionary isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    
    VJSONHelper *helper = [[VJSONHelper alloc] init];
    
    NSNumber *red = [helper numberFromJSONValue:colorDictionary[kRedKey]];
    NSNumber *green = [helper numberFromJSONValue:colorDictionary[kGreenKey]];
    NSNumber *blue = [helper numberFromJSONValue:colorDictionary[kBlueKey]];
    NSNumber *alpha = [helper numberFromJSONValue:colorDictionary[kAlphaKey]];
    
    // Work around a bug in the back-end
    if ( alpha.doubleValue == 1.0 )
    {
        alpha = @255;
    }
    
    if ( red == nil ||
         green == nil ||
         blue == nil ||
         alpha == nil )
    {
        return nil;
    }
    
    UIColor *color = [UIColor colorWithRed:[red VCGFLOAT_VALUE] / 255.0f
                                     green:[green VCGFLOAT_VALUE] / 255.0f
                                      blue:[blue VCGFLOAT_VALUE] / 255.0f
                                     alpha:[alpha VCGFLOAT_VALUE] / 255.0f];
    return color;
}

+ (NSDictionary *)dictionaryFromColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ( [color getRed:&r green:&g blue:&b alpha:&a] )
    {
        return @{ kRedKey : @(r * 255.0f), kGreenKey : @(g * 255.0f), kBlueKey : @(b * 255.0f), kAlphaKey : @(a * 255.0f) };
    }
    return nil;
}

- (UIFont *)fontForKey:(NSString *)key
{
    UIFont *font = nil;
    NSDictionary *fontDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    
    VJSONHelper *helper = [[VJSONHelper alloc] init];
    NSString *fontName = fontDictionary[kFontNameKey];
    NSNumber *fontSize = [helper numberFromJSONValue:fontDictionary[kFontSizeKey]];
    
    if ([fontName isKindOfClass:[NSString class]] &&
        [fontSize isKindOfClass:[NSNumber class]])
    {
        font = [self fontWithName:fontName size:[fontSize VCGFLOAT_VALUE]];
    }
    if ( font == nil )
    {
        return [self.parentManager fontForKey:key];
    }
    else
    {
        return font;
    }
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
    NSDictionary *imageDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    
    if ( imageDictionary != nil )
    {
        if ( [VTemplateImage isImageJSON:imageDictionary] )
        {
            VTemplateImage *templateImage = [[VTemplateImage alloc] initWithJSON:imageDictionary];
            return [self imageWithTemplateImage:templateImage];
        }
        else if ( [VTemplateImageSet isImageSetJSON:imageDictionary] )
        {
            VTemplateImageSet *imageSet = [[VTemplateImageSet alloc] initWithJSON:imageDictionary];
            CGFloat scale = [[UIScreen mainScreen] scale];
            return [self imageWithTemplateImage:[imageSet imageForScreenScale:scale]];
        }
        return nil;
    }
    else
    {
        return [self templateValueOfType:[UIImage class] forKey:key];
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    return [self templateValueOfType:[UIViewController class] forKey:key];
}

- (UIViewController *)singletonViewControllerForKey:(NSString *)key
{
    return [self singletonObjectOfType:[UIViewController class] forKey:key];
}

- (UIViewController<Scaffold> *)scaffoldViewController
{
    return (UIViewController<Scaffold> *)[self singletonViewControllerForKey:VDependencyManagerScaffoldViewControllerKey];
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
        else if ( !typeTest([NSDictionary class]) && [templateObject isKindOfClass:[NSDictionary class]] && [self isDictionaryAComponent:templateObject] )
        {
            dependencyManager = [self childDependencyManagerForID:[(NSDictionary *)templateObject objectForKey:VDependencyManagerIDKey]];
        }
        else if ( typeTest([templateObject class]) )
        {
            [returnValue addObject:templateObject];
            continue;
        }
        else if ( typeTest([UIImage class]) && [templateObject isKindOfClass:[NSDictionary class]] && [VTemplateImage isImageJSON:templateObject] )
        {
            VTemplateImage *templateImage = [[VTemplateImage alloc] initWithJSON:templateObject];
            UIImage *image = [self imageWithTemplateImage:templateImage];
            if ( image != nil )
            {
                [returnValue addObject:image];
                continue;
            }
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

- (NSArray *)arrayOfImagesForKey:(NSString *)key
{
    NSDictionary *macroDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    VTemplateImageMacro *imageMacro = [[VTemplateImageMacro alloc] initWithJSON:macroDictionary];
    
    NSArray *templateImages = [imageMacro images];
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithCapacity:templateImages.count];
    for (VTemplateImage *templateImage in templateImages)
    {
        UIImage *image = [self imageWithTemplateImage:templateImage];
        if ( image == nil )
        {
            return @[];
        }
        [returnValue addObject:image];
    }
    return returnValue;
}

- (BOOL)hasArrayOfImagesForKey:(NSString *)key
{
    VDataCache *dataCache = [[VDataCache alloc] init];
    NSDictionary *macroDictionary = [self templateValueOfType:[NSDictionary class] forKey:key];
    VTemplateImageMacro *imageMacro = [[VTemplateImageMacro alloc] initWithJSON:macroDictionary];
    NSArray *templateImages = [imageMacro images];
    
    for (VTemplateImage *templateImage in templateImages)
    {
        if ( ![dataCache hasCachedDataForID:templateImage.imageURL] )
        {
            return NO;
        }
    }
    return YES;
}

- (NSArray *)arrayOfImageURLsWithDictionary:(NSDictionary *)imageDictionary
{
    VTemplateImageMacro *macro = [[VTemplateImageMacro alloc] initWithJSON:imageDictionary];

    NSArray *imagesWithNonNilURL = [macro.images filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"imageURL != nil"]];
    NSArray *imageURLStrings = [imagesWithNonNilURL v_map:^(VTemplateImage *image)
    {
        return image.imageURL.absoluteString;
    }];
    return imageURLStrings;
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
        VDependencyManager *dependencyManager = [self childDependencyManagerForID:[(NSDictionary *)value valueForKey:VDependencyManagerIDKey]];
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
    NSString *objectID = [dependencyManager stringForKey:VDependencyManagerIDKey];
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

- (void)cleanup
{
    dispatch_barrier_sync(self.privateQueue, ^(void)
    {
        [self.singletonsByID removeAllObjects];
        [self.childDependencyManagersByID removeAllObjects];
    });
}

#pragma mark - Feature toggle flags

- (BOOL)festivalIsEnabled
{
    return [[self numberForKey:@"festivalEnabled"] boolValue];
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

- (id)templateValueMatchingAnyType:(NSArray<Class> *)expectedTypes forKey:(NSString *)key withAddedDependencies:(NSDictionary *)dependencies
{
    for (Class expectedType in expectedTypes)
    {
        id value = [self templateValueOfType:expectedType forKey:key withAddedDependencies:dependencies];
        
        if (value)
        {
            return value;
        }
    }
    
    return nil;
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
    
    VDependencyManager *dependencyManagerForReturnedObject = nil;
    if ( [value isKindOfClass:[NSDictionary class]] && [(NSDictionary *)value objectForKey:kReferenceIDKey] != nil )
    {
        dependencyManagerForReturnedObject = [self childDependencyManagerForID:[(NSDictionary *)value objectForKey:kReferenceIDKey]];
    }
    else if ( [value isKindOfClass:[NSDictionary class]] && !typeTest([NSDictionary class]) )
    {
        dependencyManagerForReturnedObject = [self childDependencyManagerForID:[value valueForKey:VDependencyManagerIDKey]];
    }
    else if ( typeTest([value class]) )
    {
        return value;
    }
    
    if ( dependencyManagerForReturnedObject != nil )
    {
        if ( dependencies != nil )
        {
            dependencyManagerForReturnedObject = [dependencyManagerForReturnedObject childDependencyManagerWithAddedConfiguration:dependencies];
        }
        return [self objectWhereTypePassesTest:typeTest withDependencyManager:dependencyManagerForReturnedObject];
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
                if ( value[VDependencyManagerIDKey] != nil )
                {
                    VDependencyManager *childDependencyManager = [self childDependencyManagerWithAddedConfiguration:value];
                    [self setChildDependencyManager:childDependencyManager forID:value[VDependencyManagerIDKey]];
                }
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
                if ( dictionary[VDependencyManagerIDKey] != nil )
                {
                    VDependencyManager *childDependencyManager = [self childDependencyManagerWithAddedConfiguration:dictionary];
                    [self setChildDependencyManager:childDependencyManager forID:dictionary[VDependencyManagerIDKey]];
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
            if ( [self isDictionaryAComponent:component] )
            {
                preparedDictionary[key] = [self componentByAddingIDToComponent:component];
            }
            else
            {
                preparedDictionary[key] = [self preparedConfigurationWithUnpreparedDictionary:component];
            }
        }
        else if ( [value isKindOfClass:[NSArray class]] )
        {
            preparedDictionary[key] = [self preparedArrayWithUnpreparedArray:value];
        }
    }
    return [preparedDictionary copy];
}

/**
 Takes an array of configuration objeccts and returns it after adding IDs to any components that are missing one.
 */
- (NSArray *)preparedArrayWithUnpreparedArray:(NSArray *)configurationArray
{
    NSMutableArray *preparedArray = [configurationArray mutableCopy];
    
    for (NSUInteger n = 0; n < preparedArray.count; n++)
    {
        if ( [preparedArray[n] isKindOfClass:[NSDictionary class]] )
        {
            NSDictionary *component = (NSDictionary *)preparedArray[n];
            if ( [self isDictionaryAComponent:component] )
            {
                preparedArray[n] = [self componentByAddingIDToComponent:component];
            }
            else
            {
                preparedArray[n] = [self preparedConfigurationWithUnpreparedDictionary:component];
            }
        }
        else if ( [preparedArray[n] isKindOfClass:[NSArray class]] )
        {
            preparedArray[n] = [self preparedArrayWithUnpreparedArray:preparedArray[n]];
        }
    }
    return [preparedArray copy];
}

- (NSDictionary *)componentByAddingIDToComponent:(NSDictionary *)component
{
    if ( ![self componentHasID:component] )
    {
        NSMutableDictionary *preparedComponent = [component mutableCopy];
        preparedComponent[VDependencyManagerIDKey] = [[NSUUID UUID] UUIDString];
        return preparedComponent;
    }
    else
    {
        return component;
    }
}

- (UIImage *)imageWithTemplateImage:(VTemplateImage *)templateImage
{
    if ( templateImage.imageURL != nil &&
        templateImage.imageURL.scheme.length > 0 &&
        [[VTemplatePackageManager validSchemes] containsObject:templateImage.imageURL.scheme] )
    {
        NSData *imageData = [[[VDataCache alloc] init] cachedDataForID:templateImage.imageURL];
        
        if ( imageData == nil )
        {
            return nil;
        }
        
        if ( templateImage.scale == nil )
        {
            return [UIImage imageWithData:imageData];
        }
        else
        {
            return [[UIImage alloc] initWithData:imageData scale:[templateImage.scale VCGFLOAT_VALUE]];
        }
    }
    NSString *imageName = templateImage.imageURL.absoluteString;
    if ( [imageName isEqualToString:@"splash"] )
    {
        imageName = @"launchImage";
    }
    
    return [UIImage imageNamed:imageName];
}

- (BOOL)isDictionaryAComponent:(NSDictionary *)possibleComponent
{
    return possibleComponent[kClassNameKey] != nil;
}

- (BOOL)componentHasID:(NSDictionary *)component
{
    return component[VDependencyManagerIDKey] != nil;
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
