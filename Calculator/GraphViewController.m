//
//  GraphViewController.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-04-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"

//  self.view is actually a GraphView, assigned in GraphViewController.xib.
#define SELF_VIEW ((GraphView*)self.view)

@interface GraphViewController ()
@property (retain,nonatomic) CGFloat (^cachedFunctionOfX)(CGFloat);
- (void) addRecognizerOfClass:(Class)recogClass forSEL:(SEL)sel;
@end


@implementation GraphViewController


@synthesize delegate, cachedFunctionOfX;


- (void) dealloc {
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
    self.cachedFunctionOfX = nil;
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    self.cachedFunctionOfX = nil;
    [SELF_VIEW setNeedsDisplay];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)ornt {
    return YES;
}


#pragma mark - Gesture handlers


- (void) handlePan:(UIPanGestureRecognizer*)recog {
    if (
        recog.state == UIGestureRecognizerStateChanged  ||
        recog.state == UIGestureRecognizerStateEnded
    ) {
        //  Note any change in translation.
        CGPoint moved = [recog translationInView:SELF_VIEW];
        SELF_VIEW.originNotScaled = CGPointMake(
            SELF_VIEW.originNotScaled.x + moved.x,
            SELF_VIEW.originNotScaled.y + moved.y
        );

        //  Reset translation to (0,0) so we'll see only the change next time.
        [recog setTranslation:CGPointZero inView:SELF_VIEW];
    }
}


- (void) handlePinch:(UIPinchGestureRecognizer*)recog {
    if (
        recog.state == UIGestureRecognizerStateChanged  ||
        recog.state == UIGestureRecognizerStateEnded
    ) {
        //  Note any change in scale.
        SELF_VIEW.widthScaled /= [recog scale];

        //  Reset scale to 1 so we'll see only the change next time.
        recog.scale = 1.0;
    }
}


#pragma mark - Implmentation of protocol GraphDataDelegate


- (CGFloat (^)(CGFloat)) functionOfX {
    if ( ! self.cachedFunctionOfX ) {
        self.cachedFunctionOfX = [delegate functionOfX];
    }
    return  self.cachedFunctionOfX;
}



#pragma mark - Implmentation of protocol UISplitViewControllerDelegate


- (void) splitViewController:(UISplitViewController*) svc
      willHideViewController:(UINavigationController*)leftNavController
           withBarButtonItem:(UIBarButtonItem*)       barButtonItem
        forPopoverController:(UIPopoverController*)   pc
{
    barButtonItem.title =
        leftNavController.topViewController.navigationItem.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void) splitViewController:(UISplitViewController*)svc
      willShowViewController:(UIViewController*)     calcViewController
   invalidatingBarButtonItem:(UIBarButtonItem*)      barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Private methods


- (void) addRecognizerOfClass:(Class)recogClass forSEL:(SEL)sel {
    UIGestureRecognizer* recog = [[recogClass alloc]
        initWithTarget:self action:sel
    ];
    [SELF_VIEW addGestureRecognizer:recog];
    [recog release];
}


@end
