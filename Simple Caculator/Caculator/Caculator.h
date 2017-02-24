//
//  Operator.h
//  Caculator
//
//  Created by 吴韬 on 16/9/7.
//  Copyright © 2016年 吴韬. All rights reserved.
//
//  将数字与符号统一的类

#import <Foundation/Foundation.h>

typedef enum {
    TYPE_TERMINAL,
    TYPE_NUMBER,
    TYPE_OPERATOR,
    TYPE_ERROR,
}CaculatorType;

typedef enum {
    RESULT_CORRECT,
    RESULT_ERROR_DIVICED_ZERO,
    RESULT_ERROR_ROOT_ZERO,
    RESULT_ERROR_NEGATIVE_OPENROOT,
    RESULT_ERROR_INFINITY,
    RESULT_ERROR_NEGATIVE_INFINITY,
}ErrorType;

@interface Caculator : NSObject

@property (assign, nonatomic)long double number;
@property (assign, nonatomic)unichar symbol;
@property (assign, nonatomic)ErrorType error;
@property (assign, nonatomic)CaculatorType type;

@end
