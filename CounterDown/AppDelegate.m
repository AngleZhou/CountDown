//
//  AppDelegate.m
//  CounterDown
//
//  Created by Zhou Qian on 15/3/14.
//  Copyright (c) 2015年 Zhou Qian. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface AppDelegate ()
@property (nonatomic, strong) AVAudioPlayer *player;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    
    NSDateComponents *dateComponets = [[NSDateComponents alloc] init];
    dateComponets.weekday = 2;
    dateComponets.hour = components.hour;
    dateComponets.minute = components.minute;
    dateComponets.timeZone = [NSTimeZone defaultTimeZone];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponets];
    NSLog(@"%@", [date descriptionWithLocale:[NSLocale currentLocale]]);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //get seconds left
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //play sound, display a message
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"计时结束" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//    [alertView show];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tap" ofType:@"aif"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    [self.player prepareToPlay];
    [self.player play];
}



@end
