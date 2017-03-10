//
//  Operator_Basic.m
//  Caculator
//
//  Created by 吴韬 on 16/9/8.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import "Operator.h"
#import "Setting.h"

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
    NSDecimal lastNumber = lastCaculator.number.decimalValue;
    NSDecimal nextNumber = [NSDecimalNumber decimalNumberWithString: @"100.0"].decimalValue;
    NSDecimal result;
    
    NSCalculationError cAError = NSDecimalDivide(&result, &lastNumber, &nextNumber, NSRoundBankers);
    [self saveOperation: result caculator: caculator error: error errorType: cAError];
}

- (void)rootingCaculateBase: (Caculator *)nextCaculator
                     result: (Caculator *)caculator
                      error: (Caculator *)error
{
    if ([nextCaculator.number doubleValue] >= 0) {
        caculator.type = TYPE_NUMBER;
        double baseNumber = [nextCaculator.number doubleValue];
        double result = sqrt(baseNumber);
        [self saveOperation: result caculator: caculator error: error];
    } else {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_NEGATIVE_OPENROOT;
    }
}

- (void)reverseRootingCaculateBase: (Caculator *)nextCaculator
                            result: (Caculator *)caculator
                             error: (Caculator *)error
{
    if ([nextCaculator.number doubleValue] >= 0) {
        caculator.type = TYPE_NUMBER;
        double baseNumber = [nextCaculator.number doubleValue];
        double result = -sqrt(baseNumber);
        [self saveOperation: result caculator: caculator error: error];
    } else {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_NEGATIVE_OPENROOT;
    }
}

- (void)rootsCaculateWithRoot: (Caculator *)lastCaculator
                          base: (Caculator *)nextCaculator
                        result: (Caculator *)caculator
                        error: (Caculator *)error
{
    if (![lastCaculator.number compare: [NSDecimalNumber zero]]){
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_ROOT_ZERO;
    } else if ([nextCaculator.number doubleValue] >= 0) {
        caculator.type = TYPE_NUMBER;
        double baseNumber = [nextCaculator.number doubleValue];
        double rootNumber = [lastCaculator.number doubleValue];
        double result = pow(baseNumber, 1 / rootNumber);
        [self saveOperation: result caculator: caculator error: error];
    } else if ([nextCaculator.number doubleValue] < 0) {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_NEGATIVE_OPENROOT;
    }
}

- (void)powerCaculateWithExponent: (Caculator *)nextCaculator
                             base: (Caculator *)lastCaculator
                           result: (Caculator *)caculator
                            error: (Caculator *)error
{
    caculator.type = TYPE_NUMBER;

    if ([nextCaculator.number.stringValue containsString: @"."]) {
        double baseNumber = [lastCaculator.number doubleValue];
        double powerNumber = [nextCaculator.number doubleValue];
        double result = pow(baseNumber, powerNumber);
        [self saveOperation: result caculator: caculator error: error];
    } else {
        NSDecimal baseNumber;
        NSDecimal lastNumber = lastCaculator.number.decimalValue;
        if ([nextCaculator.number doubleValue] < 0 && [lastCaculator.number compare: [NSDecimalNumber zero]]) {
            NSDecimal one = [NSDecimalNumber decimalNumberWithString: @"1"].decimalValue;
            NSDecimalDivide(&baseNumber, &one, &lastNumber, NSRoundBankers);
        } else {
            baseNumber = lastNumber;
        }
        NSUInteger powerNumber = (NSUInteger)fabs([nextCaculator.number doubleValue]);
        NSDecimal result;
        NSCalculationError cAError = NSDecimalPower(&result, &baseNumber, powerNumber, NSRoundBankers);
        [self saveOperation: result caculator: caculator error: error errorType: cAError];
    }
}

- (void)multiplyCaculateWith: (Caculator *)lastCaculator
                        next: (Caculator *)nextCaculator
                      result: (Caculator *)caculator
                       error: (Caculator *)error
{
    NSDecimal lastNumber = lastCaculator.number.decimalValue;
    NSDecimal nextNumber = nextCaculator.number.decimalValue;
    NSDecimal result;
    
    NSCalculationError cAError = NSDecimalMultiply(&result, &lastNumber, &nextNumber, NSRoundBankers);
    [self saveOperation: result caculator: caculator error: error errorType: cAError];
}

- (void)divideCaculateWith: (Caculator *)lastCaculator
                      next: (Caculator *)nextCaculator
                    result: (Caculator *)caculator
                     error: (Caculator *)error
{
    NSDecimal lastNumber = lastCaculator.number.decimalValue;
    NSDecimal nextNumber = nextCaculator.number.decimalValue;
    NSDecimal result;
    
    NSCalculationError cAError = NSDecimalDivide(&result, &lastNumber, &nextNumber, NSRoundBankers);
    [self saveOperation: result caculator: caculator error: error errorType: cAError];
}

- (void)plusCaculateWith: (Caculator *)lastCaculator
                    next: (Caculator *)nextCaculator
                  result: (Caculator *)caculator
                   error: (Caculator *)error
{
    NSDecimal lastNumber = lastCaculator.number.decimalValue;
    NSDecimal nextNumber = nextCaculator.number.decimalValue;
    NSDecimal result;
    
    NSCalculationError cAError = NSDecimalAdd(&result, &lastNumber, &nextNumber, NSRoundBankers);
    [self saveOperation: result caculator: caculator error: error errorType: cAError];
}

- (void)reverseCaculateWith: (Caculator *)nextCaculator
                     result: (Caculator *)caculator
                      error: (Caculator *)error
{
    NSDecimal lastNumber = [NSDecimalNumber zero].decimalValue;
    NSDecimal nextNumber = nextCaculator.number.decimalValue;
    NSDecimal result;
    
    NSCalculationError cAError = NSDecimalSubtract(&result, &lastNumber, &nextNumber, NSRoundBankers);
    [self saveOperation: result caculator: caculator error: error errorType: cAError];
}

- (void)minusCaculateWith: (Caculator *)lastCaculator
                     next: (Caculator *)nextCaculator
                   result: (Caculator *)caculator
                    error: (Caculator *)error
{
    NSDecimal lastNumber = lastCaculator.number.decimalValue;
    NSDecimal nextNumber = nextCaculator.number.decimalValue;
    NSDecimal result;
    
    NSCalculationError cAError = NSDecimalMultiply(&result, &lastNumber, &nextNumber, NSRoundBankers);
    [self saveOperation: result caculator: caculator error: error errorType: cAError];
}


#pragma mark - Saving & Error Check

- (void)saveOperation: (double)result caculator: (Caculator *)caculator error: (Caculator *)error
{
    if (result < [NSDecimalNumber maximumDecimalNumber].doubleValue &&
        result > [NSDecimalNumber minimumDecimalNumber].doubleValue) {
        NSDecimalNumber *currentNumber = [NSDecimalNumber decimalNumberWithDecimal:
                                          [NSNumber numberWithDouble: result].decimalValue];
        caculator.number = [NSDecimalNumber roundingDecimalNumber: currentNumber scale: 11];
        if ([currentNumber compare: caculator.number]) {
            error.rounded = YES;
        }
    } else {
        error.type = TYPE_ERROR;
        error.error = RESULT_ERROR_OVER_FLOW;
    }
}

- (void)saveOperation: (NSDecimal)decimal caculator: (Caculator *)caculator error: (Caculator *)error errorType: (NSCalculationError)cAError
{
    switch (cAError) {
        case NSCalculationNoError:
            caculator.type = TYPE_NUMBER;
            caculator.number = [NSDecimalNumber decimalNumberWithDecimal: decimal];
            break;
        case NSCalculationLossOfPrecision:
            caculator.type = TYPE_NUMBER;
            caculator.number = [NSDecimalNumber decimalNumberWithDecimal: decimal];
            break;
        case NSCalculationUnderflow:
            error.type = TYPE_ERROR;
            error.error = RESULT_ERROR_UNDER_FLOW;
            break;
        case NSCalculationOverflow:
            error.type = TYPE_ERROR;
            error.error = RESULT_ERROR_OVER_FLOW;
            break;
        case NSCalculationDivideByZero:
            error.type = TYPE_ERROR;
            error.error = RESULT_ERROR_DIVICED_ZERO;
            break;
        default:
            caculator.type = TYPE_NUMBER;
            caculator.number = [NSDecimalNumber decimalNumberWithDecimal: decimal];
            break;
    }
}


@end
