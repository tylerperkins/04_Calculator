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
    <GraphDataDelegate, UISplitViewControllerDelegate>
{}
@property (retain,nonatomic) IBOutlet id<GraphDataDelegate> delegate;

- (CGFloat (^)(CGFloat)) functionOfX;  // Implements proto. GraphDataDelegate.

@end
