//
//  SplashViewController.m
//  iTennis
//
//  Created by Brandon Trebitowski on 3/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"


@implementation SplashViewController

@synthesize timer,splashImageView,viewController;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// Init the view
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *view = [[UIView alloc] initWithFrame:appFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.view = view;
	[view release];
	
	splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Splash.jpg"]];
	splashImageView.frame = CGRectMake(0, 0, 480, 320);
	[self.view addSubview:splashImageView];
	
	viewController = [[ballChainViewController alloc] initWithNibName:@"ballChainViewController" bundle:[NSBundle mainBundle]];
	viewController.view.alpha = 0.0;
	[self.view addSubview:viewController.view];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];
}

-(void) onTimer{
	NSLog(@"LOAD");
}

- (void)fadeScreen
{
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:0.75];        // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	[UIView setAnimationDidStopSelector:@selector(finishedFading)];   // calls the finishedFading method when the animation is done (or done fading out)	
	self.view.alpha = 0.5;       // Fades the alpha channel of this view to "0.0" over the animationDuration of "0.75" seconds
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
}


- (void) finishedFading
{
	
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:0.75];        // sets animation duration
	self.view.alpha = 1.0;   // fades the view to 1.0 alpha over 0.75 seconds
	viewController.view.alpha = 1.0;
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
	[splashImageView removeFromSuperview];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[viewController release];
    [super dealloc];
}


@end
