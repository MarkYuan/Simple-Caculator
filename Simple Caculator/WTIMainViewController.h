//
//  WTIMainViewController.h
//  Caculator
//
//  Created by 吴韬 on 16/9/4.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTIMainViewController : UIViewController

- (UIImage *)backgroundImage;
- (void)settingChanged: (UIColor *)backgroundColor colorLevel: (NSInteger)colorLevel reverse: (BOOL)colorReversed soundOn: (BOOL)soundOn;

@end
