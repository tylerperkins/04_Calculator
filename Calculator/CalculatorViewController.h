//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Tyler Perkins on 2011-03-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController : UIViewController <GraphDataDelegate> {
    BOOL userIsInTheMiddleOfTypingANumber;
}
@property (nonatomic,retain) IBOutlet UILabel*             display;
@property (nonatomic,retain) IBOutlet UIButton*            equalsButton;
@property (nonatomic,retain) IBOutlet CalculatorBrain*     brain;
@property (nonatomic,retain) IBOutlet GraphViewController* graphViewController;

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

- (IBAction) graphPressed;

@end
