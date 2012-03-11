//
//  RepositoryController.m
//  MindMation
//
//  Created by Faisal Saeed on 12/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CSqliteController.h"
//#import "CScore.h"

//#define INSERT_TASK_QUERY "INSERT INTO taskMM (Title,Category,Priority,Text,Status) VALUES('New task','Personal','3','This is sample decscription','0')"
//#define DBSELECT_QUERY_WHERE "SELECT Title,Category,Priority,Text,Status,StartDateTime,EndDateTime FROM taskMM WHERE pk=?"
#define UPDATE_TASK_QUERY	@"UPDATE %@ SET %@ = ?, Category = ?, Text = ? , Priority = ?,Status = ?, StartDateTime = ?, EndDateTime = ? WHERE pk=?"
#define DELETE_TASK_QUERY	@"DELETE FROM %@ WHERE pk=?"
#define SELECT_ALL_QUERY	@"SELECT * FROM %@"
#define ADD_TASK_QUERY		@"INSERT INTO %@ (Title,Category,Priority,Text,Status,StartDateTime, EndDateTime) VALUES(?,?,?,?,?,?,?)"

/*@interface CSqliteController (Private)
- (BOOL) createEditableCopyOrDatabaseIfNeeded;
- (void) loadTasksFromTable;
- (void) deleteTaskFromTable:(const char*) sql primaryKey:(int) pk;
- (void) updateTaskInTable:(const char*) sql tempTask:(Task*) task;
- (void) insertTaskToTable:(const char*) sql tempTask:(Task*) task;
- (void) loadCategoriesFromTable;
@end
*/

@implementation CSqliteController

-(id) init
{
	if (self = [super init]) 
	{
		m_pDatabaseName = nil;
		m_pTableName = nil;
		m_pTableColumns = nil;
		m_pTableColumnTypes = nil;
		m_pTableRows = nil;
	}
	return self;
}

- (void)dealloc 
{
	if(m_pSqliteDatabase != nil)
	{
		sqlite3_close(m_pSqliteDatabase);
	}
	
	if(m_pTableRows != nil)
	{
		[m_pTableRows removeAllObjects];
		[m_pTableRows release];
		m_pTableRows = nil;
	}
	
	if(m_pTableColumnTypes != nil)
	{
		[m_pTableColumnTypes removeAllObjects];
		[m_pTableColumnTypes release];
		m_pTableColumnTypes = nil;
	}
	
	if(m_pTableColumns != nil)
	{
		[m_pTableColumns removeAllObjects];
		[m_pTableColumns release];
		m_pTableColumns = nil;
	}
	
	if(m_pTableName)
	{
		[m_pTableName release];
		m_pTableName = nil;
	}
	
	if(m_pDatabaseName)
	{
		[m_pDatabaseName release];
		m_pDatabaseName = nil;
	}
	
	[super dealloc];
}


-(BOOL) connectToDatabase:(NSString *) dbName
{
	if(m_pDatabaseName == nil)
		m_pDatabaseName = [[NSString alloc] initWithFormat:dbName];

	BOOL status =  [self createEditableCopyOrDatabaseIfNeeded];
	if(status == TRUE)
	{
		// The database is stored in the application bundle. 
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:m_pDatabaseName];
		// Open the database. The database was prepared outside the application.
		if (sqlite3_open([path UTF8String], &m_pSqliteDatabase) != SQLITE_OK) 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(m_pSqliteDatabase);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(m_pSqliteDatabase));
			// Additional error handling, as appropriate...
			status = FALSE;
			[m_pDatabaseName release];
			m_pDatabaseName = nil;
		}
	}
	
	return status;
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (BOOL)createEditableCopyOrDatabaseIfNeeded 
{
    // First, test for existence.
	//[dbController createEditableCopyOrDatabaseIfNeeded];
	
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:m_pDatabaseName];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return TRUE;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:m_pDatabaseName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) 
	{
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
	return success;
}

- (BOOL) initTable:(NSString*) tableName
{
	if(m_pTableName == nil)
	{
		m_pTableName = [[NSString alloc] initWithFormat:tableName];
		m_pTableColumns = [[NSMutableArray alloc] init];
		m_pTableColumnTypes = [[NSMutableArray alloc] init];
		m_pTableRows = [[NSMutableArray alloc] init];
		return TRUE;
	}
	return FALSE;
}

- (void) addColumnToTable:(NSString*) columnName dateType:(NSString*) columnDataType
{
	if(columnName == nil || columnDataType == nil)
		return;
	[m_pTableColumns addObject:columnName];
	[m_pTableColumnTypes addObject:columnDataType];
}

- (void) loadRecords:(NSString*) selectQuery
{	
    const char *sql = [selectQuery UTF8String];
    sqlite3_stmt *statement;
	
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
    if (sqlite3_prepare_v2(m_pSqliteDatabase, sql, -1, &statement, NULL) == SQLITE_OK) 
	{
		if([m_pTableRows count] >0)
			[m_pTableRows removeAllObjects];
		
		// We "step" through the results - once for each row.
		int hResult = sqlite3_step(statement);
        while (hResult == SQLITE_ROW) 
		{
			NSMutableArray *pRecord = [[NSMutableArray alloc] init];
			NSString *strContent = @"";
			
			for(int i=0; i<[m_pTableColumns count]; i++)
			{
				NSString *strColumn = [m_pTableColumnTypes objectAtIndex:i];
				if([strColumn compare:DATA_TYPE_STRING] == 0) 
				{
					strContent = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, i)];
					[pRecord addObject:strContent];
				}
				else if([strColumn compare:DATA_TYPE_INT] == 0)
				{
					strContent = [NSString stringWithFormat:@"%d",sqlite3_column_int(statement, i)];
					[pRecord addObject:strContent];
				}
				// more datatype checks can be added here !!! 
			}
			
            [m_pTableRows addObject:pRecord];
			[pRecord release];
			hResult = sqlite3_step(statement);
		}
	}
    // "Finalize" the statement - releases the resources associated with the statement.
    sqlite3_finalize(statement);
}

- (NSMutableArray*) loadRecordsFromTableOrderBy:(NSString*) orderingColumn orderType:(int) iSortingOrder
{
	NSString *queryString = @"";
	
	if(iSortingOrder == 0) // ascending order
	{
		queryString = [NSString stringWithFormat:@"%@ order by %@ ASC",
					   [NSString stringWithFormat:SELECT_ALL_QUERY,m_pTableName], orderingColumn];
	}
	else if (iSortingOrder == 1) // descending order
	{
		queryString = [NSString stringWithFormat:@"%@ order by %@ DESC",
					   [NSString stringWithFormat:SELECT_ALL_QUERY,m_pTableName], orderingColumn];	
	}
	
	[self loadRecords:queryString];
	return m_pTableRows;
}

- (NSMutableArray*) loadRecordsFromTable // returns all records loaded
{
	[self loadRecords:[NSString stringWithFormat:SELECT_ALL_QUERY, m_pTableName]];
	return m_pTableRows;
}

- (void) addRecordInTable:(NSMutableArray*) newRecord isAutoPrimaryKeyEnabled:(BOOL) bAutoPrimaryKey
{
	NSString *queryString = [NSString stringWithFormat:@"INSERT INTO %@ ",m_pTableName];
	NSString *queryString2 = @" VALUES";
	
	int startingIdx = 0;
	if(bAutoPrimaryKey)
		startingIdx = 1;

	for(int i=startingIdx; i<[m_pTableColumns count]; i++)
	{
		if(i==startingIdx)
		{
			queryString = [queryString stringByAppendingFormat:@"("];
			queryString2 = [queryString2 stringByAppendingFormat:@"("];
		}
		
		queryString = [queryString stringByAppendingFormat:@"%@",[m_pTableColumns objectAtIndex:i]];
		queryString2 = [queryString2 stringByAppendingFormat:@"?"];
		
		if(i<([m_pTableColumns count] - 1))
		{
			queryString = [queryString stringByAppendingFormat:@","];
			queryString2 =[queryString2 stringByAppendingFormat:@","];
		}
		else
		{
			queryString = [queryString stringByAppendingFormat:@")"];
			queryString2 = [queryString2 stringByAppendingFormat:@")"];
		}
	}
			
	queryString = [queryString stringByAppendingFormat:queryString2];
	
	const char *add_sql	= [queryString UTF8String];

	sqlite3_stmt *insert_statement;

	if (sqlite3_prepare_v2(m_pSqliteDatabase, add_sql, -1, &insert_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(m_pSqliteDatabase));
	}
	
	for(int i = startingIdx; i<[m_pTableColumns count]; i++)
	{
		NSString *columnType = [m_pTableColumnTypes objectAtIndex:i];
		if([columnType compare:DATA_TYPE_INT] == 0)
		{
			sqlite3_bind_int(insert_statement, i, [[newRecord objectAtIndex:i] intValue]);
		}
		else if([columnType	compare:DATA_TYPE_STRING] == 0)
		{
			sqlite3_bind_text(insert_statement, i, [[newRecord objectAtIndex:i] UTF8String], -1,SQLITE_TRANSIENT);
		}
	}
	
	int success = sqlite3_step(insert_statement);
	
	if (success != SQLITE_DONE) 
	{
		NSAssert1(0, @"Error: failed to save priority with message '%s'.", sqlite3_errmsg(m_pSqliteDatabase));
	}
	
	sqlite3_reset(insert_statement);
	
}

- (void) saveRecordsInTable:(NSMutableArray*) updatedRecords
{

}


/********************************************************************************/
//
// Table Name: TaskMM
// Description: It contains the all tasks information
//
// Public Methods: getTasksCount, addTask, removeTask, updateTask, saveTasks
//
// Private Methods: laodTasksFromTable, deleteTaskFromTable, updateTaskInTable, insertTaskToTable
//
/********************************************************************************/

// Following are the public methods which interact with the local taskList array
/*
-(int) searchTask:(int) pk
{
	for(int i=0; i<[taskList count]; i++)
	{
		Task *tTask = [taskList objectAtIndex:i];
		if(tTask.primaryKey == pk)
			return i;
	}
	return -1;
}

-(NSInteger) getTasksCount
{
	// return the count of all tasks with deletedTask == FALSE
	int iCount = [taskList count];
	for(int i=0; i<[taskList count]; i++)
	{
		Task *tTask = [taskList objectAtIndex:i];
		if (tTask.deletedTask == TRUE)
			iCount--;
		//[tTask release];
	}
	return iCount;
}

-(Task*) getTask:(int) idx
{
	int iCount = 0;
	for(int i=0; i<[taskList count]; i++)
	{
		Task *tTask = [taskList objectAtIndex:i];
		if(tTask.deletedTask == FALSE)
		{
			if(iCount == idx)
				return tTask;
			iCount++;
		}
	}
	return NULL;
}

-(void) addTask:(Task *) task
{
	task.newTask = TRUE;
	[taskList addObject:task];
}

-(void) removeTask:(Task *) task
{
	int idx = [self searchTask:task.primaryKey];
	if ( idx < 0) 
		return;
	task.deletedTask = TRUE;
}

-(Task *) updateTask:(Task *) task
{

	int idx = [self searchTask:task.primaryKey];
	if ( idx < 0) 
		return task;
	if(task.newTask == FALSE && task.dirtyTask	== FALSE)
		return task;
	Task *_newTask = [[Task alloc] initWithTask:task];
	
	if(task.newTask == TRUE)
		_newTask.newTask = TRUE;
	else if(task.dirtyTask == TRUE)
		_newTask.dirtyTask = TRUE;

	[taskList removeObjectAtIndex:idx];
	[taskList insertObject:_newTask atIndex:idx];
	return _newTask;
}

// Following are the private methods which interact with the database
-(void) loadTasksFromTable
{
	if(taskList != nil)
	{
		[taskList removeAllObjects];
	}
	else
	{
		NSMutableArray *taskArray = [[NSMutableArray alloc] init];
		self.taskList = taskArray;
		[taskArray release];
	}
	
    const char *sql = [[NSString stringWithFormat:SELECT_ALL_QUERY, Task_DBName] UTF8String];
    sqlite3_stmt *statement;
	
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
	{
		// We "step" through the results - once for each row.
        while (sqlite3_step(statement) == SQLITE_ROW) 
		{
			Task *td = [[Task alloc] init];
			td.primaryKey = sqlite3_column_int(statement, 0);
			td.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			td.category = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			td.priority = sqlite3_column_int(statement,3);
			td.text =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			td.status = sqlite3_column_int(statement,5);
			td.startDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 6)];
			td.endDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 7)];
			td.newTask = FALSE;
			td.deletedTask = FALSE;
			td.dirtyTask = FALSE;
            [self.taskList addObject:td];
            [td release];
		}
	}
    // "Finalize" the statement - releases the resources associated with the statement.
    sqlite3_finalize(statement);
}

-(void) saveTasks
{
	const char *delete_sql	= [[NSString stringWithFormat:DELETE_TASK_QUERY, Task_DBName] UTF8String];
	const char *update_sql	= [[NSString stringWithFormat:UPDATE_TASK_QUERY, Task_DBName] UTF8String];
	const char *add_sql		= [[NSString stringWithFormat:ADD_TASK_QUERY, Task_DBName] UTF8String];

	int iCount = [taskList count];
	
	if( iCount > 0)
	{
		// traverse through taskList and update the table in database
		for(int i=0; i<iCount; i++)
		{
			Task * tempTask = [taskList objectAtIndex:i];
			if ( tempTask.deletedTask == TRUE )
			{
				[self deleteTaskFromTable:delete_sql primaryKey:tempTask.primaryKey];
			}
			else if ( tempTask.dirtyTask == TRUE )
			{
				[self updateTaskInTable:update_sql tempTask:tempTask];
			}
			else if ( tempTask.newTask == TRUE )
			{
				[self insertTaskToTable:add_sql tempTask:tempTask];
			}
		}
		
		[self loadTasksFromTable];
	}

}

-(void) deleteTaskFromTable:(const char*) sql primaryKey:(int) pk
{
	// delete all tasks from the database which have deletedTask = TRUE
	// DELETE %@ taskMM WHERE pk=?
	int primaryKey = pk;
	sqlite3_stmt *delete_statement;
	if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_bind_int(delete_statement, 1, primaryKey);
	
	int success = sqlite3_step(delete_statement);
	
	if (success != SQLITE_DONE) 
	{
		NSAssert1(0, @"Error: failed to save priority with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_reset(delete_statement);
}

-(void) updateTaskInTable:(const char*) sql tempTask:(Task *) task
{
	// update all tasks in the database which have dirtyTask = TRUE
	// UPDATE %@ SET Title = ?, Category = ?, Text = ? , Priority = ?,Status = ?, StartDateTime = ?, EndDateTime = ? WHERE pk=?
	sqlite3_stmt *update_statement;
	Task *tempTask = task;
	if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_bind_int(update_statement, 8, tempTask.primaryKey);
	sqlite3_bind_double(update_statement, 7, [tempTask.endDate timeIntervalSince1970]);
	sqlite3_bind_double(update_statement, 6, [tempTask.startDate timeIntervalSince1970]);
	sqlite3_bind_int(update_statement, 5, tempTask.status);
	sqlite3_bind_int(update_statement, 4, tempTask.priority);
	sqlite3_bind_text(update_statement, 3, [tempTask.text UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement, 2, [tempTask.category UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement, 1, [tempTask.title UTF8String], -1, SQLITE_TRANSIENT);
		
	int success = sqlite3_step(update_statement);
		
	if (success != SQLITE_DONE) 
	{
		NSAssert1(0, @"Error: failed to save priority with message '%s'.", sqlite3_errmsg(database));
	}
		
	sqlite3_reset(update_statement);

}

- (void) insertTaskToTable:(const char*) sql tempTask:(Task*) task
{
	// add all tasks to the database which have newTask = TRUE	
	// INSERT INTO %@ (Title,Category,Priority,Text,Status,StartDateTime, EndDateTime) VALUES(?,?,?,?,?,?,?)"
	sqlite3_stmt *insert_statement;
	Task *tempTask = task;
	
	if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_bind_double(insert_statement, 7, [tempTask.endDate timeIntervalSince1970]);
	sqlite3_bind_double(insert_statement, 6, [tempTask.startDate timeIntervalSince1970]);
	sqlite3_bind_int(insert_statement, 5, tempTask.status);
	sqlite3_bind_text(insert_statement, 4, [tempTask.text UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insert_statement, 3, tempTask.priority);
	sqlite3_bind_text(insert_statement, 2, [tempTask.category UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 1, [tempTask.title UTF8String], -1, SQLITE_TRANSIENT);
	
	int success = sqlite3_step(insert_statement);
	
	if (success != SQLITE_DONE) 
	{
		NSAssert1(0, @"Error: failed to save priority with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_reset(insert_statement);
}
*/

@end
