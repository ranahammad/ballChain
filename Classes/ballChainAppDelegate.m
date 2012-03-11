//
//  ballChainAppDelegate.m
//  ballChain
//
//  Created by Faisal Saeed on 5/9/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ballChainAppDelegate.h"
#import "ballChainViewController.h"

@implementation ballChainAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
