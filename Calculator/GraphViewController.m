//
//  GraphViewController.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-04-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"


@interface GraphViewController ()
@property (retain,nonatomic) CGFloat (^cachedFunctionOfX)(CGFloat);
@end


@implementation GraphViewController


@synthesize graphView, delegate, cachedFunctionOfX;


- (void) dealloc {
    self.graphView = nil;
    self.cachedFunctionOfX = nil;
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    self.cachedFunctionOfX = nil;
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle


- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void) viewDidUnload {
    self.graphView = nil;
    self.cachedFunctionOfX = nil;
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    self.cachedFunctionOfX = nil;
    [self.graphView setNeedsDisplay];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)ornt {
    return YES;
}


- (CGFloat (^)(CGFloat)) functionOfX {
    if ( ! self.cachedFunctionOfX ) {
        self.cachedFunctionOfX = [delegate functionOfX];
    }
    return  self.cachedFunctionOfX;
}


- (IBAction) zoomIn {
    graphView.widthScaled /= 1.5;
}


- (IBAction) zoomOut {
    graphView.widthScaled *= 1.5;
}


@end
