//
//  WTIRGBEngine.m
//  Caculator
//
//  Created by 吴韬 on 17/2/6.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import "WTIRGBEngine.h"

#define UIColor(R, G, B) [UIColor colorWithRed: (R) green: (G) blue: (B) alpha: 1.0]
#define THREEMAX(R, G, B) (((R) >= (G) ? (R) : (G)) >= ((R) >= (B) ? (R) : (B)) ? ((R) >= (G) ? (R) : (G)) : ((R) >= (B) ? (R) : (B)))
#define THREEMIN(R, G, B) (((R) <= (G) ? (R) : (G)) <= ((R) <= (B) ? (R) : (B)) ? ((R) <= (G) ? (R) : (G)) : ((R) <= (B) ? (R) : (B)))
#define GRAY(R, G, B) ((THREEMAX((R), (G), (B)) + THREEMIN((R), (G), (B))) / 2)

@implementation WTIRGBEngine

+ (UIColor *)colorChange: (CGFloat)colorDistances grayChange: (CGFloat)grayDistances
             lightChange: (CGFloat)lightDistences
          totalDistLenth: (CGFloat)lenth
                 uiColor: (UIColor *)color
{
    CGFloat R; CGFloat G; CGFloat B;
    [color getRed: &R green: &G blue: &B alpha: nil];
    CGFloat dValue = THREEMAX(R, G, B) - THREEMIN(R, G, B);
    
    if (R != G && R != B && B != G) {
        while (colorDistances > 0) {
            if (R >= G && R > B) {
                if (G > B) {
                    if (G - colorDistances * dValue * 6 / lenth >= B) {
                        G -= colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances -= (G - B) / dValue * lenth / 6;
                        G = B;
                    }
                }
                if (G <= B) {
                    if (B + colorDistances * dValue * 6 / lenth <= R) {
                        B += colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances -= (R - B) / dValue * lenth / 6;
                        B = R;
                    }
                }
            }
            if (B >= R && B > G) {
                if (R > G) {
                    if (R - colorDistances * dValue * 6 / lenth >= G) {
                        R -= colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances -=  (R - G) / dValue * lenth / 6;
                        R = G;
                    }
                }
                if (R <= G) {
                    if (G + colorDistances * dValue * 6 / lenth <= B) {
                        G += colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances -= (B - G) / dValue * lenth / 6;
                        G = B;
                    }
                }
            }
            if (G >= B && G > R) {
                if (B > R) {
                    if (B - colorDistances * dValue * 6 / lenth >= R) {
                        B -= colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances -= (B - R) / dValue * lenth / 6;
                        B = R;
                    }
                }
                if (B <= R) {
                    if (R + colorDistances * dValue * 6 / lenth <= G) {
                        R += colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances -= (G - R) / dValue * lenth / 6;
                        R = G;
                    }
                }
            }
        }
        while (colorDistances < 0) {
            if (R > G && R >= B) {
                if (B > G) {
                    if (B + colorDistances * dValue * 6 / lenth >= G) {
                        B += colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances += (B - G) / dValue * lenth / 6;
                        B = G;
                    }
                }
                if (B <= G) {
                    if (G - colorDistances * dValue * 6 / lenth <= R) {
                        G -= colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances += (R - G) / dValue * lenth / 6;
                        G = R;
                    }
                }
            }
            if (B > R && B >= G) {
                if (G > R) {
                    if (G + colorDistances * dValue * 6 / lenth >= R) {
                        G += colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances +=  (G - R) / dValue * lenth / 6;
                        G = R;
                    }
                }
                if (G <= R) {
                    if (R - colorDistances * dValue * 6 / lenth <= B) {
                        R -= colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances += (B - R) / dValue * lenth / 6;
                        R = B;
                    }
                }
            }
            if (G > B && G >= R) {
                if (R > B) {
                    if (R + colorDistances * dValue * 6 / lenth >= B) {
                        R += colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances += (R - B) / dValue * lenth / 6;
                        R = B;
                    }
                }
                if (R <= B) {
                    if (B - colorDistances * dValue * 6 / lenth <= G) {
                        B -= colorDistances * dValue * 6 / lenth;
                        colorDistances = 0;
                    } else {
                        colorDistances += (G - B) / dValue * lenth / 6;
                        B = G;
                    }
                }
            }
        }
    }
    
    CGFloat GR, GG, GB;
    GR = R; GG = G; GB = B;
    CGFloat gray = GRAY(R, G, B);
    CGFloat max = THREEMAX(R, G, B);
    CGFloat min = THREEMIN(R, G, B);
    
    if (gray != max && gray != min) {
        if (grayDistances != 0) {
            if (grayDistances < 0) {
                GR = R + grayDistances * (R - gray) / lenth * 2;
                GG = G + grayDistances * (G - gray) / lenth * 2;
                GB = B + grayDistances * (B - gray) / lenth * 2;
            } else {
                if ((1 - max) / (max - gray) <= min / (gray - min)) {
                    GR = R + grayDistances * (1 - max) * (R - gray) / (max - gray) / lenth * 2;
                    GG = G + grayDistances * (1 - max) * (G - gray) / (max - gray) / lenth * 2;
                    GB = B + grayDistances * (1 - max) * (B - gray) / (max - gray) / lenth * 2;
                } else {
                    GR = R + grayDistances * min * (R - gray) / (gray - min) / lenth * 2;
                    GG = G + grayDistances * min * (G - gray) / (gray - min) / lenth * 2;
                    GB = B + grayDistances * min * (B - gray) / (gray - min) / lenth * 2;
                }
            }
        }
    }
    
    CGFloat LR, LG, LB;
    LR = GR; LG = GG; LB = GB;
    if (lightDistences != 0) {
        if (lightDistences < 0) {
            LR = GR + lightDistences * GR / lenth * 2;
            LG = GG + lightDistences * GG / lenth * 2;
            LB = GB + lightDistences * GB / lenth * 2;
        } else {
            LR = GR + lightDistences * (1 - GR) / lenth * 2;
            LG = GG + lightDistences * (1 - GG) / lenth * 2;
            LB = GB + lightDistences * (1 - GB) / lenth * 2;
        }
    }
 
    UIColor *changedColor = [UIColor colorWithRed: LR green: LG blue: LB alpha: 1.0];
    return changedColor;
}

@end
