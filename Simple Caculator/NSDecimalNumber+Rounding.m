//
//  NSDecimalNumber+Rounding.m
//  Simple Caculator
//
//  Created by 吴韬 on 17/3/10.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import "NSDecimalNumber+Rounding.h"

@implementation NSDecimalNumber (Rounding)

+ (NSDecimalNumber *)roundingDecimalNumber: (NSDecimalNumber *)decimalNumber scale: (short)scale;
{
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                      scale:scale
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    return [decimalNumber decimalNumberByRoundingAccordingToBehavior: roundingBehavior];
}


@end
