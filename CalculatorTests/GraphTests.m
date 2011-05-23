//
//  GraphTests.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-05-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphTests.h"


@implementation GraphTests


- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}


- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}


#pragma mark - Tests


- (void) testLineWidthScale {
    CGAffineTransform trans = CGAffineTransformMakeScale(1.0, 1.0);
    CGPoint p1 = CGPointMake(0.0, 0.0);
    CGPoint p2 = CGPointMake(1.0, 0.0);
    STAssertEquals(
        lineWidthScale(p1, p2, trans), 
        (CGFloat)1.0,
        @"Identity tranform should give no change in linewidth scale"
    );
    p2 = CGPointMake(0.0, 1.0);
    STAssertEquals(
        lineWidthScale(p1, p2, trans), 
        (CGFloat)1.0,
        @"Identity tranform should give no change in linewidth scale"
    );
    
    trans = CGAffineTransformMakeScale(2.0, 0.5);
    p1 = CGPointMake(1.0, 1.0);
    p2 = CGPointMake(2.0, 1.0);
    STAssertEquals(
        lineWidthScale(p1, p2, trans), 
        (CGFloat)0.5,
        @"Horizontal linewidth should scale as Y-dimension."
    );
    p2 = CGPointMake(1.0, 2.0);
    STAssertEquals(
        lineWidthScale(p1, p2, trans), 
        (CGFloat)2.0,
        @"Vertical linewidth should scale as X-dimension."
    );
    p2 = CGPointMake(2.0, 2.0);
    STAssertEqualsWithAccuracy(
        lineWidthScale(p1, p2, trans),
        (CGFloat)0.6860,
        (CGFloat)0.0001,
        @"Diagonal linewidth should scale using both X and Y scales."
    );
    trans = CGAffineTransformMakeScale(2.0, 2.0);
    STAssertEquals(
        lineWidthScale(p1, p2, trans),
        (CGFloat)2.0,
        @"Diag. linewidth should scale the same when X & Y scales are equal."
    );
    p1 = CGPointMake(0.0, 0.0);
    p2 = CGPointMake(4.0, 1.0);
    trans = CGAffineTransformMakeScale(1.0, 4.0);
    STAssertEqualsWithAccuracy(
        lineWidthScale(p1, p2, trans),
        (CGFloat)2.9155,
        (CGFloat)0.0001,
        @"Diagonal linewidth should scale using both X and Y scales."
    );
}


@end
