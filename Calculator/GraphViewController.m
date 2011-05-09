//
//  GraphViewController.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-04-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"


@implementation GraphViewController


@synthesize graphView, delegate;


- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) dealloc {
    self.graphView = nil;
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void) viewDidUnload {
    self.graphView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.graphView setNeedsDisplay];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)ornt {
    // Return YES for supported orientations
    return  ornt == UIInterfaceOrientationPortrait;
}


- (CGFloat (^)(CGFloat)) functionOfX {
    return [delegate functionOfX];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.graphView;
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.graphView setNeedsDisplay];
}


@end
