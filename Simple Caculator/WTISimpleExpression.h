//
//  SimpleExpression.h
//  Caculator
//
//  Created by 吴韬 on 16/9/6.
//  Copyright © 2016年 吴韬. All rights reserved.
//
//该类用于提取字符串算式中数字与操作符

#import <Foundation/Foundation.h>

@interface WTISimpleExpression : NSObject

- (NSString *)formatOutputResult: (long double)result;
- (void)addProtectionCaculator: (NSMutableArray *)caculatorsArray;
- (NSMutableArray *)induceCaculatorsFromString: (NSString *)expression;

@end
