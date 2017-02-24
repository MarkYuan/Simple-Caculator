//
//  Setting.h
//  Caculator
//
//  Created by 吴韬 on 16/9/5.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#ifndef Setting_h
#define Setting_h

#define UICOLOR(R, G, B, A) [UIColor colorWithRed: (R)/255.0 green: (G)/255.0 blue: (B)/255.0 alpha: A]
#define RAMDOM_COLOR [UIColor colorWithRed: arc4random() % 255 / 255.0 green: arc4random() % 255 / 255.0 blue: arc4random() % 255 / 255.0 alpha: 1.0]

#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define SETTING_LENGTH 30
#define SETTING_H_DIVIDER 24
#define SETTING_V_DIVIDER 26

#define H_OFFSET -0.28
#define S_OFFSET 0.1
#define B_OFFSET -0.2
#define LEVEL_RADIO 0.25

#define DEFAULT_LEVEL 7

static NSString * const soundsOnKey = @"soundsOnKey";
static NSString * const backgroundColorKey = @"backgroundColorKey";
static NSString * const firstLunchKey = @"firstLunchKey";
static NSString * const everLunchedKey = @"everLunchedKey";
static NSString * const levelButtonRadiusKey = @"levelButtonRadiusKey";
static NSString * const colorLevelKey = @"colorLevelKey";
static NSString * const colorReversedKey = @"colorReversedKey";
static NSString * const expressonArrayKey = @"expressonArrayKey";

typedef enum {
    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    
    cancel,
    power,
    square,
    percent,
    divide,
    multiply,
    minus,
    plus,
    leftBracket,
    rightBracket,
    point
} wButton;

#endif /* Setting_h */
