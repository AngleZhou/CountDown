//
//  ViewController.h
//  CounterDown
//
//  Created by Zhou Qian on 15/3/14.
//  Copyright (c) 2015年 Zhou Qian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UITextField *miniteTextField;


@end

