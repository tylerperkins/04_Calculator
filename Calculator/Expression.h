//
//  Expression.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-04-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SavesAndRestoresDefaults.h"

#define PREV_RESULT_SYMBOL @"use_previous_result"

typedef double num;

@interface Expression : NSObject {
    NSMutableArray* plist;
    NSMutableSet* variables;
}

@property (readonly,nonatomic) NSArray* plist;
@property (readonly,nonatomic) NSSet* variables;

- (id) init;

- (id) initWithPlist:(NSArray*)plist;

- (void) appendSELStr:(NSString*)selStr 
           operandStr:(NSString*)oprnd
                glyph:(NSString*)glyph;

- (BOOL) hasVariables;

- (BOOL) isComplete;

- (NSString*) description;

+ (BOOL) isNumString:(NSString*)str;

+ (num) makeNumFromString:(NSString*)str;

@end
