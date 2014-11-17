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

// Keys for colors
NSString * const VDependencyManagerBackgroundColorKey = @"color.background";
NSString * const VDependencyManagerSecondaryBackgroundColorKey = @"color.bacground.secondary";
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
static NSString * const kClassNameKey = @"name";
static NSString * const kFontNameKey = @"fontName";
static NSString * const kFontSizeKey = @"fontSize";

// Keys for experiments
NSString * const VDependencyManagerHistogramEnabledKey = @"experiments.histogram_enabled";
NSString * const VDependencyManagerProfileImageRequiredKey = @"experiments.require_profile_image";

// Keys for view controllers
NSString * const VDependencyManagerScaffoldViewControllerKey = @"scaffold";

@interface VDependencyManager ()

@property (nonatomic, strong) VDependencyManager *parentManager;
@property (nonatomic, strong) NSDictionary *configuration;
@property (nonatomic, copy) NSDictionary *classesByTemplateName;
@property (nonatomic) dispatch_queue_t privateQueue;

@end

@implementation VDependencyManager

- (instancetype)initWithParentManager:(VDependencyManager *)parentManager configuration:(NSDictionary *)configuration dictionaryOfClassesByTemplateName:(NSDictionary *)classesByTemplateName
{
    self = [super init];
    if (self)
    {
        _parentManager = parentManager;
        _configuration = configuration;
        _privateQueue = dispatch_queue_create("VDependencyManager private queue", DISPATCH_QUEUE_SERIAL);
        
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
    
    UIColor *color = [UIColor colorWithRed:[red CGFLOAT_VALUE] green:[green CGFLOAT_VALUE] blue:[blue CGFLOAT_VALUE] alpha:[alpha CGFLOAT_VALUE]];
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

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    return [self templateValueOfType:[UIViewController class] forKey:key];
}

- (NSArray *)arrayForKey:(NSString *)key
{
    return [self templateValueOfType:[NSArray class] forKey:key];
}

#pragma mark - Dependency getter primatives

- (id)templateValueOfType:(Class)expectedType forKey:(NSString *)keyPath
{
    id value = [self.configuration valueForKeyPath:keyPath];
    
    if (value == nil)
    {
        return [self.parentManager templateValueOfType:expectedType forKey:keyPath];
    }
    
    if ([value isKindOfClass:expectedType])
    {
        return value;
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        return [self objectOfClass:expectedType fromDictionary:value];
    }
    
    return nil;
}

- (id)objectOfClass:(Class)expectedClass fromDictionary:(NSDictionary *)configurationDictionary
{
    Class templateClass = [self classWithTemplateName:configurationDictionary[kClassNameKey]];
    
    if ([templateClass isSubclassOfClass:expectedClass])
    {
        id object;
        VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:self
                                                                                    configuration:configurationDictionary
                                                                dictionaryOfClassesByTemplateName:self.classesByTemplateName];
        
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
        }
        return object;
    }
    return nil;
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
