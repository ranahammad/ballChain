//
//  ballChainViewController.h
//  ballChain
//
//  Created by Faisal Saeed on 5/9/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBall.h"

#define kGameStateRunnning	1
#define kGameStatePaused	2

@interface ballChainViewController : UIViewController 
{
	CBall	*m_pBall,*m_pBall2,*m_pBall3,*m_pBall4;
	CBall	*m_pTouchBall;
	NSMutableArray *m_pMovingBalls;
	
	NSMutableArray *m_pTouchBalls;
	NSMutableArray *m_pTouchBallsLabels;
	
	id	m_pGameRunningID;
	id	m_pTouchBallTimer;
	NSInteger m_iGameState;
	CGFloat m_fGameSpeed;
	BOOL	m_bGameSound;
	BOOL	m_bFirstTouchDone;
	NSInteger m_iGameLevel;
	NSInteger m_iTargetBalls;
	NSInteger m_iTimeLeft;
	
	UILabel *m_pLabelScore;
	UILabel *m_pLabelBallsCount;
	CGFloat m_fTotalScore;
	CGFloat m_fTotalBalls;
}

@property (nonatomic,retain) IBOutlet UILabel *m_pLabelBallsCount;
@property (nonatomic,retain) IBOutlet UILabel *m_pLabelScore;

@property (nonatomic,retain) NSMutableArray *m_pMovingBalls;
@property (nonatomic, retain) NSMutableArray *m_pTouchBalls;
@property (nonatomic, retain) NSMutableArray *m_pTouchBallsLabels;

@end

