//
//  CScore.h
//  iGameOn
//
//  Created by Faisal Saeed on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCORE_DATABASENAME	@"scoresDatabase.sqlite"
#define SCORE_TABLENAME		@"scores"
#define SCORE_COL0_PK		@"pk"
#define SCORE_COL1_NAME		@"playerName"
#define SCORE_COL2_LEVEL	@"level"
#define SCORE_COL3_SCORE	@"score"

@interface CScore : NSObject 
{
	NSString *m_strPlayerName;
	NSInteger m_iLevel;
	NSInteger m_iScore;
}

@property (nonatomic, retain) NSString *m_strPlayerName;
@property (nonatomic) NSInteger m_iLevel;
@property (nonatomic) NSInteger m_iScore;

@end
