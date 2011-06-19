//
//  CalculatorTests.m
//  CalculatorTests
//
//  Created by Tyler Perkins on 2011-04-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorTests.h"

@interface CalculatorTests ()
- (void) pushButtonWithTitle:(NSString*)txt;
@end
NSDictionary* newDictOfButtonsByTitleInView( UIView* view );


@implementation CalculatorTests


- (void)setUp {
    [super setUp];
    
    // Set-up code here.

    //  Create a new view controller and all its associated objects and
    //  connections as defined in the XIB. Note that this process is not
    //  complete until the XIB is loaded when the view is accessed below.
    calculatorViewController = [
      [CalculatorViewController alloc]
        initWithNibName:@"CalculatorViewController" bundle:nil
    ];

    //  Button dict. Also, accessing calculatorViewController.view forces
    //  loading the CalculatorViewController.xib and initializing outlets.
    buttons = newDictOfButtonsByTitleInView( calculatorViewController.view );

    defaults = [[NSUserDefaults standardUserDefaults] retain];
    clearAppDefaults(defaults);
}


- (void)tearDown {
    // Tear-down code here.

    [defaults release];
    [buttons release];
    [calculatorViewController release];
    [super tearDown];
}


#pragma mark - Tests

/*  Test that user defaults are empty initially.
*/
- (void) test$Setup {
    STAssertFalse(
        [defaults boolForKey:defaultKey(HaveSavedValues)],
        @"The default object used for testing must start out clean."
    );

    [defaults setBool:YES forKey:defaultKey(HaveSavedValues)];
    [defaults setObject:@"TEST" forKey:defaultKey(Typing)];

    STAssertTrue(
        [defaults boolForKey:defaultKey(HaveSavedValues)],
        @"The default object should store a BOOL value."
    );
    STAssertEqualObjects(
        [defaults stringForKey:defaultKey(Typing)],
        @"TEST",
        @"The default object should store a NSString value."
    );

    //  Clear out those Calculator defaults set above.
    clearAppDefaults(defaults);

    STAssertFalse(
        [defaults boolForKey:defaultKey(HaveSavedValues)],
        @"The default object should be cleared."
    );
    STAssertNil(
        [defaults stringForKey:defaultKey(Typing)],
        @"The default object should be cleared."
    );
    STAssertNil(
        [defaults stringForKey:defaultKey(ExpressionPlist)],
        @"The default object used for testing must start out clean."
    );
}


/*  Test entry '3'. CalculatorBrain should automatically add '='.
    Test that state in the middle of an numerical calculation is saved to
    user defaults.
*/
- (void) testConstant {
    CGFloat (^f)(CGFloat);

    [self pushButtonWithTitle:@"3"];

    [calculatorViewController saveToUserDefaults:defaults];
    STAssertTrue(
        [defaults boolForKey:defaultKey(HaveSavedValues)],
        @"User defaults should know we have saved values."
    );
    STAssertEqualObjects(
        [defaults stringForKey:defaultKey(Typing)],
        @"3",
        @"Defaults should contain typing display value."
    );

    [self pushButtonWithTitle:@"Sto"];
    [self pushButtonWithTitle:@"="];

    f = [calculatorViewController functionOfX];
    STAssertEquals( f(-1.0), (CGFloat)3.0, @"operation 3" );
    STAssertEquals( f( 0.0), (CGFloat)3.0, @"operation 3" );
    STAssertEquals( f( 1.0), (CGFloat)3.0, @"operation 3" );

    //  Test recovery using restoreFromDefaults:.

    [self pushButtonWithTitle:@"+"];
    [self pushButtonWithTitle:@"1"];
    
    [calculatorViewController saveToUserDefaults:defaults];
    [calculatorViewController clearPressed];
    [calculatorViewController restoreFromUserDefaults:defaults];

    STAssertEqualObjects(
        calculatorViewController.display.text,
        @"1",
        @"Entered digit should be restored."
    );

    [self pushButtonWithTitle:@"6"];

    STAssertEqualObjects(
        calculatorViewController.display.text,
        @"16",
        @"Entering digits should continue."
    );

    [self pushButtonWithTitle:@"sqrt"];

    STAssertEqualObjects(
        calculatorViewController.display.text,
        @"4",
        @"Sqrt should operate on complete number."
    );

    [self pushButtonWithTitle:@"="];

    STAssertEqualObjects(
        calculatorViewController.display.text,
        @"7",
        @"Restoring from user defaults should recover '+' operatation."
    );

    [self pushButtonWithTitle:@"Rcl"];
    
    STAssertEqualObjects(
        calculatorViewController.display.text,
        @"3",
        @"Rcl should obtain stored number."
    );
}


/*  Test entry 'x 1/x =', including that 1/0 should return an error.
*/
- (void) test1OverX {
    CGFloat (^f)(CGFloat);

    [self pushButtonWithTitle:@"x"];
    [self pushButtonWithTitle:@"1/x"];
    [self pushButtonWithTitle:@"="];
    f = [calculatorViewController functionOfX];
    STAssertEquals( f(1.0), (CGFloat)1.0, @"operation 1/x" );
    STAssertTrue( isnan( f(0.0) ), @"'0 1/x' should be NAN" );
    STAssertEquals( f(2.0), (CGFloat)0.5, @"operation 1/x" );
}


/*  Test entry 'x sqrt =', including that sqrt(-1) should return an error.
*/
- (void) testSqrtX {
    CGFloat (^f)(CGFloat);

    [self pushButtonWithTitle:@"x"];
    [self pushButtonWithTitle:@"sqrt"];
    [self pushButtonWithTitle:@"="];
    f = [calculatorViewController functionOfX];
    STAssertEquals( f(9.0), (CGFloat)3.0, @"operation sqrt" );
    STAssertTrue( isnan( f(-1.0) ), @"'-1 sqrt' should be NAN" );
    STAssertEquals( f(0.0), (CGFloat)0.0, @"operation sqrt" );
}


/*  Test entry 'x sin * = Sto x cos * = + Rcl = sqrt', which is function
    sqrt( cos(x)^2 + sin(x)^2 ).
*/
- (void) testUnitRadius {
    CGFloat (^f)(CGFloat);

    [self pushButtonWithTitle:@"x"];
    [self pushButtonWithTitle:@"sin"];
    [self pushButtonWithTitle:@"*"];
    [self pushButtonWithTitle:@"="];
    [self pushButtonWithTitle:@"Sto"];
    [self pushButtonWithTitle:@"x"];
    [self pushButtonWithTitle:@"cos"];
    [self pushButtonWithTitle:@"*"];

    //  Simulate quitting and restarting in the middle of entering expression.
    [calculatorViewController saveToUserDefaults:defaults];
    [calculatorViewController clearPressed];
    [calculatorViewController restoreFromUserDefaults:defaults];

    [self pushButtonWithTitle:@"="];
    [self pushButtonWithTitle:@"+"];
    [self pushButtonWithTitle:@"Rcl"];
    [self pushButtonWithTitle:@"="];
    [self pushButtonWithTitle:@"sqrt"];
    f = [calculatorViewController functionOfX];

    STAssertEqualsWithAccuracy( f(-1.0), (CGFloat)1.0, 0.0001, @"at -1.0" );
    STAssertEqualsWithAccuracy( f(0.0),  (CGFloat)1.0, 0.0001, @"at 0.0" );
    STAssertEqualsWithAccuracy( f(3.14), (CGFloat)1.0, 0.0001, @"at ~ PI" );
}


- (void) testBinaryWithUnary {
    CGFloat (^f)(CGFloat);

    [self pushButtonWithTitle:@"x"];
    [self pushButtonWithTitle:@"*"];
    [self pushButtonWithTitle:@"1"];
    [self pushButtonWithTitle:@"sqrt"];
    [self pushButtonWithTitle:@"="];
    STAssertTrue(
        [calculatorViewController.display.text
            isEqual:@" x * 1 sqrt ="
        ],
        @"display string"
    );
    f = [calculatorViewController functionOfX];
    STAssertEquals( f(0.0), (CGFloat)0.0, @" x * 1 sqrt" );
    STAssertEquals( f(1.0), (CGFloat)1.0, @" x * 1 sqrt" );
    STAssertEquals( f(2.0), (CGFloat)2.0, @" x * 1 sqrt" );
}


#pragma mark - Private methods and functions


NSDictionary* newDictOfButtonsByTitleInView( UIView* view ) {
    NSMutableDictionary* dict = [NSMutableDictionary new];
    for ( UIView* subView in view.subviews ) {
        if ( [subView isKindOfClass:[UIButton class]] ) {
            [dict setValue:subView forKey:((UIButton*)subView).currentTitle];
        }
    }
    return dict;
}


- (void) pushButtonWithTitle:(NSString*)txt {
    [[buttons objectForKey:txt]
        sendActionsForControlEvents:UIControlEventTouchUpInside
    ];
}


@end
