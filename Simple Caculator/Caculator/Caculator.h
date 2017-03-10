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
    RESULT_ERROR_OVER_FLOW,
    RESULT_ERROR_UNDER_FLOW,
    RESULT_ERROR_DIVICED_ZERO,
    RESULT_ERROR_ROOT_ZERO,
    RESULT_ERROR_NEGATIVE_OPENROOT,
}ErrorType;

@interface Caculator : NSObject

@property (strong, nonatomic)NSDecimalNumber *number;
@property (assign, nonatomic)BOOL rounded;
@property (assign, nonatomic)unichar symbol;
@property (assign, nonatomic)ErrorType error;
@property (assign, nonatomic)CaculatorType type;

@end
