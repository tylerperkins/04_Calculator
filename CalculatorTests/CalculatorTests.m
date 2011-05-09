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
}


- (void)tearDown {
    // Tear-down code here.

    [buttons release];
    [calculatorViewController release];
    [super tearDown];
}


#pragma mark - Tests


/*  Test entry '3'. CalculatorBrain should automatically add '='.
*/
- (void) testConstant {
    CGFloat (^f)(CGFloat);

    [self pushButtonWithTitle:@"3"];
    f = [calculatorViewController functionOfX];
    STAssertEquals( f(-1.0), (CGFloat)3.0, @"operation 3" );
    STAssertEquals( f( 0.0), (CGFloat)3.0, @"operation 3" );
    STAssertEquals( f( 1.0), (CGFloat)3.0, @"operation 3" );
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
    [self pushButtonWithTitle:@"="];
    [self pushButtonWithTitle:@"+"];
    [self pushButtonWithTitle:@"Rcl"];
    [self pushButtonWithTitle:@"="];
    [self pushButtonWithTitle:@"sqrt"];
    STAssertTrue(
        [calculatorViewController.display.text
            isEqual:@" x sin * = Sto x cos * = + Rcl = sqrt"
        ],  //        ^-- Note leading space.
        @"display string"
    );
    f = [calculatorViewController functionOfX];
    STAssertEqualsWithAccuracy( f(-1.0), (CGFloat)1.0, 0.0001, @"at -1.0" );
    STAssertEqualsWithAccuracy( f(0.0),  (CGFloat)1.0, 0.0001, @"at 0.0" );
    STAssertEqualsWithAccuracy( f(3.14), (CGFloat)1.0, 0.0001, @"at ~ PI" );
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
