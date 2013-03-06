//
//  Task.h
//  TaskListR
//
//  Created by Marco S. Graciano on 3/5/13.
//  Copyright (c) 2013 MSG. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Task : NSManagedObject

@property NSString *text;
@property NSDate *completedAt;
@property NSData *imageData;
@property NSData *audioData;

@property (nonatomic, getter = isCompleted) BOOL completed;

@end