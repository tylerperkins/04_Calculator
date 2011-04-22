//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-03-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"

/*  Private method interfaces. Here, a nameless class extension (like a
    category declaration) is used just to declare the private methods.
*/
@interface CalculatorViewController ()  // (Could've named it, but unneces.)
@property (retain,nonatomic) NSString* operandToSubmit;
- (void) reset;
- (void) show:(NSString*)str;
- (void) showResult;
+ (void) button:(UIButton*)btn setEnabled:(BOOL)state;
@end


@implementation CalculatorViewController


@synthesize operandToSubmit;


- (id) init {
    //  Initialize, but don't mess with outlets. This provides a convenient
    //  way to reset the calculator to its original state.
    
    id obj = [super init];
    if ( obj ) {
        [self reset];
    }
    return obj;
}


- (void)dealloc
{
    [display release];
    [brain release];
    [solveButton release];
    [operandToSubmit release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


- (void) viewDidLoad {
    [CalculatorViewController button:solveButton setEnabled:NO]; 
}


- (void) viewDidUnload
{
    [display release];
    display = nil;
    [solveButton release];
    solveButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Actions


- (IBAction) digitPressed:(UIButton*)bttn {
    NSString* digit = bttn.currentTitle;

	if ( userIsInTheMiddleOfTypingANumber ) {
        NSString* oldText = display.text;
        //  Remove a leading "0", preserving "-", if present.
        if      ( [oldText isEqualToString:@"0" ] )  oldText = @"";
        else if ( [oldText isEqualToString:@"-0"] )  oldText = @"-";

        [self show:[oldText stringByAppendingString:digit]];

    } else {
        [self show:digit];
        userIsInTheMiddleOfTypingANumber = YES;
    }
}


- (IBAction) decimalPointPressed:(UIButton*)bttn {
	if ( userIsInTheMiddleOfTypingANumber ) {
        //  Check to see if a decimal point has already been entered.
        NSString* ptStr = bttn.currentTitle;
        if ( [display.text rangeOfString:ptStr].length == 0 ) {
            [self show:[display.text stringByAppendingString:ptStr]];
        }
    } else {
        //  New number. Prefix with "0.".
        [self show:@"0."];
        userIsInTheMiddleOfTypingANumber = YES;
    }
}


- (IBAction)variablePressed:(UIButton*)sender {
    [self show:sender.titleLabel.text];
    userIsInTheMiddleOfTypingANumber = NO;
}

- (IBAction) negatePressed:(UIButton*)bttn {

    if ( userIsInTheMiddleOfTypingANumber ) {
        //  Just prepend a "-" to entered string if not already present,
        //  or remove it if it is present.

        NSString* minusSignStr = @"-";
        NSString* oldText = display.text;
        
        [self show:(
            [oldText hasPrefix:minusSignStr]
            ?   [oldText substringFromIndex:[minusSignStr length]]
            :   [minusSignStr stringByAppendingString:oldText]
        )];

    } else {
        //  A number has already been entered or calculated. Apply the
        //  unary "negate" operation to change its sign.

        [brain negateOperand:operandToSubmit glyph:bttn.currentTitle];
        [self showResult];
    }
}


- (IBAction) equalsPressed:(UIButton*)bttn {
    [brain identityOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction) plusPressed:(UIButton*)bttn {
    [brain plusOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction) minusPressed:(UIButton*)bttn {
    [brain minusOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction) timesPressed:(UIButton*)bttn {
    [brain timesOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction) dividedByPressed:(UIButton*)bttn {
    [brain divOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction) sqrtPressed:(UIButton*)bttn {
    [brain sqrtOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction) sinPressed:(UIButton*)bttn {
    [brain sinOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction) cosPressed:(UIButton*)bttn {
    [brain cosOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction)recipPressed:(UIButton*)bttn {
    [brain recipOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction)recallPressed:(UIButton*)bttn {
    [brain recallOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction)storePressed:(UIButton*)bttn {
    [brain storeOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction)storePlusPressed:(UIButton*)bttn {
    [brain storePlusOperand:operandToSubmit glyph:bttn.currentTitle];
    [self showResult];
}


- (IBAction)clearPressed {
    [brain init];
    [self reset];
}



- (IBAction) solvePressed {
    NSDictionary* testDict =
      [NSDictionary dictionaryWithObjectsAndKeys:
          @"1.1", @"x",
          @"2.2", @"a",
          @"3.3", @"b",
          nil
      ];

    /*  Uncomment the following to test CalculatorBrain class methods.

    NSLog(
        @"\n-- Variables: %@",
        [CalculatorBrain variablesInExpression:brain.expression]
    );

    NSLog(
        @"\n-- Solution is %g",
        [CalculatorBrain evaluateExpression:brain.expression
                        usingVariableValues:testDict
        ]
    );
    */

    id plist = [CalculatorBrain propertyListForExpression:brain.expression];
    [self clearPressed];   // TODO Useful instead to NOT clear STO memory?
    [CalculatorBrain runPlist:plist inBrain:brain withBindings:testDict];
    [self showResult];
}


#pragma mark - Private methods


/*  Sets this instance to its original state.
*/
- (void) reset {
    [self show:@"0"];
    userIsInTheMiddleOfTypingANumber = NO;
    [CalculatorViewController button:solveButton setEnabled:NO];
}


- (void) show:(NSString*)str {
    display.text = self.operandToSubmit = str;
}


/*  Show the brain's current result in UILabel display, and switch mode
    to flag that the user is not currently entering a number. If the brain's
    expression has variables, display the whole expression.
*/
- (void) showResult {

    if ( [brain.expression hasVariables] ) {

        //  We have at least one variable, so we can solve. Only enable
        //  solveButton if the last operation was "=". Otherwise it would be
        //  enabled after the first operation following a variable button.
        //  This would be confusing for the user, since the state of the
        //  "solution" won't reflect the last pending operation, unless she
        //  types "=" after "solve".
        [CalculatorViewController button:solveButton
                              setEnabled:[brain.expression isComplete]
        ];

        //  User has entered a symbolic expression, so just show its textual
        //  representation instead of a numerical result.
        display.text = [brain.expression description];

        //  In case user just hits an operation button without first entering
        //  a number or variable, set the default value, a symbol indicating
        //  that an evaluation should use the value calculated thus far.
        self.operandToSubmit = PREV_RESULT_SYMBOL;

    } else {
        //  Just numbers have been calculated. Display the numerical result.
        [self show:[NSString stringWithFormat:@"%g", brain.result]];
    }

    userIsInTheMiddleOfTypingANumber = NO;
}


+ (void) button:(UIButton*)btn setEnabled:(BOOL)yorn {
    btn.enabled = yorn;
    btn.alpha =  yorn ? 1.0 : 0.5;
}


@end
