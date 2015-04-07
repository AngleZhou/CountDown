//
//  ViewController.m
//  CounterDown
//
//  Created by Zhou Qian on 15/3/14.
//  Copyright (c) 2015年 Zhou Qian. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic) int minutes;
@property (nonatomic) int seconds;
@property (nonatomic) int secondsLeft;
@property (nonatomic) BOOL isStarted;
@property (nonatomic) BOOL isRepeated;
@property (nonatomic) int timeUserSet; //in minutes

//@property (nonatomic) UIAlertView *alertView;


//@property (weak, nonatomic) IBOutlet UIDatePicker *countDownDatePicker;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *setFiveMinutesButton;
@property (weak, nonatomic) IBOutlet UIButton *setTenMinuteButton;
@property (weak, nonatomic) IBOutlet UIButton *setThirteenMinutesButton;

@property (weak, nonatomic) IBOutlet UIImageView *editImage;
@property (weak, nonatomic) IBOutlet UIView *editTimeTapView;

@end

@implementation ViewController

#define INITTIME 1

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tag = 0;
    self.editTimeTapView.tag = 1;
    self.isStarted = NO;
    self.timeUserSet = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"timeUserSet"];
    if (!self.timeUserSet) {
        self.timeUserSet = INITTIME;
    }
    self.miniteTextField.text = [NSString stringWithFormat:@"%02d", self.timeUserSet];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      if (self.isStarted) {
                                                          [self saveTimerState];
                                                      }
                                                      
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self invokeTimer];
                                                  }];
    
    //UI
    self.startButton.layer.cornerRadius = self.startButton.bounds.size.width / 2.0;
    self.startButton.clipsToBounds = YES;
    self.startButton.layer.borderWidth = 2.0;
    self.startButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.repeatButton.layer.cornerRadius = self.repeatButton.bounds.size.width / 2.0;
    self.repeatButton.clipsToBounds = YES;
    self.repeatButton.layer.borderWidth = 2.0;
    self.repeatButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.setFiveMinutesButton.layer.cornerRadius = self.setFiveMinutesButton.bounds.size.width / 2.0;
    self.setFiveMinutesButton.clipsToBounds = YES;
    self.setFiveMinutesButton.layer.borderWidth = 1.0;
    self.setFiveMinutesButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.setTenMinuteButton.layer.cornerRadius = self.setTenMinuteButton.bounds.size.width / 2.0;
    self.setTenMinuteButton.clipsToBounds = YES;
    self.setTenMinuteButton.layer.borderWidth = 1.0;
    self.setTenMinuteButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.setThirteenMinutesButton.layer.cornerRadius = self.setThirteenMinutesButton.bounds.size.width / 2.0;
    self.setThirteenMinutesButton.clipsToBounds = YES;
    self.setThirteenMinutesButton.layer.borderWidth = 1.0;
    self.setThirteenMinutesButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
//    UIGestureRecognizer *signleTap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(editTime:)];
//    [self.secondLabel]
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self saveTimerState];
}

#pragma mark - Actions

- (IBAction)startCounter:(UIButton *)sender {
    if (!self.isStarted) {
        //reset button state
        [self.startButton setTitle:@"取消" forState:normal];
        self.isStarted = YES;
        //disable repeat button
        [self.repeatButton setEnabled:NO];
        [self.repeatButton setAlpha:0.5];
        //hide edit image
        [self.editImage setHidden:YES];
        
        //set timer
        self.timeUserSet = [self.miniteTextField.text intValue];
        self.secondsLeft = self.timeUserSet * 60;
        [self scheduleLocalNotificationAfter:self.secondsLeft Repeat:self.isRepeated];
        [self countdownTimer];
        
        //save timeUserSet
        [[NSUserDefaults standardUserDefaults] setInteger:self.timeUserSet forKey:@"timeUserSet"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Cancel Timer
    } else {
        //reset start button
        [self.startButton setTitle:@"开始" forState:normal];
        self.isStarted = NO;
        //reset repeat button
        [self.repeatButton setTitle:@"重复" forState:normal];
        self.isRepeated = NO;
        //enable repeat button
        [self.repeatButton setEnabled:YES];
        [self.repeatButton setAlpha:1.0];
        //show edit image
        [self.editImage setHidden:NO];
        
        //reset countdown label
        self.miniteTextField.text = [NSString stringWithFormat:@"%02d", self.timeUserSet];
        self.secondLabel.text = [NSString stringWithFormat:@":00"];
        
        //cancel timer
        [self.timer invalidate];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }

}


- (IBAction)repeatTimer:(UIButton *)sender {
    if (!self.isRepeated) {
        [self.repeatButton setTitle:@"取消重复" forState:normal];
        self.isRepeated = YES;
    } else {
        [self.repeatButton setTitle:@"重复" forState:normal];
        self.isRepeated = NO;
    }
}

- (IBAction)editTime:(UITapGestureRecognizer *)sender {
    if (sender.view == self.editTimeTapView) {
        [self.miniteTextField becomeFirstResponder];
    }
}
- (IBAction)exitEditing:(UITapGestureRecognizer *)sender {
    [self.miniteTextField resignFirstResponder];
}

- (IBAction)setTimeButtonTapped:(UIButton *)sender {
    if (sender == self.setFiveMinutesButton) {
        self.miniteTextField.text = [NSString stringWithFormat:@"05"];
    }
    if (sender == self.setTenMinuteButton) {
        self.miniteTextField.text = [NSString stringWithFormat:@"10"];
    }
    if (sender == self.setThirteenMinutesButton) {
        self.miniteTextField.text = [NSString stringWithFormat:@"30"];
    }
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.isStarted) {
        return NO;
    }
    [self.editImage setHidden:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.miniteTextField resignFirstResponder];
//    [self.editImage setHidden:NO];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.editImage setHidden:NO];
    return YES;
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
        self.minutes = self.secondsLeft / 60;
        self.seconds = self.secondsLeft % 60;
        self.miniteTextField.text = [NSString stringWithFormat:@"%02d", self.minutes];
        self.secondLabel.text = [NSString stringWithFormat:@":%02d", self.seconds];
    } else if (self.secondsLeft == 0) {
        if (self.isRepeated) {
            self.secondsLeft = self.timeUserSet * 60;
        } else {
            self.secondsLeft--;
            [self.startButton setTitle:@"开始" forState:normal];
            [self.editImage setHidden:NO];
        }
        
    }
}



- (void)scheduleLocalNotificationAfter:(NSTimeInterval)timeInterval Repeat:(BOOL)isRepeat {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    note.soundName = UILocalNotificationDefaultSoundName;
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    if (isRepeat) {
        note.repeatInterval = kCFCalendarUnitMinute * ((int)timeInterval / 60);
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



#pragma mark - Inactive and Active

- (void)saveTimerState {
    int stopMinutes = [self.miniteTextField.text intValue];
    int stopSeconds = [self.secondLabel.text intValue];

    NSNumber *secondsLeft = [NSNumber numberWithInt:(stopMinutes * 60 + stopSeconds)];
    NSUserDefaults *timerDefault = [NSUserDefaults standardUserDefaults];
    [timerDefault setObject:secondsLeft forKey:@"stopSecondsLeft"];
    [timerDefault setObject:[NSDate date] forKey:@"stopSystemTime"];
    [timerDefault setBool:YES forKey:@"isStarted"];
    [timerDefault synchronize];
}

- (void)invokeTimer {
    NSUserDefaults *timerDefault = [NSUserDefaults standardUserDefaults];
    if ([timerDefault boolForKey:@"isStarted"]) {
        NSNumber *stopSecondsLeft = [timerDefault objectForKey:@"stopSecondsLeft"];
        long stopSecondsLeftInt = [stopSecondsLeft integerValue];
        NSDate *stopSystemTime= [timerDefault objectForKey:@"stopSystemTime"];
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:stopSystemTime];
        int minutes;
        int seconds;
        if (stopSecondsLeftInt > timeInterval) {
            self.secondsLeft = stopSecondsLeftInt - timeInterval;
            minutes = self.secondsLeft / 60;
            seconds = self.secondsLeft % 60;
            [self countdownTimer];
        } else {
            minutes = 0;
            seconds = 0;
            self.secondsLeft = -1;
        }
        self.miniteTextField.text = [NSString stringWithFormat:@"%02d", minutes];
        self.secondLabel.text = [NSString stringWithFormat:@":%02d", seconds];
    }
    
}

@end
