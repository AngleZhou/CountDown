//
//  AlarmClock+Create.h
//  CounterDown
//
//  Created by Zhou Qian on 15/4/7.
//  Copyright (c) 2015年 Zhou Qian. All rights reserved.
//

#import "AlarmClock.h"

@interface AlarmClock (Create)

/**
 *  new alarm clock
 *
 *  @param userSetTime    hour and minute user set
 *  @param repeatDayIndex 0~7. 0: no repeat; 1~7: single repeat weekday
 *  @param title          alarm clock name
 *  @param context        core data context
 *
 *  @return AlarmClock instance
 */
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime andRepeatDayIndex:(int)repeatDayIndex andTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context;

// single repeatDay, no titile
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime andRepeatDayIndex:(int)repeatDayIndex inManagedObjectContext:(NSManagedObjectContext *)context;

//userSetTime only
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 *  New Alarm clock with multiple repeat days
 *
 *  @param userSetTime          hour, minute user set
 *  @param repeatWeekDayIndexes array of repeat day indexes: from 0 to 7
 *  @param title                alarm clock title
 *  @param context              core data context
 *
 *  @return Alarm clock instance
 */
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime andRepeatWeekDays:(NSArray *)repeatWeekDayIndexes andTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context;

//Alarm clock with weekdays repeat, userSetTime (no title)
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime andRepeatWeekDays:(NSArray *)repeatWeekDayIndexes inManagedObjectContext:(NSManagedObjectContext *)context;



- (void)cancelNotification;

/**
 *  Get a NSDate of specified hour, minute, weekday user set
 *
 *  @param userSetTime        NSDate instance, from DatePicker user set
 *  @param repeatWeekDayIndex repeat weekday user choose (1~7)
 *
 *  @return a NSDate instance
 */
- (NSDate *)dateForAlarmClock:(NSDate *)userSetTime WithWeekDay:(int)repeatWeekDayIndex;

/**
 *  schedule local notification when an alarm clock is set
 *
 *  @param title      alarm clock title
 *  @param date       fireDate of local notification
 *  @param repeatUnit kCFCalendarUnit
 */
- (void)scheduleNotificationWithTitle:(NSString *)title Date:(NSDate *)date repeatInterval:(NSUInteger) repeatUnit;
@end
