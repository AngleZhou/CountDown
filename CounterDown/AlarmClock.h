//
//  AlarmClock.h
//  CounterDown
//
//  Created by Zhou Qian on 15/4/8.
//  Copyright (c) 2015年 Zhou Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AlarmClock : NSManagedObject

@property (nonatomic, retain) NSArray * repeatDays;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) BOOL isON;
@property (nonatomic, retain) NSDate * time;

@end
