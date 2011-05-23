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

CGFloat lineWidthScale( CGPoint p1, CGPoint p2, CGAffineTransform trans );

@interface GraphView : UIView {
}
@property (assign,nonatomic) IBOutlet id<GraphDataDelegate> delegate;
@property (assign,nonatomic)          CGFloat               widthScaled;
@property (assign,nonatomic)          CGPoint               originNotScaled;

@end
