//
//  GraphViewController.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-04-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface GraphViewController : UIViewController
    <GraphDataDelegate, UIScrollViewDelegate>
{    
}
@property (nonatomic,retain) IBOutlet UIView*               graphView;
@property (assign)           IBOutlet id<GraphDataDelegate> delegate;

//  Implements protocol GraphDataDelegate.
- (CGFloat (^)(CGFloat)) functionOfX;

//  Optional methods of protocol UIScrollViewDelegate for scrolling & zooming.
- (UIView *) viewForZoomingInScrollView:(UIScrollView*)scrollView;
- (void) scrollViewDidScroll:(UIScrollView *)scrollView;

@end
