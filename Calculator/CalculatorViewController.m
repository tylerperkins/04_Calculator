//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-03-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*  This view controller manages the calculator's buttons and display. It
    hands off calculation to model CalculatorBrain, and graphical display
    to GraphViewController. It conforms to protocol GraphDataDelegate, so
    it knows how to wrap the current numerical state of an expression of
    one variable, and provide it to the GraphViewController as an anonymous
    function. It also handles the distinct requirements of iPad and iPhone.
*/

#import "CalculatorViewController.h"

/*  Private method interfaces. Here, a nameless class extension (like a
    category declaration) is used just to declare the private methods.
*/
@interface CalculatorViewController ()  // (Could've named it, but unneces.)
@property (assign,nonatomic) BOOL      userIsInTheMiddleOfTypingANumber;
@property (copy,nonatomic)   NSString* operandToSubmit;
- (void) reset;
- (void) show:(NSString*)str;
- (void) showResult;
- (void) drawRightView;
- (void) releaseGUIOutlets;
@end


@implementation CalculatorViewController


@synthesize
    display,
    equalsButton,
    brain,
    graphViewController,
    operandToSubmit,
    userIsInTheMiddleOfTypingANumber;


- (void) dealloc {
    [self releaseGUIOutlets];
    [brain release];
    [operandToSubmit release];
    [super dealloc];
}


#pragma mark - View lifecycle


- (void) viewDidLoad {
    //  In case we're in a UISplitViewController, we define the size of the
    //  popover that displays when the user touches the left bar button.
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
}


- (void) viewDidUnload {
    [self releaseGUIOutlets];
    [super viewDidUnload];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)ornt {
    return YES;
}


#pragma mark - Actions


- (IBAction) digitPressed:(UIButton*)bttn {
    NSString* digit = bttn.currentTitle;

	if ( self.userIsInTheMiddleOfTypingANumber ) {
        NSString* oldText = display.text;
        //  Remove a leading "0", preserving "-", if present.
        if      ( [oldText isEqualToString:@"0" ] )  oldText = @"";
        else if ( [oldText isEqualToString:@"-0"] )  oldText = @"-";

        [self show:[oldText stringByAppendingString:digit]];

    } else {
        [self show:digit];
        self.userIsInTheMiddleOfTypingANumber = YES;
    }
}


- (IBAction) decimalPointPressed:(UIButton*)bttn {
	if ( self.userIsInTheMiddleOfTypingANumber ) {
        //  Check to see if a decimal point has already been entered.
        NSString* ptStr = bttn.currentTitle;
        if ( [display.text rangeOfString:ptStr].length == 0 ) {
            [self show:[display.text stringByAppendingString:ptStr]];
        }
    } else {
        //  New number. Prefix with "0.".
        [self show:@"0."];
        self.userIsInTheMiddleOfTypingANumber = YES;
    }
}


- (IBAction)variablePressed:(UIButton*)sender {
    [self show:sender.titleLabel.text];
    self.userIsInTheMiddleOfTypingANumber = NO;
}


- (IBAction) negatePressed:(UIButton*)bttn {

    if ( self.userIsInTheMiddleOfTypingANumber ) {
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


- (IBAction) graphPressed {
    //  Ensure the expression is terminated by '='.
    if ( ! [brain.expression isComplete] ) {
        [self equalsPressed:equalsButton];
    }
    
    if ( self.splitViewController ) {
        [self drawRightView];
    } else {
        [self.navigationController pushViewController:self.graphViewController
                                             animated:YES
        ];
    }
}


#pragma mark - Implmentation of protocol GraphDataDelegate


/*  Create a new anonymous function (a block) that takes one CGFloat variable
    and returns a CGFloat. It calculates the expression entered by the user
    where the variable is "x".
*/
- (CGFloat (^)(CGFloat)) functionOfX {
    //  Note that these objects must be autoreleased, since references to
    //  them are kept by the returned block, which itself is autoreleased.
    //
    id plist                     =
      [CalculatorBrain propertyListForExpression:brain.expression];
    num memoryWhenFuncCreated    = self.brain.memory;
    CalculatorBrain* brn         = [[CalculatorBrain alloc] autorelease];
    NSMutableDictionary* binding =
      [NSMutableDictionary dictionaryWithCapacity:1];

    return [[^(CGFloat x){
        [binding setValue:[NSString stringWithFormat:@"%g", x]
                   forKey:@"x"
        ];
        [brn init];
        brn.memory = memoryWhenFuncCreated;
        [CalculatorBrain runPlist:plist inBrain:brn withBindings:binding];
        return [brn.expression hasVariables] ? NAN : brn.result;

    } copy] autorelease];
}


#pragma mark - Implmentation of protocol SavesAndRestoresDefaults


/*  This is the central method for saving the user defaults for
    the entire application.
*/
- (void) saveToUserDefaults:(NSUserDefaults*)defaults {
    clearAppDefaults(defaults);

    if ( userIsInTheMiddleOfTypingANumber ) {
        [defaults setObject:display.text forKey:defaultKey(Typing)];
    }

    [self.brain saveToUserDefaults:defaults];

    [graphViewController saveToUserDefaults:defaults];

    [defaults setBool:YES forKey:defaultKey(HaveSavedValues)];
}


/*  This is the central method for restoring the user defaults for
    the entire application.
*/
- (void) restoreFromUserDefaults:(NSUserDefaults*)defaults {
    if ( [defaults boolForKey:defaultKey( HaveSavedValues )] ) {

        [graphViewController restoreFromUserDefaults:defaults];

        [self.brain restoreFromUserDefaults:defaults];

        NSString* typing = [defaults stringForKey:defaultKey(Typing)];
        if ( typing )  [self show:typing];
        else           [self showResult];
        self.userIsInTheMiddleOfTypingANumber = ( typing != nil );

        if ( self.splitViewController )  [self drawRightView];
    }
}


#pragma mark - Private methods


/*  Sets this instance to its original state.
*/
- (void) reset {
    //  Initialize, but don't mess with outlets.
    [self show:@"0"];
    self.userIsInTheMiddleOfTypingANumber = NO;
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

    self.userIsInTheMiddleOfTypingANumber = NO;
}


- (void) drawRightView {
    self.graphViewController.navigationItem.title = display.text;
    [self.graphViewController viewWillAppear:NO];  // (NO animation.)
}


- (void) releaseGUIOutlets {
    [display release];
    [equalsButton release];
    [graphViewController release];
}


@end
