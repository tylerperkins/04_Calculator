//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-03-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorBrain.h"

@interface CalculatorViewController : UIViewController {
    IBOutlet UILabel*         display;
    IBOutlet CalculatorBrain* brain;
    IBOutlet UIButton*        solveButton;

    NSString* operandToSubmit;
    BOOL userIsInTheMiddleOfTypingANumber;
}

- (IBAction) digitPressed:(UIButton*)sender;

- (IBAction) decimalPointPressed:(UIButton*)sender;

- (IBAction) negatePressed:(UIButton*)sender;

- (IBAction) equalsPressed:(UIButton*)sender;

- (IBAction) plusPressed:(UIButton*)sender;

- (IBAction) minusPressed:(UIButton*)sender;

- (IBAction) timesPressed:(UIButton*)sender;

- (IBAction) dividedByPressed:(UIButton*)sender;

- (IBAction) sqrtPressed:(UIButton*)sender;

- (IBAction) sinPressed:(UIButton*)sender;

- (IBAction) cosPressed:(UIButton*)sender;

- (IBAction) recipPressed:(UIButton*)sender;

- (IBAction) recallPressed:(UIButton*)sender;

- (IBAction) storePressed:(UIButton*)sender;

- (IBAction) storePlusPressed:(UIButton*)sender;

- (IBAction) variablePressed:(UIButton*)sender;

- (IBAction) clearPressed;

- (IBAction) solvePressed;

@end
