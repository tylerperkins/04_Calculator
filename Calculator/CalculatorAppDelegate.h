//
//  CalculatorAppDelegate.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-03-31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorViewController.h"

@interface CalculatorAppDelegate : NSObject <UIApplicationDelegate> {}
@property (nonatomic,retain) IBOutlet UIWindow* window;
@property (nonatomic,retain) IBOutlet CalculatorViewController*calculatorViewController;

@end
