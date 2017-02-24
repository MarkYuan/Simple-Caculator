//
//  Operator_Basic.m
//  Caculator
//
//  Created by 吴韬 on 16/9/8.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import "Operator.h"

@implementation Operator

//有符号才会调用该方法，所以不必担心数组被过度计算
- (BOOL)caculate: (NSMutableArray *)caculatorsArray
                atIndex: (NSInteger)index
     ofOperatorPriority: (SymbolPriority)priority
{
    Caculator *error = [caculatorsArray firstObject];
    Caculator *caculator = [caculatorsArray objectAtIndex: index];
    Caculator *lastCaculator = [caculatorsArray objectAtIndex: index - 1];
    Caculator *nextCaculator = [caculatorsArray objectAtIndex: index + 1];
    OperatorType operatorType = OPERATOR_BINARY_DEFAULT; //default is binary

    unichar operator = caculator.symbol;
    if (priority == PRIORITY_GRAND) {
        if (operator == '+') {
            if (lastCaculator.type != TYPE_NUMBER) {
                operatorType = OPERATOR_UNARY_PRE;
            } else {
                return NO;
            }
        } else if (operator == '-') {
            if (lastCaculator.type != TYPE_NUMBER) {
                if (nextCaculator.symbol == 's' && nextCaculator.type == TYPE_OPERATOR ) {
                    caculator.symbol = '_';
                    return NO;
                } else {
                    operatorType = OPERATOR_UNARY_PRE;
                    [self reverseCaculateWith: nextCaculator result: caculator error: error];
                }
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    } else if (priority == PRIORITY_HIGH) {
        if (operator == '%') {
            operatorType = OPERATOR_UNARY_POST;
            [self percentCaculate: lastCaculator result: caculator error: error];
        } else {
            return NO;
        }
    } else if (priority == PRIORITY_MEDIUM) {
        if (operator == 's') {
            if (lastCaculator.type != TYPE_NUMBER) {
                if (lastCaculator.symbol == '_') {
                    [self reverseRootingCaculateBase: nextCaculator result: caculator error: error];
                } else {
                    operatorType = OPERATOR_UNARY_PRE; //decide root type
                    [self rootingCaculateBase: nextCaculator result: caculator error: error];
                }
            } else {
                [self rootsCaculateWithRoot: lastCaculator base: nextCaculator result: caculator error: error];
            }
        } else if (operator == 'n') {
            [self powerCaculateWithExponent: nextCaculator base: lastCaculator result: caculator error: error];
        } else {
            return NO;
        }
    } else if (priority == PRIORITY_DEFAULT) {
        if (operator == '*') {
            [self multiplyCaculateWith: lastCaculator next: nextCaculator result: caculator error: error];
        } else if (operator == '/') {
            [self divideCaculateWith: lastCaculator next: nextCaculator result: caculator error: error];
        } else {
            return NO;
        }
    } else {
        if (operator == '+') {
            if (lastCaculator.type == TYPE_NUMBER) {
                [self plusCaculateWith: lastCaculator next: nextCaculator result: caculator error: error];
            }
        } else if (operator == '-') {
            if (lastCaculator.type == TYPE_NUMBER) {
                [self minusCaculateWith: lastCaculator next: nextCaculator result: caculator error: error];
            }
        } else {
            return NO;
        }
    }
    
    if (!caculator.error) {
        [self refresh: caculatorsArray AtIndex: index with: operatorType];
    } else {
        Caculator *errorCau = [caculatorsArray objectAtIndex: 0];
        errorCau.error = caculator.error;
    }
    return YES;
}

- (void)refresh: (NSMutableArray *)caculatorsArray AtIndex: (NSInteger)index with: (OperatorType)operatorType;
{
    if (operatorType == OPERATOR_UNARY_PRE) {
        [caculatorsArray removeObjectAtIndex: index + 1];
    } else if (operatorType == OPERATOR_UNARY_POST) {
        [caculatorsArray removeObjectAtIndex: index - 1];
    } else if (operatorType == OPERATOR_BINARY_DEFAULT){
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex: index - 1];
        [indexSet addIndex: index + 1];
        [caculatorsArray removeObjectsAtIndexes: indexSet];
    }
}


# pragma mark - simple caculator

- (void)percentCaculate: (Caculator *)lastCaculator
                 result: (Caculator *)caculator
                  error: (Caculator *)error
{
    caculator.type = TYPE_NUMBER;
    long double divice = 100.0;
    caculator.number = lastCaculator.number / divice;
    [self infinityCheck: caculator error: error];
}

- (void)rootingCaculateBase: (Caculator *)nextCaculator
                     result: (Caculator *)caculator
                      error: (Caculator *)error
{
    if (nextCaculator.number >= 0) {
        caculator.type = TYPE_NUMBER;
        caculator.number = sqrt(nextCaculator.number);
    } else {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_NEGATIVE_OPENROOT;
    }
    [self infinityCheck: caculator error: error];
}

- (void)reverseRootingCaculateBase: (Caculator *)nextCaculator
                            result: (Caculator *)caculator
                             error: (Caculator *)error
{
    if (nextCaculator.number >= 0) {
        caculator.type = TYPE_NUMBER;
        caculator.number = -sqrt(nextCaculator.number);
    } else {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_NEGATIVE_OPENROOT;
    }
    [self infinityCheck: caculator error: error];
}

- (void)rootsCaculateWithRoot: (Caculator *)lastCaculator
                          base: (Caculator *)nextCaculator
                        result: (Caculator *)caculator
                        error: (Caculator *)error
{
    if (lastCaculator.number == 0){
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_ROOT_ZERO;
    } else if (nextCaculator.number >= 0) {
        caculator.type = TYPE_NUMBER;
        caculator.number = pow(nextCaculator.number, 1 / lastCaculator.number);
    } else if (nextCaculator.number < 0) {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_NEGATIVE_OPENROOT;
    }
    [self infinityCheck: caculator error: error];
}

- (void)powerCaculateWithExponent: (Caculator *)nextCaculator
                             base: (Caculator *)lastCaculator
                           result: (Caculator *)caculator
                            error: (Caculator *)error
{
    caculator.type = TYPE_NUMBER;
    caculator.number = powl(lastCaculator.number, nextCaculator.number);
    [self infinityCheck: caculator error: error];
}

- (void)multiplyCaculateWith: (Caculator *)lastCaculator
                        next: (Caculator *)nextCaculator
                      result: (Caculator *)caculator
                       error: (Caculator *)error
{
    caculator.type = TYPE_NUMBER;
    caculator.number = lastCaculator.number * nextCaculator.number;
    [self infinityCheck: caculator error: error];
}

- (void)divideCaculateWith: (Caculator *)lastCaculator
                      next: (Caculator *)nextCaculator
                    result: (Caculator *)caculator
                     error: (Caculator *)error
{
    if (nextCaculator.number != 0) {
        caculator.type = TYPE_NUMBER;
        caculator.number = lastCaculator.number / nextCaculator.number;
    } else {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_DIVICED_ZERO;
    }
    [self infinityCheck: caculator error: error];
}

- (void)plusCaculateWith: (Caculator *)lastCaculator
                    next: (Caculator *)nextCaculator
                  result: (Caculator *)caculator
                   error: (Caculator *)error
{
    caculator.type = TYPE_NUMBER;
    caculator.number = lastCaculator.number + nextCaculator.number;
    [self infinityCheck: caculator error: error];
}

- (void)reverseCaculateWith: (Caculator *)nextCaculator
                     result: (Caculator *)caculator
                      error: (Caculator *)error
{
    caculator.type = TYPE_NUMBER;
    caculator.number = - nextCaculator.number;
    [self infinityCheck: caculator error: error];
}

- (void)minusCaculateWith: (Caculator *)lastCaculator
                     next: (Caculator *)nextCaculator
                   result: (Caculator *)caculator
                    error: (Caculator *)error
{
    caculator.type = TYPE_NUMBER;
    caculator.number = lastCaculator.number - nextCaculator.number;
    [self infinityCheck: caculator error: error];
}

- (void)infinityCheck: (Caculator *)caculator error: (Caculator *)error
{
    if (caculator.number == INFINITY) {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_INFINITY;
    } else if (caculator.number == -INFINITY) {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_NEGATIVE_INFINITY;
    }
}

@end
