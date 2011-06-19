//
//  GraphViewController.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-04-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*  This view controller manages the display of a plot of a particular function
    of one variable in its GraphView. It conforms to protocol
    GraphDataDelegate and thus provides a function to plot to its GraphView.
    The function is cached when obtained from another GraphDataDelegate, the
    CalculatorViewController. This class also conforms to
    UISplitViewControllerDelegate, so handles the shift in the center of the
    view when the use changes from portrait to landscape mode, or vice versa.
*/

#import "GraphViewController.h"

//  self.view is actually a GraphView, assigned in GraphViewController.xib.
#define SELF_VIEW ((GraphView*)self.view)

@interface GraphViewController ()
@property (retain,nonatomic) CGFloat (^cachedFunctionOfX)(CGFloat);
@property (assign,nonatomic) CGSize  sizeBeforeRotation;
@end


@implementation GraphViewController


@synthesize delegate, cachedFunctionOfX, sizeBeforeRotation;


- (void) dealloc {
    [delegate release];
    [cachedFunctionOfX release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    self.cachedFunctionOfX = nil;
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle


- (void) viewDidUnload {
    self.cachedFunctionOfX = nil;
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    //  Force retrieval of the function from CalculatorViewController.
    self.cachedFunctionOfX = nil;

    //  We'll need these view dimensions when user changes device orientation.
    self.sizeBeforeRotation = SELF_VIEW.bounds.size;

    //  Function or split view may have changed. Re-plot.
    [SELF_VIEW setNeedsDisplay];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)ornt {
    return YES;
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)ornt {
    if (
        UIInterfaceOrientationIsLandscape(self.interfaceOrientation) !=
            UIInterfaceOrientationIsLandscape(ornt)
        &&                       // Check that the view has laid-out bounds.
        [SELF_VIEW hasCoordSys]  // This won't be the case on startup.
    ) {
        //  User changed from a portrait orientation (possibly upside-down)
        //  to a landscape orientation (pointed left or right), or vice
        //  versa. Calculate the displacement of the middle of the view in
        //  points.
        CGFloat shiftX = (
            SELF_VIEW.bounds.size.width - self.sizeBeforeRotation.width
        )/2.0;
        CGFloat shiftY = (
            SELF_VIEW.bounds.size.height - self.sizeBeforeRotation.height
        )/2.0;

        //  Modify the view's coordSys by composing it to a translation of
        //  the amount of the displacement.
        SELF_VIEW.coordSys = CGAffineTransformConcat(
            SELF_VIEW.coordSys,
            CGAffineTransformMakeTranslation(shiftX, shiftY)
        );

        //  Save dimensions for the next call.
        self.sizeBeforeRotation = SELF_VIEW.bounds.size;
    }
}


#pragma mark - Implmentation of protocol GraphDataDelegate


- (CGFloat (^)(CGFloat)) functionOfX {
    //  Just used cached function, if possible.
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
    //  User rotated device to portrait mode.

    //  Use the title on the right nav. controller for button's title.
    barButtonItem.title =
        leftNavController.topViewController.navigationItem.title;

    //  Set the right nav. controller's left bar button to be the given one.
    self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void) splitViewController:(UISplitViewController*)svc
      willShowViewController:(UIViewController*)     calcViewController
   invalidatingBarButtonItem:(UIBarButtonItem*)      barButtonItem
{
    //  User rotated device to landscape mode.

    //  Remove the button item of the right nav. controller.
    self.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Implmentation of protocol SavesAndRestoresDefaults


- (void) saveToUserDefaults:(NSUserDefaults*)defaults {
    [(GraphView*)self.view saveToUserDefaults:defaults];
}


- (void) restoreFromUserDefaults:(NSUserDefaults*)defaults {
    [(GraphView*)self.view restoreFromUserDefaults:defaults];
}


@end
