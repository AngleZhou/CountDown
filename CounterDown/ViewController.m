//
//  ViewController.m
//  CounterDown
//
//  Created by Zhou Qian on 15/3/14.
//  Copyright (c) 2015年 Zhou Qian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIAlertViewDelegate>
@property (nonatomic) int minutes;
@property (nonatomic) int seconds;
@property (nonatomic) int secondsLeft;
@property (nonatomic) BOOL isStarted;
//@property (nonatomic) UIAlertView *alertView;


@property (weak, nonatomic) IBOutlet UIDatePicker *countDownDatePicker;

@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation ViewController


#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.countDownLabel setHidden:YES];
    self.isStarted = NO;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self saveTimerState];
}

#pragma mark - Actions

- (IBAction)startCounter:(UIButton *)sender {
    if (!self.isStarted) {
        [self.startButton setTitle:@"取消" forState:normal];
        self.isStarted = YES;
        NSTimeInterval timeInterval = self.countDownDatePicker.countDownDuration;
//        self.secondsLeft = timeInterval;
        self.secondsLeft = 5;
        [self scheduleLocalNotificationAfter:self.secondsLeft Repeat:NO];
        
        int minutes = ((int)timeInterval % 3600) / 60;
        int seconds = ((int)timeInterval % 3600) % 60;
        self.countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        
        [self.countDownDatePicker setHidden:YES];
        [self.countDownLabel setHidden:NO];
    
    //Cancel Timer
    } else {
        [self.startButton setTitle:@"开始" forState:normal];
        self.isStarted = NO;
        [self.countDownLabel setHidden:YES];
        [self.countDownDatePicker setHidden:NO];
    }
    
    [self countdownTimer];

}

#pragma mark - Timer

- (void)countdownTimer {
    [self.timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                              target:self
                                            selector:@selector(updateCounter:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)updateCounter:(NSTimer *)theTimer {
    if (self.secondsLeft > 0) {
        self.secondsLeft--;
        self.minutes = (self.secondsLeft % 3600) / 60;
        self.seconds = (self.secondsLeft % 3600) % 60;
        self.countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d", self.minutes, self.seconds];
    } else if (self.secondsLeft == 0) {
        self.secondsLeft--;
        [self.startButton setTitle:@"开始" forState:normal];
        [self.countDownLabel setHidden:YES];
        [self.countDownDatePicker setHidden:NO];
    }
}



- (void)scheduleLocalNotificationAfter:(NSTimeInterval)timeInterval Repeat:(BOOL)isRepeat {
    UILocalNotification *note = [[UILocalNotification alloc] init];
//    note.alertBody = @"计时结束";
    note.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    note.soundName = UILocalNotificationDefaultSoundName;

    
    if (isRepeat) {
        int minutes = ((int)timeInterval % 3600) / 60;
        note.repeatInterval = kCFCalendarUnitMinute * minutes;
    }
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound categories:nil]];
        [application scheduleLocalNotification:note];
    }
}

- (void)scheduleLocalNotificationAfter:(NSTimeInterval)timeInterval {
    [self scheduleLocalNotificationAfter:timeInterval Repeat:NO];
}




- (void)saveTimerState {
    NSString *stopSecondsLeftString = self.countDownLabel.text;
    NSNumber *stopSecondsLeft = [NSNumber numberWithInt:(int)[stopSecondsLeftString integerValue]];
    NSUserDefaults *timerDefault = [NSUserDefaults standardUserDefaults];
    [timerDefault setObject:stopSecondsLeft forKey:@"stopSecondsLeft"];
    [timerDefault setObject:[NSDate date] forKey:@"stopSystemTime"];
    [timerDefault synchronize];
}

- (void)invokeTimer {
    NSUserDefaults *timerDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *stopSecondsLeft = [timerDefault objectForKey:@"stopSecondsLeft"];
    long stopSecondsLeftInt = [stopSecondsLeft integerValue];
    NSDate *stopSystemTime= [timerDefault objectForKey:@"stopSystemTime"];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:stopSystemTime];
    int minutes;
    int seconds;
    if (stopSecondsLeftInt > timeInterval) {
        self.secondsLeft = stopSecondsLeftInt - timeInterval;
        [self countdownTimer];
    } else {
        minutes = 0;
        seconds = 0;
    }
    self.countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    
}

@end
