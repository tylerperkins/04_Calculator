//
//  GraphView.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-05-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GraphDataDelegate <NSObject>
- (CGFloat (^)(CGFloat)) functionOfX;
@end

@interface GraphView : UIView {
}
@property (assign) IBOutlet id<GraphDataDelegate> delegate;

@end
