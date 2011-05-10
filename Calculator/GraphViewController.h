//
//  GraphViewController.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-04-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface GraphViewController : UIViewController <GraphDataDelegate> {
}
@property (nonatomic,retain) IBOutlet GraphView*            graphView;
@property (assign)           IBOutlet id<GraphDataDelegate> delegate;

- (IBAction) zoomIn;
- (IBAction) zoomOut;
- (CGFloat (^)(CGFloat)) functionOfX;  // Impl. protocol GraphDataDelegate.

@end
