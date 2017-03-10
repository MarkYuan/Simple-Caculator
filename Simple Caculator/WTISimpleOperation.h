//
//  SimpleOperation.h
//  Caculator
//
//  Created by 吴韬 on 16/9/6.
//  Copyright © 2016年 吴韬. All rights reserved.
//
//  该类用于计算输入算式的结果

#import <Foundation/Foundation.h>

@interface WTISimpleOperation : NSObject

@property (nonatomic, strong) NSDecimalNumber *currentNumber;

- (NSString *)evaulateExpression: (NSString *)expression;

@end
