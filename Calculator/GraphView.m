//
//  GraphView.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-05-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*  When drawn, an instance of this view class plots a CGFloat-valued function
    of one CGFloat variable, which it obtains from its GraphDataDelegate
    instance. The function's domain, determined by the initialCoordSys method,
    is [-5, 5] by default. The plot is scaled to just fit within the bounds of
    this view, with the vertical scale the same as the horizontal scale. The
    user can adjust the domain and range using touch gestures. This class
    handles panning, scaling/zooming (by pinching), jumping back to the origin
    (by double-tapping), and and jumping back to the origin at the default
    scale (by tripple-tapping).
*/

#import "GraphView.h"
#import "AxesDrawer.h"

static const CGFloat AxesThicknessInPoints = 1.0;
static const CGFloat PlotThicknessInPoints = 2.0;

@interface GraphView ()
@property (assign,nonatomic) BOOL hasCoordSys;
- (UIGestureRecognizer*) addRecognizerOfClass:(Class)recogClass
                                       forSEL:(SEL)sel;
- (void) handlePan:(UIPanGestureRecognizer*)recog;
- (void) handlePinch:(UIPinchGestureRecognizer*)recog;
- (void) handle2Taps:(UIPinchGestureRecognizer*)recog;
- (void) handle3Taps:(UIPinchGestureRecognizer*)recog;
- (void) plotFunction:(CGFloat (^)(CGFloat))f inContext:(CGContextRef)context;
@end


@implementation GraphView


@synthesize delegate, coordSys, coordSysInverse, hasCoordSys;


- (void)awakeFromNib {
    //  Force setNeedsDisplay to be called whenever the reciever's bounds
    //  are changed.
    self.contentMode = UIViewContentModeRedraw;

    //  Add the gesture recognizers, which call the receiver's handlers,
    //  defined below.
    //
    [self addRecognizerOfClass:[UIPanGestureRecognizer class]
                        forSEL:@selector(handlePan:)
    ];
    [self addRecognizerOfClass:[UIPinchGestureRecognizer class]
                        forSEL:@selector(handlePinch:)
    ];
    (   (UITapGestureRecognizer*)[self
            addRecognizerOfClass:[UITapGestureRecognizer class]
                          forSEL:@selector(handle2Taps:)
        ]
    ).numberOfTapsRequired = 2;
    (   (UITapGestureRecognizer*)[self
            addRecognizerOfClass:[UITapGestureRecognizer class]
                          forSEL:@selector(handle3Taps:)
        ]
    ).numberOfTapsRequired = 3;
}


- (void) drawRect:(CGRect)rect {
    if ( ! self.hasCoordSys ) {
        //  First time here, so we must initialize coordSys.
        self.coordSys = [self initialCoordSys];
        self.hasCoordSys = YES;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();

    //  Draw the axes with labels BEFORE we change the CTM below. Class
    //  AxesDrawer (provided by Stanford for use in this homework) does not
    //  consult the CTM to determine the distance between hash marks.
    //  (AxesDrawer could be greatly improved, IMHO.)
    //
    [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.33] set];
    CGContextSetLineWidth( context, AxesThicknessInPoints );
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:CGPointApplyAffineTransform(
                                   CGPointZero, self.coordSys
                               )
                         scale:self.coordSys.a
    ];

    //  Draw the plot of the function.
    //
    [[UIColor blackColor] set];
    [self plotFunction:[delegate functionOfX] inContext:context];
}


/*  Assigns the coordSys property, caching its inverse too. Also ensures
    that the plot will be redrawn.
*/
- (void) setCoordSys:(CGAffineTransform)newTransform {
    coordSys = newTransform;
    coordSysInverse = CGAffineTransformInvert(coordSys);
    [self setNeedsDisplay];
}


/*  Returns an affine transformation whose domain and range are in coordSys
    coordinates and that calculates the displacement of its argument from the
    middle of the view. The "middle" is the same location on the screen as
    given by UIView's center property, but, like the domain of the returned
    transformation, it is in the coordinate system defined by the receiver's
    coordSys property.
*/
- (CGAffineTransform) translateToMiddle {
    CGPoint userOrigin = CGPointApplyAffineTransform(
        CGPointMake( self.bounds.size.width/2.0, self.bounds.size.height/2.0 ),
        self.coordSysInverse
    );
    return  CGAffineTransformMakeTranslation(
        userOrigin.x, userOrigin.y
    );
}


/*  Returns an affine transformation whose domain and range are in coordSys
    coordinates and that zooms in or out on the middle of the view, NOT the
    origin.
*/
- (CGAffineTransform) dilationAtMiddleWithScaleX:(CGFloat)scaleX
                                               y:(CGFloat)scaleY
{ 
    CGAffineTransform toMiddle = [self translateToMiddle];

    //  First translate to the middle, then scale, then translate back.
    return  CGAffineTransformConcat(
        CGAffineTransformInvert( toMiddle ),
        CGAffineTransformConcat(
            CGAffineTransformMakeScale(scaleX, scaleY),
            toMiddle
        )
    );
}


#pragma mark - Gesture handlers


- (void) handlePan:(UIPanGestureRecognizer*)recog {
    if (
        recog.state == UIGestureRecognizerStateChanged  ||
        recog.state == UIGestureRecognizerStateEnded
    ) {
        CGPoint moved = [recog translationInView:self];
        
        //  Modify coordSys by shifting its result.
        self.coordSys = CGAffineTransformConcat(
            self.coordSys,
            CGAffineTransformMakeTranslation(moved.x, moved.y)
        );
        
        //  Reset translation to (0,0) so we'll see only the change next time.
        [recog setTranslation:CGPointZero inView:self];
    }
}


- (void) handlePinch:(UIPinchGestureRecognizer*)recog {
    if (
        recog.state == UIGestureRecognizerStateChanged  ||
        recog.state == UIGestureRecognizerStateEnded
    ) {
        //  Apply a possibly off-center dilation as input to coordSys.
        self.coordSys = CGAffineTransformConcat(
            [self dilationAtMiddleWithScaleX:recog.scale y:recog.scale],
            self.coordSys
        );
        
        //  Reset scale to 1 so we'll see only the change next time.
        recog.scale = 1.0;
    }
}


- (void) handle2Taps:(UIPinchGestureRecognizer*)recog {
    if (
        recog.state == UIGestureRecognizerStateChanged  ||
        recog.state == UIGestureRecognizerStateEnded
    ) {
        CGAffineTransform toMiddle = [self translateToMiddle];
        
        //  Change view's coordSys to one whose origin is at the middle
        //  of the view.
        self.coordSys = CGAffineTransformConcat( toMiddle, self.coordSys );
    }
}


- (void) handle3Taps:(UIPinchGestureRecognizer*)recog {
    if (
        recog.state == UIGestureRecognizerStateChanged  ||
        recog.state == UIGestureRecognizerStateEnded
    ) {
        //  Change the view's coordSys back to the original one.
        self.coordSys = [self initialCoordSys];
    }
}


#pragma mark - Private methods and functions


/*  Generates the affine transformation initially used for drawing, until the
    user uses a gesture to pan or pinch the screen. The returned transformation
    is scaled to show a graph from x == -5 to x == 5. Its y-scale defaults to
    be the same as the x-scale.
*/
- (CGAffineTransform) initialCoordSys {
    CGFloat scale = self.bounds.size.width/10.0;  // Points per unit.

    return  CGAffineTransformConcat(
        CGAffineTransformMakeScale(scale, -scale),
        CGAffineTransformMakeTranslation(
            self.bounds.size.width/2.0, self.bounds.size.height/2.0
        )
    );
}


- (UIGestureRecognizer*) addRecognizerOfClass:(Class)recogClass
                                       forSEL:(SEL)sel
{
    UIGestureRecognizer* recog = [[recogClass alloc]
        initWithTarget:self action:sel
    ];
    [self addGestureRecognizer:recog];
    [recog autorelease];
    return recog;
}


- (void) plotFunction:(CGFloat (^)(CGFloat))f inContext:(CGContextRef)context {    

    int viewWidthInPixels = round(
        self.bounds.size.width * self.contentScaleFactor
    );
    CGFloat xStart = CGPointApplyAffineTransform(
        self.bounds.origin, self.coordSysInverse
    ).x;
    CGFloat xIncr = CGSizeApplyAffineTransform(
        CGSizeMake(1.0, 0.0), self.coordSysInverse
    ).width;

    BOOL lastYWasNAN = YES;     // We just move, not draw to (xStart,y).

    //  Essentially make self.coordSys the current one.
    CGContextConcatCTM(context, self.coordSys);

    CGContextBeginPath(context);
    for ( int i = 0; i <= viewWidthInPixels; i++ ) {
        CGFloat x  = xStart + i*xIncr;
        CGPoint thisPoint = CGPointMake(x, f(x));
        BOOL thisYWasNAN = isnan( thisPoint.y );
        if ( ! thisYWasNAN ) {
            //  We got a valid value for f(x). If the last one was not valid,
            //  just MOVE to the new coords. Othewise, DRAW LINE to the coords.

            if ( lastYWasNAN ) {
                //  Previous f(x) was invalid, so draw nothing. Just move to
                //  the current good point and continue to the next x value.
                CGContextMoveToPoint( context, thisPoint.x, thisPoint.y );

            } else {
                //  Set the line width for the context, i.e., the entire path.
                CGContextSetLineWidth(
                    context,
                    PlotThicknessInPoints/lineWidthScale(
                        CGContextGetPathCurrentPoint(context),
                        thisPoint,
                        self.coordSys
                    )
                );

                //  Previous f(x) was valid, and so is the current one.
                //  So draw a line between them.
                CGContextAddLineToPoint( context, thisPoint.x, thisPoint.y );
                
                //  Draw the entire path with above line width. It contains
                //  just a single line segment, but maybe many moves.
                CGContextStrokePath(context);

                //  Start a new path for next line segment, which might have
                //  a different line width.
                CGContextBeginPath(context);
                CGContextMoveToPoint( context, thisPoint.x, thisPoint.y );
            }
        }
        lastYWasNAN = thisYWasNAN;
    }
	CGContextStrokePath(context);
}


@end
