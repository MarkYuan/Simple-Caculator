//
//  WTIRGBEngine.h
//  Caculator
//
//  Created by 吴韬 on 17/2/6.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WTIRGB(H, S, B, D, UICOLOR) [WTIRGBEngine colorChange: (H) grayChange: (S) lightChange: (B) totalDistLenth: (D) uiColor: UICOLOR]

@interface WTIRGBEngine : NSObject

+ (UIColor *)colorChange: (CGFloat)colorDistances grayChange: (CGFloat)grayDistances
             lightChange: (CGFloat)lightDistences
          totalDistLenth: (CGFloat)lenth
                 uiColor: (UIColor *)color;

@end
