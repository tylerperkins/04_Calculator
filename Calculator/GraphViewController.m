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
- (void) addRecognizerOfClass:(Class)recogClass forSEL:(SEL)sel;
@end


@implementation GraphViewController


@synthesize graphView, delegate, cachedFunctionOfX;


- (void) dealloc {
    [graphView release];
    [cachedFunctionOfX release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    self.cachedFunctionOfX = nil;
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle


- (void) viewDidLoad {
    [super viewDidLoad];

    [self addRecognizerOfClass:[UIPanGestureRecognizer class]
                        forSEL:@selector(handlePan:)
    ];
    [self addRecognizerOfClass:[UIPinchGestureRecognizer class]
                        forSEL:@selector(handlePinch:)
    ];
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


- (void) handlePan:(UIPanGestureRecognizer*)recog {
    if (
        recog.state == UIGestureRecognizerStateChanged  ||
        recog.state == UIGestureRecognizerStateEnded
    ) {
        //  Note any change in translation.
        CGPoint moved = [recog translationInView:graphView];
        graphView.originNotScaled = CGPointMake(
            graphView.originNotScaled.x + moved.x,
            graphView.originNotScaled.y + moved.y
        );

        //  Reset translation to (0,0) so we'll see only the change next time.
        [recog setTranslation:CGPointZero inView:graphView];
    }
}


- (void) handlePinch:(UIPinchGestureRecognizer*)recog {
    if (
        recog.state == UIGestureRecognizerStateChanged  ||
        recog.state == UIGestureRecognizerStateEnded
    ) {
        //  Note any change in scale.
        graphView.widthScaled /= [recog scale];

        //  Reset scale to 1 so we'll see only the change next time.
        recog.scale = 1.0;
    }
}


#pragma mark - Private methods


- (void) addRecognizerOfClass:(Class)recogClass forSEL:(SEL)sel {
    UIGestureRecognizer* recog = [[recogClass alloc]
        initWithTarget:self action:sel
    ];
    [self.view addGestureRecognizer:recog];
    [recog release];
}


@end
