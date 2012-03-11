//
//  ballChainViewController.m
//  ballChain
//
//  Created by Faisal Saeed on 5/9/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ballChainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CSound.h"

#define ARC4RANDOM_MAX						0x100000000
#define kInitialBallRadius					10

#define kFinalBallRadius					15

#define kLeftWallPosition					10
#define kTopWallPosition					10
#define kWidthPlayground					460
#define kHeightPlayground					290

#define kTimeForVisibility					300

@implementation ballChainViewController

@synthesize m_pMovingBalls;
@synthesize m_pTouchBalls;
@synthesize m_pTouchBallsLabels;

@synthesize m_pLabelScore;
@synthesize m_pLabelBallsCount;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
	///[self.view setBackgroundColor:[UIColor whiteColor]];
	m_iGameLevel = 3;
	m_pTouchBall = nil;
	m_iTargetBalls = 0;
	m_fTotalScore = 0;
	[m_pLabelScore setText:[NSString stringWithFormat:@"Score: %.0f",m_fTotalScore]];
	m_bFirstTouchDone = FALSE;
	m_pTouchBalls = [[NSMutableArray alloc] init];
	m_pTouchBallsLabels = [[NSMutableArray alloc] init];
	
	// allocate and hide the touch ball
	m_pTouchBall = [[CBall alloc] initBall:kInitialBallRadius 
								  centerPt:CGPointMake(150,150)];
	
	[[m_pTouchBall m_pBallImageView] setImage:[UIImage imageNamed:@"bigBall1.png"]];
	m_pTouchBall.m_bVisible = FALSE;
	
	// generate Moving Balls
	m_pMovingBalls = [[NSMutableArray alloc] init];
	m_fTotalBalls = pow(2.0,(m_iGameLevel+1)*1.0);
	[m_pLabelBallsCount setText:[NSString stringWithFormat:@"Balls: %.0f",m_fTotalBalls]];
	for(int i=0; i< m_fTotalBalls ; i++)
	{
		[m_pMovingBalls addObject:[[CBall alloc] initMovingBall:kInitialBallRadius boundingRect:CGRectMake(kLeftWallPosition, kTopWallPosition, kWidthPlayground, kHeightPlayground)]];
		[self.view addSubview:[[m_pMovingBalls objectAtIndex:i] m_pBallImageView]];
	}
	
	// load from Default settings
	// Set game speed
	m_fGameSpeed = 0.001;
	
	// start the game loop
	m_pGameRunningID = [NSTimer scheduledTimerWithTimeInterval:m_fGameSpeed 
														target:self 
													  selector:@selector(gameLoop) 
													  userInfo:nil 
													   repeats:YES];	
	m_bGameSound = TRUE;
	m_iGameState = kGameStateRunnning;
}

-(void) gameLoop
{
	if(m_iGameState == kGameStateRunnning)
	{
		for(int i=0; i<[m_pMovingBalls count]; i++)
		{
			CBall *pBall = [m_pMovingBalls objectAtIndex:i];
			
			if([pBall m_bVisible])
			{
				[pBall updateBallPosition];
			
				if([m_pTouchBalls count]>0)
				{
					for(int j=0; j<[m_pTouchBalls count]; j++)
					{
						CBall *pTempBall = [m_pTouchBalls objectAtIndex:j];
						if([pTempBall m_bVisible])
						{
							if([pBall hasCollidedWithAnotherBall:pTempBall])
							{
								// collision has occurred
								CBall *newBall = [[CBall alloc] initWithBall:pBall];
								newBall.m_iTimeLeftForVisibility = kTimeForVisibility;
								newBall.m_iBallLevel = pTempBall.m_iBallLevel + 1;
								[[newBall m_pBallImageView] setAlpha:0.5];
								[self.view addSubview:[newBall m_pBallImageView]];
								[m_pTouchBalls addObject:newBall];
								pBall.m_bVisible = FALSE;
								CGFloat currentScore = (pow(2,newBall.m_iBallLevel) * 50.0);
								
								UILabel* pLabel = [[UILabel alloc] init];
								[pLabel setFrame:CGRectMake(0, 0, 50, 10)];
								[pLabel setCenter:newBall.m_ptCenter];
								[pLabel setText:[NSString stringWithFormat:@"+%.0f",currentScore]];
								[pLabel setTextAlignment:UITextAlignmentCenter];
								[pLabel setBackgroundColor:[UIColor clearColor]];
								[pLabel setTextColor:[UIColor whiteColor]];
								[pLabel setFont:[UIFont systemFontOfSize:10.0]];
								[self.view addSubview:pLabel];
								[self.view bringSubviewToFront:pLabel];
								[m_pTouchBallsLabels addObject:pLabel];
								 
								m_fTotalScore += currentScore;
								[m_pLabelScore setText:[NSString stringWithFormat:@"Score: %.0f",m_fTotalScore]];
								m_fTotalBalls--;
								[m_pLabelBallsCount setText:[NSString stringWithFormat:@"Balls: %.0f",m_fTotalBalls]];	
								//[CSound soundEffect:newBall.m_iBallType];

								break;
							}
						}
					}
					
					if([pBall m_bVisible] == FALSE)
					{
						[[pBall m_pBallImageView] removeFromSuperview];
						[m_pMovingBalls removeObject:pBall];
						i--;
					}
				}
			}
		}

		if([m_pTouchBalls count] > 0)
		{
			for(int i=0; i<[m_pTouchBalls count]; i++)
			{
				CBall *pBall = [m_pTouchBalls objectAtIndex:i];
				if([pBall m_bVisible])
				{
					if(pBall.m_iTimeLeftForVisibility <= (kTimeForVisibility/2))
						[pBall incrementRadiusBy:-0.2];
					else
						[pBall incrementRadiusBy:0.2];
					pBall.m_iTimeLeftForVisibility--;
					if(pBall.m_iTimeLeftForVisibility == 0)
					{
						[pBall updateRadius:kInitialBallRadius];
						[[pBall m_pBallImageView] removeFromSuperview];
						pBall.m_bVisible = FALSE;
						[m_pTouchBalls removeObjectAtIndex:i];
						
						[[m_pTouchBallsLabels objectAtIndex:i] removeFromSuperview];
						[m_pTouchBallsLabels removeObjectAtIndex:i];
						i--;
					}			
				}
			}
		}
		
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:self.view];
	
	if([m_pTouchBalls count] == 0)
	{
//		UIAlertView *pAlert = [[UIAlertView alloc] initWithTitle:@"msg box" message:@"touch check" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//		[pAlert show];
//		[pAlert release];

		if([m_pTouchBall m_bVisible] == FALSE)
		{
			[[m_pTouchBall m_pBallImageView] setAlpha:0.75];
			[m_pTouchBall updateCenterPoint:touchLocation];
			m_pTouchBall.m_iTimeLeftForVisibility = kTimeForVisibility;
			m_pTouchBall.m_bVisible = TRUE;
			[m_pTouchBalls addObject:m_pTouchBall];

			UILabel* pLabel = [[UILabel alloc] init];
			[pLabel setFrame:CGRectMake(0, 0, 50, 15)];
			[pLabel setCenter:m_pTouchBall.m_ptCenter];
			[pLabel setText:@""];
			[pLabel setTextAlignment:UITextAlignmentCenter];
			[pLabel setBackgroundColor:[UIColor clearColor]];
			[pLabel setTextColor:[UIColor whiteColor]];
			[pLabel setFont:[UIFont systemFontOfSize:10.0]];
			[self.view addSubview:pLabel];
			[m_pTouchBallsLabels addObject:pLabel];

			if(m_bFirstTouchDone)
			{
				CGFloat currentScore = (m_fTotalBalls * 10);
				m_fTotalScore -= currentScore;
				if(m_fTotalScore <= 0)
					m_fTotalScore = 0;
				//[pLabel setText:[NSString stringWithFormat:@"-%.0f",currentScore]];
				[m_pLabelScore setText:[NSString stringWithFormat:@"Score: %.0f",m_fTotalScore]];
			}
			if(m_bFirstTouchDone == FALSE)
				m_bFirstTouchDone = TRUE;
		
			[self.view addSubview:[m_pTouchBall m_pBallImageView]];
			[self.view sendSubviewToBack:[m_pTouchBall m_pBallImageView]];
			
			m_pTouchBallTimer = [NSTimer scheduledTimerWithTimeInterval:m_fGameSpeed 
																 target:self 
															   selector:@selector(touchBallTimer) 
															   userInfo:nil 
																repeats:YES];
		}	
	}
}

-(void) touchBallTimer
{
	if([m_pTouchBalls count] > 0)
	{
		for(int i=0; i<[m_pTouchBalls count]; i++)
		{
			CBall *pBall = [m_pTouchBalls objectAtIndex:i];
			if([pBall m_bVisible])
			{
				[pBall incrementRadiusBy:0.2];
				pBall.m_iTimeLeftForVisibility--;
				if(pBall.m_iTimeLeftForVisibility == 0)
				{
					[pBall updateRadius:kInitialBallRadius];
					[[pBall m_pBallImageView] removeFromSuperview];
					pBall.m_bVisible = FALSE;
					[m_pTouchBalls removeObjectAtIndex:i];
					
					[[m_pTouchBallsLabels objectAtIndex:i] removeFromSuperview];
					[m_pTouchBallsLabels removeObjectAtIndex:i];
					
					i--;
				}			
			}
		}
	}
	
	if([m_pTouchBalls count] == 0)
		[m_pTouchBallTimer invalidate];
}

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
	for(int i=0; i<[m_pMovingBalls count]; i++)
		[[m_pMovingBalls objectAtIndex:i] release];
	[m_pMovingBalls removeAllObjects];
	[m_pMovingBalls release];
	
	for(int j=0; j<[m_pTouchBalls count]; j++)
		[[m_pTouchBalls objectAtIndex:j] release];
	[m_pTouchBalls removeAllObjects];
	[m_pTouchBalls release];
	
	[m_pTouchBallsLabels removeAllObjects];
	[m_pTouchBallsLabels release];
	
	[m_pTouchBall release];
    [super dealloc];
}

@end
