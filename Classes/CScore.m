//
//  CScore.m
//  iGameOn
//
//  Created by Faisal Saeed on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CScore.h"


@implementation CScore
@synthesize m_strPlayerName;
@synthesize m_iLevel;
@synthesize m_iScore;

-(id) init
{
	if(self = [super init])
	{
		m_strPlayerName = [[NSString alloc] init];
		m_iLevel = 1;
		m_iScore = 0;
	}
	
	return self;
}

-(void) dealloc
{
	[m_strPlayerName release];
	[super dealloc];
}

@end
