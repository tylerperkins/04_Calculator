//
//  UIView+DrawHelp.m
//  Calculator
//
//  Created by Tyler Perkins on 2011-05-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+DrawHelp.h"


@implementation UIView (UIView_DrawHelp)


/*  Calculates the factor by which line width changes as a result of a
    change in coordinate system defined by the CGAffineTransform, trans.
    When scale in the X dimension differs from that in the Y dimension,
    this will depend on the slope of the line. This is given by the
    endpoints of the line p1 and p2.
*/
CGFloat lineWidthScale( CGPoint p1, CGPoint p2, CGAffineTransform trans ) {
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
