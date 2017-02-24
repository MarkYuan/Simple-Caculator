//
//  SimpleOperation.m
//  Caculator
//
//  Created by 吴韬 on 16/9/6.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import "Caculator.h"
#import "Operator.h"
#import "WTISimpleOperation.h"
#import "WTISimpleExpression.h"

@interface WTISimpleOperation()

@property (strong, nonatomic) NSMutableString *recursionString;
@property (strong, nonatomic) Operator *operator;
@property (strong, nonatomic) WTISimpleExpression *simpleExpression;

@end

@implementation WTISimpleOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operator = [[Operator alloc] init];
        _recursionString = [[NSMutableString alloc] init];
        _simpleExpression = [[WTISimpleExpression alloc] init];
    }
    return self;
}

- (NSString *)evaulateExpression: (NSString *)expression
{
    [self pretreatExpressionWithString: expression];
    [self caculateByCoupleBrackets];
    return self.recursionString;
}


#pragma mark - Pretreat Expression

- (void)pretreatExpressionWithString: (NSString *)expression
{
    [self.recursionString setString: expression];
    if ([self.recursionString length] != 0) {
        if([self clearNoneDigitExpression]) {   //clear expression if it has't a digit
            [self replaceSpecialSymbol];
            [self removeInvalidEndOperator];    //remove invalid operator first then
            [self supplementRightBrackets];
        }
    } else {
        [self.recursionString setString: @"0"];
    }
}

- (BOOL)clearNoneDigitExpression
{
    BOOL digit = NO;
    NSInteger length = [self.recursionString length];
    for (NSInteger i = 0; i < length; i++) {
        unichar tmpChar = [self.recursionString characterAtIndex: i];
        if (isdigit(tmpChar)) {
            digit = YES;
            break;
        }
    }
    if (!digit) {
        [self.recursionString setString: @"0"];
    }
    return digit;
}

- (void)replaceSpecialSymbol
{
    NSRange compareRange = {0, [self.recursionString length]};
    
    [self.recursionString replaceOccurrencesOfString: @"ⁿ"
                                          withString: @"n"
                                             options: NSCaseInsensitiveSearch
                                               range: compareRange];
    [self.recursionString replaceOccurrencesOfString: @"√"
                                          withString: @"s"
                                             options: NSCaseInsensitiveSearch
                                               range: compareRange];
    [self.recursionString replaceOccurrencesOfString: @"×"
                                          withString: @"*"
                                             options: NSCaseInsensitiveSearch
                                               range: compareRange];
    [self.recursionString replaceOccurrencesOfString: @"÷"
                                          withString: @"/"
                                             options: NSCaseInsensitiveSearch
                                               range: compareRange];
}

- (void)removeInvalidEndOperator
{
    if ([self removeTheLastSymbol]) {
        [self removeInvalidEndOperator];
    }
}

- (BOOL)removeTheLastSymbol
{
    NSInteger length = [self.recursionString length];
    if ([self.recursionString length] >= 1) {
        unichar lastChar = [self.recursionString characterAtIndex: length - 1];
        lastChar = [self.recursionString characterAtIndex: [self.recursionString length] - 1];
        if (!isdigit(lastChar) && lastChar != '.' && lastChar != ')' && lastChar != '%') {
            [self.recursionString setString: [self.recursionString substringToIndex: [self.recursionString length] - 1]];
            return YES;
        }
    }
    return NO;
}

- (void)supplementRightBrackets
{
    NSInteger leftBracketCount = 0;
    NSInteger rightBracketCount = 0;
    NSInteger length = [self.recursionString length];
    for (NSInteger i = 0; i < length; i++) {
        unichar tmpChar = [self.recursionString characterAtIndex: i];
        if (tmpChar == '(') {
            leftBracketCount ++;
        } else if (tmpChar == ')') {
            rightBracketCount ++;
        }
    }
    if (leftBracketCount > rightBracketCount) {
        for (NSInteger i = 0; i < leftBracketCount - rightBracketCount; i++) {
            [self.recursionString appendString: @")"];
        }
    }
}


#pragma mark - Do Operation

//计算核心，首先将输入字符串归纳为数组，再从内向外依次计算括号内元素
- (void)caculateByCoupleBrackets
{
    BOOL finish;
    NSInteger leftBracket = 0;
    NSInteger rightBracket = 0;
    NSMutableArray *caculatorsArray = [self.simpleExpression induceCaculatorsFromString: self.recursionString];
    
    do {
        NSInteger counts = [caculatorsArray count];
        finish = YES;
        for (NSInteger i = 0; i < counts; i++) {
            Caculator *tempCau = [caculatorsArray objectAtIndex: i];
            if (tempCau.type == TYPE_OPERATOR && tempCau.symbol == '(') {
                leftBracket = i;
            } else if (tempCau.type == TYPE_OPERATOR && tempCau.symbol == ')') {
                rightBracket = i;
                
                NSRange subCaculatorsRange = {leftBracket + 1, rightBracket - leftBracket - 1}; //cast away bracket
                NSMutableArray *subCaculatorsArray = [NSMutableArray arrayWithArray:
                                [caculatorsArray subarrayWithRange: subCaculatorsRange]];
                [self.simpleExpression addProtectionCaculator: subCaculatorsArray];
                [self caculateBasicCaculatorsArray: subCaculatorsArray];

                Caculator *errorCau = [subCaculatorsArray firstObject];
                if (errorCau.error) {
                    [self.recursionString setString: [self checkError: errorCau.error]];
                     return;
                } else {
                    [subCaculatorsArray removeObjectAtIndex: 0];
                    [subCaculatorsArray removeLastObject];
                }
                subCaculatorsRange.location -= 1;
                subCaculatorsRange.length += 2; //add bracket
                [caculatorsArray replaceObjectsInRange: subCaculatorsRange withObjectsFromArray: subCaculatorsArray];
                leftBracket = 0;
                rightBracket = 0;
                finish = NO;
                break;
            }
        }
    } while (!finish);
    
    [self caculateBasicCaculatorsArray: caculatorsArray];
    Caculator *errorCau = [caculatorsArray firstObject];
    if (errorCau.error) {
        [self.recursionString setString: [self checkError: errorCau.error]];
        return;
    }
    Caculator *resultCau = [caculatorsArray objectAtIndex: 1];
    [self.recursionString setString: [self.simpleExpression formatOutputResult: resultCau.number]];
}

- (void)caculateBasicCaculatorsArray: (NSMutableArray *)subCaculatorsArray
{
    [self reverseTraversal: subCaculatorsArray ofOperatorPriority: PRIORITY_GRAND];
    [self forwardTraversal: subCaculatorsArray ofOperatorPriority: PRIORITY_HIGH];
    [self reverseTraversal: subCaculatorsArray ofOperatorPriority: PRIORITY_MEDIUM];
    [self forwardTraversal: subCaculatorsArray ofOperatorPriority: PRIORITY_DEFAULT];
    [self forwardTraversal: subCaculatorsArray ofOperatorPriority: PRIORITY_LOW];
}

- (void)forwardTraversal: (NSMutableArray *)caculatorsArray ofOperatorPriority: (SymbolPriority)priority
{
    NSInteger i = 0;
    BOOL finish;
    do {
        Caculator *errorCau = [caculatorsArray objectAtIndex: 0];
        if (errorCau.error) {
            return;
        }
        finish = YES;
        NSInteger count = [caculatorsArray count];
        for (; i < count; i++) {
            finish = NO;
            Caculator *caculator = [caculatorsArray objectAtIndex: i];
            if (caculator.type == TYPE_OPERATOR) {
                if([self.operator caculate: caculatorsArray atIndex: i ofOperatorPriority: priority]) {
                    i --;
                    break;
                }
            }
        }
    } while (!finish);
}

- (void)reverseTraversal: (NSMutableArray *)caculatorsArray ofOperatorPriority: (SymbolPriority)priority
{
    NSInteger i = [caculatorsArray count] - 1;
    BOOL finish;
    do {
        Caculator *errorCau = [caculatorsArray objectAtIndex: 0];
        if (errorCau.error) {
            return;
        }
        finish = YES;
        for (; i >= 0; i--) {
            finish = NO;
            Caculator *caculator = [caculatorsArray objectAtIndex: i];
            if (caculator.type == TYPE_OPERATOR) {
                if([self.operator caculate: caculatorsArray atIndex: i ofOperatorPriority: priority]) {
                    break;
                }
            }
        }
    } while(!finish);
}

- (NSString *)checkError: (ErrorType)errorType
{
    if (errorType == RESULT_ERROR_DIVICED_ZERO) {
        return @"Division by zero";
    } else if (errorType == RESULT_ERROR_ROOT_ZERO) {
        return @"Open root by zero";
    } else if (errorType == RESULT_ERROR_NEGATIVE_OPENROOT) {
        return @"Negative open root";
    } else if (errorType == RESULT_ERROR_INFINITY) {
        return @"Positive infinity";
    } else if (errorType == RESULT_ERROR_NEGATIVE_INFINITY) {
        return @"Negative infinity";
    }
    return @"Unknow error";
}

@end
