//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-03-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*  This is the model for the Calculator application. It does the actual
    calculation. It is also responsible for recording expressions containing
    variables and later evaluating them.
*/

#import "CalculatorBrain.h"
#import <math.h>

NSString* variableValue( NSString* txt, NSDictionary* bindings );

@interface CalculatorBrain ()
- (void) doOperand:(NSString*)oprnd
           unaryOp:(unaryOperation)op
            caller:(NSString*)selStr
             glyph:(NSString*)glyph;
- (void) doOperand:(NSString*)oprnd
          binaryOp:(binaryOperation)op
            caller:(NSString*)selStr
             glyph:(NSString*)glyph;
@end


@implementation CalculatorBrain


@synthesize memory, result, expression;


/*  Initializes this instance to the state of the user having already tapped
    the "0" and "+" buttons. (This just makes a valid state for the first
    call to doOperand:binaryOp:.) It is safe to call this method more than
    once.
*/
- (id) init {
    id obj = [super init];
    if ( obj ) {
        operand1 = 0.0;
        result = 0.0;
        memory = 0.0;
        //  This dummy operation ensures correct state the first time a
        //  binary operation is evaluated.
        pendingOp = ^(num o1, num o2){ return o1 + o2; };
        if ( ! expression )  expression = [Expression alloc];
        [expression init];
    }
    return obj;
}


- (void) dealloc {
    [expression release];
    [super dealloc];
}


#pragma mark - Operators


- (void) negateOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
            unaryOp:^(num o2){ return -o2; }
             caller:@"negateOperand:glyph:"
              glyph:glyph
     ];
}


- (void) identityOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
           binaryOp:^(num o1, num o2){ return o2; }
             caller:@"identityOperand:glyph:"
              glyph:glyph
    ];
}


- (void) plusOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
           binaryOp:^(num o1, num o2){ return o1 + o2; }
             caller:@"plusOperand:glyph:"
              glyph:glyph
    ];
}


- (void) minusOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
           binaryOp:^(num o1, num o2){ return o1 - o2; }
             caller:@"minusOperand:glyph:"
              glyph:glyph
    ];
}


- (void) timesOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
           binaryOp:^(num o1, num o2){ return o1 * o2; }
             caller:@"timesOperand:glyph:"
              glyph:glyph
    ];
}


- (void) divOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
           binaryOp:^(num o1, num o2){ return o1 / o2; }
             caller:@"divOperand:glyph:"
              glyph:glyph
    ];
}


- (void) sqrtOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
            unaryOp:^(num o2){ return sqrt(o2); }
             caller:@"sqrtOperand:glyph:"
              glyph:glyph
    ];
}


- (void) sinOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
            unaryOp:^(num o2){ return sin(o2); }
             caller:@"sinOperand:glyph:"
              glyph:glyph
    ];
}


- (void) cosOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
            unaryOp:^(num o2){ return cos(o2); }
             caller:@"cosOperand:glyph:"
              glyph:glyph
    ];
}


- (void) recipOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
            unaryOp:^(num o2){ return 1.0 / o2; }
             caller:@"recipOperand:glyph:"
              glyph:glyph
    ];
}


- (void) recallOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
            unaryOp:^(num o2){ return self.memory; }
             caller:@"recallOperand:glyph:"
              glyph:glyph
    ];
}


- (void) storeOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
            unaryOp:^(num o2){ return self.memory = o2; }
             caller:@"storeOperand:glyph:"
              glyph:glyph
    ];
}


- (void) storePlusOperand:(NSString*)oprnd glyph:(NSString*)glyph {
    [self doOperand:oprnd
            unaryOp:^(num o2){
                self.memory += o2;
                return o2;
            }
             caller:@"storePlusOperand:glyph:"
              glyph:glyph
    ];
}


#pragma mark - Implmentation of protocol SavesAndRestoresDefaults


- (void) saveToUserDefaults:(NSUserDefaults*)defaults {
    [defaults setObject:expression.plist forKey:defaultKey(ExpressionPlist)];
    [defaults setDouble:self.memory forKey:defaultKey(BrainMemory)];
}


- (void) restoreFromUserDefaults:(NSUserDefaults*)defaults {
    [self init];
    self.memory = [defaults doubleForKey:defaultKey(BrainMemory)];
    [CalculatorBrain
         runPlist:[defaults objectForKey:defaultKey(ExpressionPlist)]
          inBrain:self
     withBindings:nil
    ];
    //  Note that variableValue(...) is defined so that nil bindings
    //  results in no substitution of variables being done.
}


#pragma mark - Private methods and functions


- (void) doOperand:(NSString*)oprnd
           unaryOp:(unaryOperation)op
            caller:(NSString*)selStr
             glyph:(NSString*)glyph
{
    if ( ! [Expression isNumString:oprnd] || [expression hasVariables] ) {
        //  User just entered a variable, or did sometime in the history
        //  of this expression. Just save the args. in existing expr.
        
        [expression appendSELStr:selStr operandStr:oprnd glyph:glyph];
        
    } else {
        //  Calculate now.
        result = op([Expression makeNumFromString:oprnd]);
    }
}


- (void) doOperand:(NSString*)oprnd
          binaryOp:(binaryOperation)op
            caller:(NSString*)selStr
             glyph:(NSString*)glyph
{
    if ( ! [Expression isNumString:oprnd] || [self.expression hasVariables] ) {
        //  User just entered a variable, or did sometime in the history
        //  of this expression. Just save the args. in existing expr.

        [self.expression appendSELStr:selStr operandStr:oprnd glyph:glyph];

    } else {

        //  Perform waiting calculation and save pending operand and operation.
        result = pendingOp( operand1, [Expression makeNumFromString:oprnd] );

        operand1 = result;           // In case we need result in next calc.
        pendingOp = op;              // Need to wait for the second operand.

        //  Record the result from the above calculation in expression, along
        //  with the new waiting operation. The resulting expression will be
        //  needed if the user next enters a variable.
        [[self.expression init]
            appendSELStr:selStr
              operandStr:[NSString stringWithFormat:@"%g", result]
                   glyph:glyph
        ];
    }
}


/*  Checks bindings for a key matching txt. If present, the associated value
    is returned. Otherwise, txt is returned.
*/
NSString* variableValue( NSString* txt, NSDictionary* bindings ) {
    NSString* value = [bindings objectForKey:txt];
    return  value ? value : txt; 
}


#pragma mark - Class methods


+ (void) runPlist:(id)pl
          inBrain:(CalculatorBrain*)brain
     withBindings:(NSDictionary*)bindings
{
    NSString* oprnd;

    for ( NSArray* arr in pl ) {

        //  If the operand in arr is a variable with a binding, replace it.
        //  If oprnd is PREV_RESULT_SYMBOL and brain has no variables so far,
        //  then replace it with a string of the num the brain has calculated
        //  so far.
        //
        oprnd = variableValue( [arr objectAtIndex:1], bindings );
        if ( [oprnd isEqualToString:PREV_RESULT_SYMBOL] &&
             ! [brain.expression hasVariables]
        ) {
            oprnd = [NSString stringWithFormat:@"%g",brain.result];
        }

        [brain performSelector:NSSelectorFromString([arr objectAtIndex:0])
                    withObject:oprnd
                    withObject:[arr objectAtIndex:2]
        ];
    }
}


+ (NSSet*) variablesInExpression:(Expression*)expr {
    return expr.variables;
}


+ (NSString*) descriptionOfExpression:(Expression*)expr {
    return [expr description];
}


+ (id) propertyListForExpression:(Expression*)expr {
    return expr.plist;
}


+ (id) expressionForPropertyList:(id)pl {
    Expression* expr = [[Expression alloc] initWithPlist:pl];
    return [expr autorelease];
}


@end
