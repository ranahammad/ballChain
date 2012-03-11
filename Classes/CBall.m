//
//  CBall.m
//  theBall
//
//  Created by Faisal Saeed on 5/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CBall.h"

#define ARC4RANDOM_MAX						0x100000000

@interface CBall (private)
CGFloat		m_fAngle;
- (void) initDirection;
@end


@implementation CBall

@synthesize m_bVisible;
@synthesize m_pBallImageView;
@synthesize m_ptDirection;
@synthesize m_ptCenter;
@synthesize m_fRadius;
@synthesize m_pBoundingRectangle;
@synthesize m_iTimeLeftForVisibility;
@synthesize m_iBallLevel;
@synthesize m_iBallType;

- (void) initDirection
{
	m_fAngle = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 360.0f);
	if(m_fAngle == 0)
		m_fAngle += 60.0;
	else if(m_fAngle == 90.0)
		m_fAngle += 30.0;
	else if(m_fAngle == 180.0)
		m_fAngle += 15.0;
	else if(m_fAngle == 270.0)
		m_fAngle -= 15.0;
	else if(m_fAngle == 360.0)
		m_fAngle -= 30.0;

	CGFloat xDirection = cos(m_fAngle);
	CGFloat yDirection = sin(m_fAngle);
	
	CGFloat tempX = xDirection;
	CGFloat tempY = yDirection;
	
	if(xDirection < 0.0)
	{
		tempX = -1.0 * xDirection;
		if(tempX < 0.75)
			xDirection = -0.75;
	}
	else
	{
		if(xDirection < 0.75)
			xDirection = 0.75; 
	}
	
	if(yDirection < 0.0)
	{
		tempY = -1.0 * yDirection;
		if(tempY < 0.75)
			yDirection = -0.75;
	}
	else
	{
		if(yDirection < 0.75)
			yDirection = 0.75;
	}
	
	self.m_ptDirection = CGPointMake(xDirection , yDirection);
}

- (id) initWithBall:(CBall*)pBall
{
	if(self = [self initBall:pBall.m_fRadius centerPt:pBall.m_ptCenter])
	{
		[self.m_pBallImageView setImage:[pBall.m_pBallImageView image]];
		self.m_iBallType = pBall.m_iBallType;
	}
	
	return self;
}

- (id) initBall:(CGFloat) pRadius centerPt:(CGPoint)pCenterpt
{
	if(self = [super init])
	{
		m_iBallType = 0;
		m_iBallLevel = 0;
		m_pBoundingRectangle = CGRectZero;
		self.m_ptCenter = CGPointMake(pCenterpt.x,pCenterpt.y);
		m_fRadius = pRadius;
		self.m_pBallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.m_ptCenter.x-pRadius,self. m_ptCenter.y-pRadius, 2*pRadius, 2*pRadius)];
		m_bVisible = TRUE;
		m_iTimeLeftForVisibility = -1;
	}
	return self;	
}

-(id) initBall:(CGFloat) pRadius boundingRect:(CGRect)pBoundingRect centerPt:(CGPoint)pCenterpt
{
	if(self = [super init])
	{
		m_iBallLevel = 0;
		m_pBoundingRectangle = pBoundingRect;
		self.m_ptCenter = CGPointMake(pCenterpt.x,pCenterpt.y);
		m_fRadius = pRadius;
		self.m_pBallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.m_ptCenter.x-pRadius,self. m_ptCenter.y-pRadius, 2*pRadius, 2*pRadius)];
		m_bVisible = TRUE;
		m_iTimeLeftForVisibility = -1;
		[self initDirection];
	}
	return self;
}

- (id) initMovingBall:(CGFloat)pRadius boundingRect:(CGRect)pRoundingRect
{
	CGFloat xPos = floorf(((double)arc4random() / ARC4RANDOM_MAX) * (pRoundingRect.size.width - 2*pRadius));
	CGFloat yPos = floorf(((double)arc4random() / ARC4RANDOM_MAX) * (pRoundingRect.size.height - 2*pRadius));
	
	if(yPos < 25.0)
		yPos = 25.0;
	if(xPos < 25.0)
		xPos = 25.0;
	
	if(self = [self initBall:pRadius boundingRect:pRoundingRect centerPt:CGPointMake(xPos+pRadius,yPos+pRadius)])
	{
//		m_iBallType = (floorf(((double)arc4random() / ARC4RANDOM_MAX) * 11.0f) + 1);
//		[self.m_pBallImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ball%d.png",m_iBallType]]];	
		[self.m_pBallImageView setImage:[UIImage imageNamed:@"ball_2.png"]];	
	}
	return self;
}

-(void) dealloc
{
	[m_pBallImageView setImage:nil];
	[m_pBallImageView release];
	[super dealloc];
}

-(void) updateCenterPoint:(CGPoint)pCenterpt
{
	m_ptCenter = CGPointMake(pCenterpt.x, pCenterpt.y);
	[self.m_pBallImageView setFrame:CGRectMake(self.m_ptCenter.x-m_fRadius,self. m_ptCenter.y-m_fRadius, 2*m_fRadius, 2*m_fRadius)];	
}

-(void) updateRadius:(CGFloat)pRadius
{
	m_fRadius = pRadius;
	[self.m_pBallImageView setFrame:CGRectMake(self.m_ptCenter.x-m_fRadius,self. m_ptCenter.y-m_fRadius, 2*m_fRadius, 2*m_fRadius)];
}

-(void) incrementRadiusBy:(CGFloat)pIncrement
{
	m_fRadius = m_fRadius + pIncrement;
	[self.m_pBallImageView setFrame:CGRectMake(self.m_ptCenter.x-m_fRadius,self. m_ptCenter.y-m_fRadius, 2*m_fRadius, 2*m_fRadius)];
}

-(void) calculateNewPosition
{
	CGPoint newPt;
	newPt = CGPointMake(self.m_ptCenter.x + self.m_ptDirection.x, self.m_ptCenter.y	+ self.m_ptDirection.y);
	self.m_ptCenter = CGPointMake(self.m_ptCenter.x + ((newPt.x) * cos(m_fAngle)),
							  self.m_ptCenter.y - ((newPt.y) * sin(m_fAngle)));
}

- (BOOL) updateBallPosition
{
	BOOL bCollision = FALSE;
	// move the BALL image around the screen
	// controlling the movement of ball
	
//	[self calculateNewPosition];
	self.m_ptCenter = CGPointMake(self.m_ptCenter.x + self.m_ptDirection.x, self.m_ptCenter.y	+ self.m_ptDirection.y);

	[self.m_pBallImageView setCenter:m_ptCenter];
	// check if the ball strikes left or right cornor
	if((self.m_ptCenter.x + m_fRadius) > (m_pBoundingRectangle.origin.x + m_pBoundingRectangle.size.width) ||
	   (self.m_ptCenter.x - m_fRadius) < (m_pBoundingRectangle.origin.x))
	{
		self.m_ptDirection = CGPointMake(-1.0 * self.m_ptDirection.x, self.m_ptDirection.y);
		bCollision = TRUE;
	}
	
	
	if((self.m_ptCenter.y + m_fRadius) > (m_pBoundingRectangle.origin.y	+ m_pBoundingRectangle.size.height) ||
	   (self.m_ptCenter.y - m_fRadius) < (m_pBoundingRectangle.origin.y))
	{
		self.m_ptDirection = CGPointMake(self.m_ptDirection.x, -1.0 * self.m_ptDirection.y);	
		bCollision = TRUE;
	}
	
	return bCollision;
}

- (BOOL) hasCollidedWithTouch:(CGPoint) ptTouch
{
	float diffX = (m_ptCenter.x - ptTouch.x);
	float diffY = (m_ptCenter.y - ptTouch.y);
		
	if( (diffX*diffX + diffY*diffY) <= (m_fRadius*m_fRadius))
	{
		m_ptDirection.x = -m_ptDirection.x;
		m_ptDirection.y = -m_ptDirection.y;

		if(m_fRadius <= kMinimumBallRadius)
		{
			m_bVisible = FALSE;
		}
		else
		{
			m_fRadius-=kMinimumBallRadius;
			[m_pBallImageView setFrame:CGRectMake(m_ptCenter.x - m_fRadius, m_ptCenter.y - m_fRadius, 2 * m_fRadius, 2*m_fRadius)];		
		}
		return TRUE;
	}
	return FALSE;
}

- (BOOL) hasCollidedWithAnotherBall:(CBall*) pOtherBall
{
	// current ball enters the area of pOtherBall
	// (x1- x2)^2 + (y1 - y2)^2 - (r1 -r2)^2 <=0
	
	CGFloat diffX = self.m_ptCenter.x - pOtherBall.m_ptCenter.x;
	CGFloat diffY = self.m_ptCenter.y - pOtherBall.m_ptCenter.y;
	CGFloat diffR = pOtherBall.m_fRadius;
	
	if((pow(diffX,2.0) + pow(diffY,2.0)) <= pow(diffR,2.0))
		return TRUE;
	return FALSE;
}


@end
