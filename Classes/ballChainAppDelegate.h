//
//  ballChainAppDelegate.h
//  ballChain
//
//  Created by Faisal Saeed on 5/9/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ballChainViewController;

@interface ballChainAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    ballChainViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ballChainViewController *viewController;

@end

