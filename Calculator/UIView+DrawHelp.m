//
//  UIView+DrawHelp.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-05-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*  This catagory holds functions and methods helpful to UIView classes in
    drawing their contents.
*/

#import "UIView+DrawHelp.h"


@implementation UIView (UIView_DrawHelp)


/*  Calculates the factor by which line width changes as a result of a
    change in coordinate system defined by the CGAffineTransform, trans.
    When scale in the X dimension differs from that in the Y dimension,
    change in line width will depend on the slope of the line, which is
    given by endpoints p1 and p2. These must be distinct or an
    IllegalArgument exception will be thrown. The given transform must
    describe only scaling and translation, i.e., its b and c entries must
    both be zero. Using a transform containing any rotation will result in
    an IllegalArgument exception.
*/
CGFloat lineWidthScale( CGPoint p1, CGPoint p2, CGAffineTransform trans ) {
    if ( p1.x == p2.x && p1.y == p2.y ) {
        [NSException raise:@"IllegalArgument"
                    format:@"CGPoints must be distinct (%g,%g).", p1.x, p1.y
        ];
    }
    if ( trans.b || trans.c ) {
        [NSException raise:@"IllegalArgument"
                    format:@"Given CGAffineTransform must consist only of scaling and translation."
        ];
    }
    CGFloat dX  = p2.x - p1.x;
    CGFloat dX2 = dX*dX;
    CGFloat dY  = p2.y - p1.y;
    CGFloat dY2 = dY*dY;
    CGFloat scaleX2 = trans.a * trans.a;
    CGFloat scaleY2 = trans.d * trans.d;

    return  sqrt( (dX2 + dY2)*scaleX2*scaleY2 / (dX2*scaleX2 + dY2*scaleY2) );
}


@end
