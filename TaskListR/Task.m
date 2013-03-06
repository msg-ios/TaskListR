//
//  Task.m
//  TaskListR
//
//  Created by Marco S. Graciano on 3/5/13.
//  Copyright (c) 2013 MSG. All rights reserved.
//

#import "Task.h"

@implementation Task
@dynamic text;
@dynamic completedAt;
@dynamic imageData;
@dynamic audioData;

- (BOOL)isCompleted {
    return self.completedAt != nil;
}

- (void)setCompleted:(BOOL)completed {
    self.completedAt = completed ? [NSDate date] : nil;
}

@end