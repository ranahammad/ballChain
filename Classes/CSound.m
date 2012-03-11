//
//  CSound.m
//  theBall
//
//  Created by Faisal Saeed on 5/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CSound.h"


@implementation CSound
+ (void) soundEffect:(int)soundNumber 
{
	CFStringRef effect;
	CFStringRef type;
	soundNumber = soundNumber % 4;
	switch (soundNumber) 
	{
		case 0:
			effect = CFSTR("beep2");
			type = CFSTR("wav");
			break;
/*		case 1:
			effect = CFSTR("clappingSoundFile");
			type = CFSTR("caf");
			break;
*/		default:
			effect = CFSTR("ambient_button_201");
			type = CFSTR("wav");
			break;
/*		default:
			effect = CFSTR("collide");
			type = CFSTR("caf");
*/			break;
	}
	 
//	NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"sound"];
//	if ([value compare:@"ON"] == NSOrderedSame) 
	{
		SystemSoundID soundID;
		OSStatus err = kAudioServicesNoError;
		CFURLRef aiffURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), effect, type, NULL);
		err = AudioServicesCreateSystemSoundID(aiffURL, &soundID);
		AudioServicesPlaySystemSound (soundID);
	}
}
 
- (void)dealloc 
{
	[super dealloc];
}

@end
