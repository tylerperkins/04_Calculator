//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-03-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Expression.h"

typedef num (^unaryOperation )(num);
typedef num (^binaryOperation)(num,num);

@interface CalculatorBrain : NSObject {
    num             operand1;
    num             memory;
    binaryOperation pendingOp;
}
@property (readonly,nonatomic) num         result;
@property (readonly,nonatomic) Expression* expression;

- (void) negateOperand:   (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) identityOperand: (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) plusOperand:     (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) minusOperand:    (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) timesOperand:    (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) divOperand:      (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) sqrtOperand:     (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) sinOperand:      (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) cosOperand:      (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) recipOperand:    (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) recallOperand:   (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) storeOperand:    (NSString*)oprnd  glyph:(NSString*)glyph;

- (void) storePlusOperand:(NSString*)oprnd  glyph:(NSString*)glyph;

+ (void) runPlist:(id)pl
          inBrain:(CalculatorBrain*)brain
     withBindings:(NSDictionary*)bindings;

+ (NSSet*) variablesInExpression:(Expression*)expr;

+ (NSString*) descriptionOfExpression:(Expression*)expr;

+ (id) propertyListForExpression:(Expression*)expr;

+ (id) expressionForPropertyList:(id)pList;

@end
