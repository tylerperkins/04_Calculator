//
//  GraphView.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-05-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

void plot(
    CGContextRef context,
    CGFloat      (^f)(CGFloat),
    CGFloat      xStart,
    int          numSteps,
    CGFloat      scale
);


@implementation GraphView


@synthesize delegate, widthScaled;


- (void)awakeFromNib {
    widthScaled = 10.0;
}


- (void)drawRect:(CGRect)rect {

    CGFloat axesThicknessInPoints = 1.0;
    CGFloat plotThicknessInPoints = 2.0;
    CGPoint originNotScaled       =
        CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);

    int viewWidthInPixels         = round(
        self.bounds.size.width * self.contentScaleFactor
    );
    CGFloat scale                 = viewWidthInPixels/widthScaled;

    CGContextRef context = UIGraphicsGetCurrentContext();

    //  Draw the axes with labels BEFORE we change the CTM below. Class
    //  AxesDrawer (provided by Stanford for use in this homework) does not
    //  consult the CTM to determine the distance between hash marks.
    //  (AxesDrawer could be greatly improved, IMHO.)
    //
    [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.33] set];
    CGContextSetLineWidth( context, axesThicknessInPoints );
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:originNotScaled
                         scale:scale
    ];

    //  Change the Current Transform Matrix to show the origin in the middle
    //  of the view with y increasing upward.
    //
    CGContextTranslateCTM( context, originNotScaled.x, originNotScaled.y );
    CGContextScaleCTM( context, scale, -scale );

    //  Plot from -widthScaled/2 to widthScaled/2, one data point per pixel.
    [[UIColor blackColor] set];
    CGContextSetLineWidth( context, plotThicknessInPoints/scale );
    plot(
        context,
        [delegate functionOfX],
        -widthScaled/2.0,
        viewWidthInPixels,
        scale
    );
}


- (void) setWidthScaled:(CGFloat)newWidthScaled {
    widthScaled = newWidthScaled;
    [self setNeedsDisplay];
}


#pragma mark - Private methods and functions


/*  In the given context, draws the given function of CGFloat -> CGFloat.
*/
void plot(
    CGContextRef context,
    CGFloat      (^f)(CGFloat),  // Block calculating f(x).
    CGFloat      xStart,         // Leftmost x value.
    int          numSteps,       // Number of data points - 1.
    CGFloat      scale           // Pixels per unit.
) {
    BOOL lastFxWasNAN = YES;     // So we just move, not draw to (xStart,fx).

    CGContextBeginPath(context);

    for ( int i = 0; i <= numSteps; i++) {
        CGFloat x  = xStart + i/scale;
        CGFloat y = f(x);
        BOOL thisFxWasNAN = isnan(y);
        
        if ( ! thisFxWasNAN ) {
            //  We got a valid value for f(x). If the last one was not valid,
            //  just MOVE to the new coords. Othewise, DRAW LINE to the coords.
            (lastFxWasNAN ? CGContextMoveToPoint : CGContextAddLineToPoint)(
                context, x, y
            );
        }
        //  Note that if we didn't get a valid value for f(x), we drew nothing
        //  and now just continue to the next x value.
        
        lastFxWasNAN = thisFxWasNAN;
    }

	CGContextStrokePath(context);
}


@end
