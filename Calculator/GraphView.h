//
//  GraphView.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-05-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+DrawHelp.h"

@protocol GraphDataDelegate <NSObject>
- (CGFloat (^)(CGFloat)) functionOfX;
@end

@interface GraphView : UIView {}

//  We don't need to retain the delegate, because we're sure this GraphView
//  will be released before the delegate is, which is the GraphViewController.
@property (assign,nonatomic) IBOutlet id<GraphDataDelegate> delegate;

//  Note that we don't retain these CGAffineTransforms because they are not
//  pointers. They are just the numerical state of the GraphView instance.
@property (assign,nonatomic) CGAffineTransform coordSys;
@property (assign,nonatomic) CGAffineTransform coordSysInverse;

- (CGAffineTransform) initialCoordSys;
- (CGAffineTransform) translateToMiddle;
- (CGAffineTransform) dilationAtMiddleWithScaleX:(CGFloat)scaleX
                                               y:(CGFloat)scaleY;

@end
