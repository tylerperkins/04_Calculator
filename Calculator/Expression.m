//
//  Expression.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-04-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Expression.h"

@implementation Expression

/*  Implementation of readonly property plist. Returns an immutable copy of
    the plist array used internally.
*/
- (NSArray*) plist {
    return [NSArray arrayWithArray:plist];
}


/*  Implementation of readonly property variables. Returns an immutable copy
    of the variables set used internally.
*/
- (NSSet*) variables {
    return [NSSet setWithSet:variables];
}


/*  Resets this expression to be empty. It is safe to call this more than once.
*/
- (id) init {
    self = [super init];
    if ( self ) {
        if ( plist )  [plist removeAllObjects];
        else          plist = [NSMutableArray new];   
        if ( variables )  [variables removeAllObjects];
        else              variables = [NSMutableSet new];   
    }
    return self;
}


- (id) initWithPlist:(NSArray*)pl {
    self = [self init];
    for (NSArray* arr in pl) {
        [self appendSELStr:[arr objectAtIndex:0]
                operandStr:[arr objectAtIndex:1]
                     glyph:[arr objectAtIndex:2]
        ];
    }
    return self;
}


- (void) appendSELStr:(NSString*)selStr
           operandStr:(NSString*)oprnd
                glyph:(NSString*)glyph
{
    if ( ! [Expression isNumString:oprnd]  &&
         ! [oprnd isEqualToString:PREV_RESULT_SYMBOL]
    ) {
        [variables addObject:oprnd];
    }
    NSArray* args = [NSArray arrayWithObjects: selStr, oprnd, glyph, nil];
    [plist addObject:args];
}


/*  Returns YES iff this expression contains at least one variable.
*/
- (BOOL) hasVariables {
    return  [variables count] != 0;
}


/* Return YES iff this expression is ready to be solved. This means it
   ends with the "=" operation.
*/
- (BOOL) isComplete {
    return [
        [[plist lastObject] objectAtIndex:0] isEqual:@"identityOperand:glyph:"
    ];
}


/*  Returns string like @"3.14 * x + 1 =" representing this Expression.
*/
- (NSString*) description {
    NSMutableString* mutStr = [NSMutableString
        stringWithCapacity:[plist count]*5    // Rough est. of size needed.
    ];

    //  Write each operand-glyph pair, unless oprnd is PREV_RESULT_SYMBOL,
    //  then just write the glyph. Separate with spaces appropriately.
    //
    for ( NSArray* arr in plist ) {
        NSString* oprnd = [arr objectAtIndex:1];
        if ( ! [oprnd isEqualToString:PREV_RESULT_SYMBOL] ) {
            [mutStr appendString:@" "];
            [mutStr appendString:oprnd];              // The operand.
        }
        [mutStr appendString:@" "];
        [mutStr appendString:[arr objectAtIndex:2]];  // The glyph.
    }

    return mutStr;
}


- (void)dealloc {
    [plist release];
    [variables release];
    [super dealloc];
}


#pragma mark - Class methods


+ (BOOL) isNumString:(NSString*)str {
    NSRange rng =
        [str rangeOfString:@"-?\\d+.?\\d*[eE]?[+-]?\\d*"
                   options:NSRegularExpressionSearch
        ];
    //  Note: Instead of the above, it's more correct to use a regex like
    //  @"-?\\d+.?\\d*([eE][+-]?\d+)?", since the exponent portion is either
    //  there in its entirity or not. For example, the string @"1e-" would
    //  satisfy the above. However, groupings don't appear to be supported
    //  by rangeOfString:options:. Alternatively, we could have used class
    //  NSRegularExpression, but perhaps that would be overkill for this use.

    return  rng.location == 0  &&  rng.length == [str length];
}


+ (num) makeNumFromString:(NSString*)str {
    return [str doubleValue];
}


@end
