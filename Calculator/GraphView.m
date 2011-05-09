//
//  GraphView.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-05-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"


@implementation GraphView


@synthesize delegate;


- (void)dealloc {
    [super dealloc];
}


- (void)drawRect:(CGRect)rect {

    CGFloat widthScaled           = 10.0;
    CGFloat axesThicknessInPixels = 1.0;
    CGFloat plotThicknessInPixels = 2.0;
    CGPoint originNotScaled       =
        CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);

    int boundsWidthInPixels       = round(
        self.bounds.size.width * self.contentScaleFactor
    );
    CGFloat scale                 = boundsWidthInPixels/widthScaled;

    CGContextRef context = UIGraphicsGetCurrentContext();

    //  Draw the axes with labels BEFORE we change the CTM below. Class
    //  AxesDrawer (provided by Stanford for use in this homework) does not
    //  consult the CTM to determine the distance between hash marks.
    //  (AxesDrawer could be greatly improved, IMHO.)
    //
    [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.33] set];
    CGContextSetLineWidth(
        context,
        axesThicknessInPixels/self.contentScaleFactor
    );
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:originNotScaled
                         scale:scale
    ];

    //  Change the Current Transform Matrix to show the origin in the middle
    //  of the view with y increasing upward.
    //
    CGContextTranslateCTM( context, originNotScaled.x, originNotScaled.y );
    CGContextScaleCTM( context, scale, -scale );

    //  Obtain the function to plot from the delegate.
    CGFloat (^f)(CGFloat) = [delegate functionOfX];

    //  Plot from -widthScaled/2 to widthScaled/2, one data point per pixel.

    CGFloat xStart = -widthScaled/2.0;
    BOOL lastFxWasNAN = YES;       // So we just move, not draw to (xStart,fx).

    [[UIColor blackColor] set];
    CGContextSetLineWidth( context, plotThicknessInPixels/scale );
    CGContextBeginPath(context);
    for ( int i = 0; i <= boundsWidthInPixels; i++) {
        CGFloat x  = xStart + i/scale;
        CGFloat fx = f(x);
        BOOL thisFxWasNAN = isnan(fx);

        if ( ! thisFxWasNAN ) {
            //  We got a valid value for f(x). If the last one was not valid,
            //  just MOVE to the new coords. Othewise, DRAW LINE to the coords.
            (lastFxWasNAN ? CGContextMoveToPoint : CGContextAddLineToPoint)(
                context, x, fx
            );
        }
        //  Note that if we didn't get a valid f(x), we did nothing and now
        //  just continue to the next x value.

        lastFxWasNAN = thisFxWasNAN;
    }
	CGContextStrokePath(context);
}


@end
