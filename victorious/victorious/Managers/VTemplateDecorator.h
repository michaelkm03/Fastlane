//
//  VTemplateDecorator.h
//  victorious
//
//  Created by Patrick Lynch on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTemplateDecorator : NSObject

- (instancetype)initWithTemplateDictionary:(NSDictionary *)templateDictionary NS_DESIGNATED_INITIALIZER;

- (NSDictionary *)dictionaryFromJSONFile:(NSString *)filename;

- (BOOL)concatonateTemplateWithFilename:(NSString *)filename;

- (BOOL)setComponentForKeyPath:(NSString *)keyPath withComponentInFileNamed:(NSString *)filename;

@property (nonatomic, readonly) NSDictionary *decoratedTemplate;

@end
