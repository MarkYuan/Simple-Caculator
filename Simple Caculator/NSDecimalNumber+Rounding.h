//
//  NSDecimalNumber+Rounding.h
//  Simple Caculator
//
//  Created by 吴韬 on 17/3/10.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (Rounding)

+ (NSDecimalNumber *)roundingDecimalNumber: (NSDecimalNumber *)decimalNumber scale: (short)scale;

@end
