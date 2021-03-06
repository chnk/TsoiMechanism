//
//  ModeViewController.m
//  TsoiMechanism
//
//  Created by Brennan Maddox on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModeViewController.h"

@implementation ModeViewController

@synthesize problemView, problemNumberLabel, scoreLabel, instructionsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        problemView = [[ProblemView alloc] init];
        score = 0;
        problemNumber = 1;
    }
    return self;
}

-(void) goToNextProblem
{
    if (problemNumber < MAX_PROBLEMS) {
        [problemView showNextProblem];
        problemNumber++;
        [problemNumberLabel setText:[NSString stringWithFormat:@"%i/%i", problemNumber, MAX_PROBLEMS]];
    }
}

-(void) addScore:(int) amount
{
    score += amount;
    [scoreLabel setText:[NSString stringWithFormat:@"Score: %i", score]];
}

-(void) removeScore:(int) amount
{
    score -= amount;
    [scoreLabel setText:[NSString stringWithFormat:@"Score: %i", score]];
}

-(IBAction) exitView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(void) dealloc {
    [problemView release];
    [super dealloc];
}

@end
