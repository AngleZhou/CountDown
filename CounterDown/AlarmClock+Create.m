//
//  AlarmClock+Create.m
//  CounterDown
//
//  Created by Zhou Qian on 15/4/7.
//  Copyright (c) 2015年 Zhou Qian. All rights reserved.
//

#import "AlarmClock+Create.h"
#import <UIKit/UIKit.h>

@implementation AlarmClock (Create)



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
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime andRepeatDayIndex:(int)repeatDayIndex andTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context {
    
    AlarmClock *alarmClock = nil;
    
    //new alarm clock into context
    alarmClock = [NSEntityDescription insertNewObjectForEntityForName:@"AlarmClock" inManagedObjectContext:context];
    alarmClock.isON = YES;
    //no repeat
    if (repeatDayIndex == 0) {
        alarmClock.time = userSetTime;
        alarmClock.repeatDays = nil;
        //schedule local notification
        [alarmClock scheduleNotificationWithTitle:title Date:userSetTime repeatInterval:0];
        
    //repeat, time = hour + minute + repeatDay
    } else {
        NSDate *fireDate = [alarmClock dateForAlarmClock:userSetTime WithWeekDay:repeatDayIndex];
        alarmClock.time = fireDate;
        alarmClock.repeatDays = @[[NSNumber numberWithInt:repeatDayIndex]];
        //schedule local notification
        [alarmClock scheduleNotificationWithTitle:title Date:fireDate repeatInterval:kCFCalendarUnitWeekday];
    }
    
    alarmClock.title = title;
    
    return alarmClock;
}



// single repeatDay, no titile
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime andRepeatDayIndex:(int)repeatDayIndex inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self newAlarmclockWithDate:userSetTime andRepeatDayIndex:repeatDayIndex andTitle:nil inManagedObjectContext:context];
}

//userSetTime only
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self newAlarmclockWithDate:userSetTime andRepeatDayIndex:0 inManagedObjectContext:context];
}


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
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime andRepeatWeekDays:(NSArray *)repeatWeekDayIndexes andTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context {
    
    AlarmClock *alarmClock = nil;

    //new alarm clock into context
    alarmClock = [NSEntityDescription insertNewObjectForEntityForName:@"AlarmClock" inManagedObjectContext:context];
    alarmClock.isON = YES;
    NSDate *fireDate = [alarmClock dateForAlarmClock:userSetTime WithWeekDay:[repeatWeekDayIndexes[0] intValue]];
    alarmClock.time = fireDate;
    alarmClock.title = title;
    alarmClock.repeatDays = [repeatWeekDayIndexes copy];
    
    //repeat everyday
    if ([repeatWeekDayIndexes count] == 7) {
        [alarmClock scheduleNotificationWithTitle:title Date:fireDate repeatInterval:kCFCalendarUnitDay];
    } else {
    for (NSNumber *weekDay in repeatWeekDayIndexes) {
        [alarmClock scheduleNotificationWithTitle:title Date:[alarmClock dateForAlarmClock:userSetTime WithWeekDay:[weekDay intValue]] repeatInterval:kCFCalendarUnitWeekday];
    }
    }
    
    return alarmClock;

}

//Alarm clock with weekdays repeat, userSetTime (no title)
+ (instancetype)newAlarmclockWithDate:(NSDate *)userSetTime andRepeatWeekDays:(NSArray *)repeatWeekDayIndexes inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self newAlarmclockWithDate:userSetTime andRepeatWeekDays:repeatWeekDayIndexes andTitle:nil inManagedObjectContext:context];
}




- (void)cancelNotification {
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *note in localNotifications) {
        NSTimeInterval timeInterval = [note.fireDate timeIntervalSinceDate:self.time];
        long long time = [[NSNumber numberWithDouble:timeInterval] longLongValue];
        if (time % (24*60*60) == 0) {
            [[UIApplication sharedApplication] cancelLocalNotification:note];
        }
    }
}

/**
 *  Get a NSDate of specified hour, minute, weekday user set
 *
 *  @param userSetTime        NSDate instance, from DatePicker user set
 *  @param repeatWeekDayIndex repeat weekday user choose (1~7)
 *
 *  @return a NSDate instance
 */
- (NSDate *)dateForAlarmClock:(NSDate *)userSetTime WithWeekDay:(int)repeatWeekDayIndex {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:userSetTime];
    NSDateComponents *dateComponets = [[NSDateComponents alloc] init];
    dateComponets.weekday = repeatWeekDayIndex;
    dateComponets.hour = components.hour;
    dateComponets.minute = components.minute;
    dateComponets.year = components.year;
    dateComponets.month = components.month;
    dateComponets.day = components.day;
    dateComponets.timeZone = [NSTimeZone defaultTimeZone];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponets];
    
    return date;
}

/**
 *  schedule local notification when an alarm clock is set
 *
 *  @param title      alarm clock title
 *  @param date       fireDate of local notification
 *  @param repeatUnit kCFCalendarUnit
 */
- (void)scheduleNotificationWithTitle:(NSString *)title Date:(NSDate *)date repeatInterval:(NSUInteger) repeatUnit{
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertBody = title;
    note.fireDate = date;
    note.soundName = UILocalNotificationDefaultSoundName;
    note.repeatInterval = repeatUnit;
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
        [application scheduleLocalNotification:note];
    }

}
@end
