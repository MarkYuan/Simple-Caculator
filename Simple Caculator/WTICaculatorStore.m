//
//  WTICaculatorBrain.m
//  Caculator
//
//  Created by 吴韬 on 16/9/5.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import "WTICaculatorStore.h"
#import "Setting.h"
#import "WTISimpleOperation.h"

@interface WTICaculatorStore()
{
    BOOL _lastExpression;
    NSInteger _operatorIndex;
    NSInteger _expressionIndex;
}

@property (strong, nonatomic) WTISimpleOperation *simpleOperation;
@property (strong, nonatomic) NSMutableString *expressionString;
@property (strong, nonatomic) NSMutableString *trendResultString;
@property (strong, nonatomic) NSMutableArray *operatorsArray;
@property (strong, nonatomic) NSMutableArray *expressionArray;

@end

@implementation WTICaculatorStore

- (instancetype)initPrivite
{
    self = [super init];
    if (self) {
        _simpleOperation = [[WTISimpleOperation alloc] init];
        _expressionString = [[NSMutableString alloc] init];
        _trendResultString = [[NSMutableString alloc] initWithString: @"0"];
        _expressionArray = [NSKeyedUnarchiver unarchiveObjectWithFile: [self historyPathAtDocuments]];
        _operatorsArray = [[NSMutableArray alloc] init];
        if (_expressionArray == nil) {
            _expressionArray = [[NSMutableArray alloc] init];
        }
        _lastExpression = NO;
        _operatorIndex = 0;
        _expressionIndex = 0;
    }
    return self;
}

+ (instancetype)shareString
{
    static WTICaculatorStore *caculatorBrain = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        caculatorBrain = [[WTICaculatorStore alloc] initPrivite];
    });
    return caculatorBrain;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName: @"Singleton" reason: @"use + [WTICaculatorBrain shareString]" userInfo: nil];
    return nil;
}


#pragma mark - History

- (void)appendExpression: (NSString *)expression
{
    if ([self.expressionArray count]) {
        NSString *lastExpression = [self.expressionArray lastObject];
        if (![lastExpression isEqualToString: expression]) {
            [self.expressionArray addObject: [expression copy]];
        }
    } else {
        [self.expressionArray addObject: [expression copy]];
    }
}

- (void)appendOpreators: (NSString *)expression
{
    if ([self.operatorsArray count]) {
        NSString *lastOperator = [self.operatorsArray lastObject];
        if (![lastOperator isEqualToString: expression]) {
            [self.operatorsArray addObject: [expression copy]];
        }
    } else {
        [self.operatorsArray addObject: [expression copy]];
    }
}

- (void)replaceOpreators: (NSString *)expression
{
    [self.operatorsArray replaceObjectAtIndex: self.operatorsArray.count - 1 withObject: [expression copy]];
}

- (void)clearHistory
{
    [self.operatorsArray removeAllObjects];
    [self.expressionArray removeAllObjects];
    [self clearAll];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bRet = [fileMgr fileExistsAtPath: [self historyPathAtDocuments]];
    if (bRet) {
        NSError *err;
        [fileMgr removeItemAtPath: [self historyPathAtDocuments] error:&err];
    }
}

- (void)saveData
{
    if (self.operatorsArray.count) {
        NSString *lastOperation = [self.operatorsArray lastObject];
        if (self.expressionArray.count) {
            NSString *lastExpression = [self.expressionArray lastObject];
            if (![lastOperation isEqualToString: lastExpression] && lastOperation.length) {
                [self.expressionArray addObject: [lastOperation copy]];
            }
        }
    }
    [NSKeyedArchiver archiveRootObject: self.expressionArray toFile: [self historyPathAtDocuments]];
}

- (NSString *)historyPathAtDocuments
{
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path = [documents stringByAppendingPathComponent:@"expression.archiver"];
    return path;
}

- (BOOL)backToLastOperator
{
    NSInteger count = [self.operatorsArray count];
    if (_operatorIndex < count - 1 && _expressionIndex == 0) {
        _operatorIndex ++;
        [self.expressionString setString: [self.operatorsArray objectAtIndex: count - _operatorIndex - 1]];
        if (self.expressionString.length) {
            [self doSimpleOperaction];
        } else {
            [self clearAll];
        }
        return YES;
    }
    return NO;
}

- (BOOL)backToLastExpression
{
    NSInteger count = [self.expressionArray count];
    if (_expressionIndex < count) {
        _expressionIndex ++;
        [self.expressionString setString: [self.expressionArray objectAtIndex: count - _expressionIndex]];
        if (self.expressionString.length) {
            [self doSimpleOperaction];
        } else {
            [self clearAll];
        }
        return YES;
    }
    return NO;
}

- (BOOL)returnToNextOperator
{
    NSInteger count = [self.operatorsArray count];
    if (_lastExpression) {
        _lastExpression = NO;
        if (self.operatorsArray.count) {
            [self.expressionString setString: [self.operatorsArray objectAtIndex: count - _operatorIndex - 1]];
            if (self.expressionString.length) {
                [self doSimpleOperaction];
            } else {
                [self clearAll];
            }
            return YES;
        }
        return NO;
    }
    if (_operatorIndex < count && _operatorIndex > 0) {
        _operatorIndex --;
        [self.expressionString setString: [self.operatorsArray objectAtIndex: count - _operatorIndex - 1]];
        if (self.expressionString.length) {
            [self doSimpleOperaction];
        } else {
            [self clearAll];
        }
        return YES;
    }
    return NO;
}

- (BOOL)returnToNextExpression
{
    NSInteger count = [self.expressionArray count];
    if (_expressionIndex <= count && _expressionIndex > 1) {
        _expressionIndex --;
        [self.expressionString setString: [self.expressionArray objectAtIndex: count - _expressionIndex]];
        if (self.expressionString.length) {
            [self doSimpleOperaction];
        } else {
            [self clearAll];
        }
        return YES;
    }
    if (_expressionIndex == 1) {
//        if (self.operatorsArray.count) {
//            _operatorIndex = self.operatorsArray.count - 1;
//            _expressionIndex = 0;
//        }
        _expressionIndex = 0;
        _lastExpression = YES;
    }
    return NO;
}

- (void)resettingOperatorAndExpression
{
    if (_operatorIndex != 0 || _expressionIndex != 0) {
        _operatorIndex = 0;
        _expressionIndex = 0;
    }
}

- (void)removeUnuselessOperator
{
    if (_expressionIndex) {
        return;
    }
    if (_operatorIndex > 0) {
        NSInteger count = [self.operatorsArray count];
        if (count - _operatorIndex > 0) {
            [_operatorsArray removeObjectsInRange: NSMakeRange(count - _operatorIndex, _operatorIndex)];
        }
    }
}


#pragma mark - Tap Events

- (void)inputDigitAndSymbolWithTag: (NSUInteger)tag
{
    [self expressionPretreatWithTag: tag];
    if (tag < 10) {
        [self.expressionString appendFormat: @"%lu", (unsigned long)tag];
    } else {
        switch (tag) {
            case cancel:       [self removeLastCharacter];
                break;
            case power:        [self.expressionString appendString: @"ⁿ"];
                break;
            case square:       [self.expressionString appendString: @"√"];
                break;
            case percent:      [self.expressionString appendString: @"%"];
                break;
            case divide:       [self.expressionString appendString: @"÷"];
                break;
            case multiply:     [self.expressionString appendString: @"×"];
                break;
            case minus:        [self.expressionString appendString: @"-"];
                break;
            case plus:         [self.expressionString appendString: @"+"];
                break;
            case leftBracket:  [self.expressionString appendString: @"("];
                break;
            case rightBracket: [self.expressionString appendString: @")"];
                break;
            case point:        [self.expressionString appendString: @"."];
                break;
            default:
                break;
        }
    }
    [self bracketsPretreat];
    [self doSimpleOperaction];
}

- (void)doSimpleOperaction
{
    [self.trendResultString setString: [self.simpleOperation evaulateExpression: self.expressionString]];
}

- (void)removeLastCharacter
{
    NSInteger length = [self.expressionString length];
    if (length > 0) {
        unichar theLastChar = [self.expressionString characterAtIndex: length - 1];
        if (theLastChar == ')') {
            NSInteger leftBracketCounts = 0;
            NSInteger rightBracketCounts = 0;
            for (NSInteger i = 0; i < length; i++) {
                unichar tmpChar = [self.expressionString characterAtIndex: i];
                if (tmpChar == '(') {
                    leftBracketCounts ++;
                } else if (tmpChar == ')') {
                    rightBracketCounts ++;
                }
            }
            unichar firstChar = [self.expressionString characterAtIndex: 0];
            if (leftBracketCounts == rightBracketCounts && firstChar == '(' && theLastChar == ')') {
                [self determineBracketDeleteRange: self.expressionString];
            } else {
                BOOL finish;
                NSInteger leftBracket = 0;
                NSInteger rightBracket = 0;
                NSInteger lastLeftBracket = 0;
                NSInteger lastRightBracket = 0;
                NSInteger lastInvaildLeftBracket = 0;
                NSInteger lastInvaildRightBracket = 0;
                NSMutableString *tempExpression = [NSMutableString stringWithString: self.expressionString];
                NSInteger length = [tempExpression length];
                do {
                    finish = YES;
                    for (NSInteger i = 0; i < length; i++) {
                        unichar cauChar = [tempExpression characterAtIndex: i];
                        if (cauChar == '(') {
                            leftBracket = i;
                        } else if (cauChar == ')') {
                            rightBracket = i;
                
                            if (leftBracket == lastLeftBracket - 1 && rightBracket == lastRightBracket + 1) {
                                lastInvaildLeftBracket = leftBracket;
                                lastInvaildRightBracket = rightBracket;
                            }
                            
                            NSRange leftBracketRange = {leftBracket, 1};
                            NSRange rightBracketRange = {rightBracket, 1};
                            [tempExpression replaceCharactersInRange: leftBracketRange withString: @"["];
                            [tempExpression replaceCharactersInRange: rightBracketRange withString: @"]"];
                            lastLeftBracket = leftBracket;
                            lastRightBracket = rightBracket;
                            leftBracket = 0;
                            rightBracket = 0;
                            finish = NO;
                            break;
                        }
                    }
                } while (!finish);
                
                if (lastInvaildRightBracket == length - 1 && lastInvaildRightBracket != 0){
                    NSRange deleteRange = {length - 1, 1};
                    [self.expressionString deleteCharactersInRange: deleteRange];
                    deleteRange.location = lastInvaildLeftBracket;
                    [self.expressionString deleteCharactersInRange: deleteRange];
                } else {
                    NSRange deleteRange = {length - 1, 1};
                    [self.expressionString deleteCharactersInRange: deleteRange];
                }
            }
        } else {
            NSRange deleteRange = {length - 1, 1};
            [self.expressionString deleteCharactersInRange: deleteRange];
        }
    }
}


#pragma mark - Operators Collection

- (void)clearAll
{
    [self.expressionString setString: @""];
    [self.trendResultString setString: @"0"];
}

- (void)reverseAll
{
    [self rightBracketsSupplement];
    
    BOOL shouldDelete = NO;
    if ([self.expressionString hasPrefix: @"-("]) {
        NSInteger theLastDidit = -1;
        NSInteger theLastRightBracket = 0;
        NSInteger length = [self.expressionString length];
        for (NSInteger i = 0; i < length; i++) {
            unichar tmpChar = [self.expressionString characterAtIndex: i];
            if (tmpChar == ')') {
                theLastRightBracket = i;
            } else if (isdigit(tmpChar) || tmpChar == '.' || tmpChar == '%') {
                theLastDidit = i;
            }
        }
        if (theLastRightBracket > 0 && theLastRightBracket > theLastDidit) {
            shouldDelete = YES;
            NSRange deleteRange = {theLastRightBracket, 1};
            [self.expressionString deleteCharactersInRange: deleteRange];
            deleteRange.location = 0;
            deleteRange.length = 2;
            [self.expressionString deleteCharactersInRange: deleteRange];
        }
    } else if ([self.expressionString hasPrefix: @"-"]) {
        if ([self confirmInvaildBracketsExistWith: self.expressionString] || ![self lowPriorityLevelExistForMinus: self.expressionString]) {
            NSRange deleteRange = {0, 1};
            [self.expressionString deleteCharactersInRange: deleteRange];
            shouldDelete = YES;
        }
    }
    if (!shouldDelete) {
        NSInteger theLastDigit = -1;
        NSInteger length = [self.expressionString length];
        for (NSInteger i = 0; i < length; i++) {
            unichar tmpChar = [self.expressionString characterAtIndex: i];
            if (isdigit(tmpChar) || tmpChar == '.' || tmpChar == '%') {
                theLastDigit = i;
            }
        }
        if (theLastDigit >= 0) {
            if ([self confirmInvaildBracketsExistWith: self.expressionString] || ![self lowPriorityLevelExistForMinus: self.expressionString]) {
                [self.expressionString insertString: @"-" atIndex: 0];
            } else {
                [self.expressionString insertString: @")" atIndex: theLastDigit + 1];
                [self.expressionString insertString: @"-(" atIndex: 0];
            }
        } else {
            [self.expressionString insertString: @"-" atIndex: 0];
        }
    }
 
    [self doSimpleOperaction];
}

- (void)countdownAll
{
    [self rightBracketsSupplement];
    
    BOOL shouldDelete = NO;
    if ([self.expressionString hasPrefix: @"1÷("]) {
        NSInteger theLastDidit = -1;
        NSInteger theLastRightBracket = 0;
        NSInteger length = [self.expressionString length];
        for (NSInteger i = 0; i < length; i++) {
            unichar tmpChar = [self.expressionString characterAtIndex: i];
            if (tmpChar == ')') {
                theLastRightBracket = i;
            } else if (isdigit(tmpChar) || tmpChar == '.' || tmpChar == '%') {
                theLastDidit = i;
            }
        }
        if (theLastRightBracket > 0 && theLastRightBracket > theLastDidit) {
            shouldDelete = YES;
            NSRange deleteRange = {theLastRightBracket, 1};
            [self.expressionString deleteCharactersInRange: deleteRange];
            deleteRange.location = 0;
            deleteRange.length = 3;
            [self.expressionString deleteCharactersInRange: deleteRange];
        }
    } else if ([self.expressionString hasPrefix: @"1÷"]) {
        if ([self confirmInvaildBracketsExistWith: self.expressionString]) {
            NSRange deleteRange = {0, 2};
            [self.expressionString deleteCharactersInRange: deleteRange];
            shouldDelete = YES;
        }
    }
    if (!shouldDelete) {
        
        NSInteger theLastDigit = -1;
        NSInteger length = [self.expressionString length];
        for (NSInteger i = 0; i < length; i++) {
            unichar tmpChar = [self.expressionString characterAtIndex: i];
            if (isdigit(tmpChar) || tmpChar == '.' || tmpChar == '%') {
                theLastDigit = i;
            }
        }
        if (theLastDigit >= 0) {
            if ([self confirmInvaildBracketsExistWith: self.expressionString] && ![self lowPriorityLevelExistForDivision: self.expressionString]) {
                [self.expressionString insertString: @"1÷" atIndex: 0];
            } else {
                [self.expressionString insertString: @")" atIndex: theLastDigit + 1];
                [self.expressionString insertString: @"1÷(" atIndex: 0];
            }
        } else {
            [self.expressionString insertString: @"1÷" atIndex: 0];
        }
    }
    
    [self doSimpleOperaction];
}

- (NSString *)redundantSymbolCleanUp: (NSString *)expression
{
    NSMutableString *tempExpression = [NSMutableString stringWithString: expression];
    NSInteger i = 0;
    BOOL finished = NO;
    BOOL pointExist = NO;
    
    do {
        NSInteger length = [tempExpression length];
        if (i < length) {
            NSString *subChar = [tempExpression substringWithRange: NSMakeRange(i, 1)];
            if (![@"0123456789e-" containsString: subChar]) {
                if ([subChar isEqualToString: @"."]) {
                    if (pointExist == NO) {
                        pointExist = YES;
                        i++;
                    }
                } else {
                    finished = NO;
                    [tempExpression deleteCharactersInRange: NSMakeRange(i, 1)];
                }
            } else {
                i++;
            }
        } else {
            finished = YES;
        }
    } while (!finished);
    return tempExpression;
}

- (void)cleanUpAndCaculatePasteExpression: (NSString *)expression
{
    NSMutableString *tempExpression = [NSMutableString stringWithString: expression];
    NSInteger i = 0;
    BOOL finished = NO;
    BOOL pointExist = NO;
    BOOL minusExist = NO;
    
    do {
        NSInteger length = [tempExpression length];
        if (i < length) {
            NSString *subChar = [tempExpression substringWithRange: NSMakeRange(i, 1)];
            if (![@"0123456789ⁿe×" containsString: subChar]) {
                if ([subChar isEqualToString: @"."]) {
                    if (pointExist == NO) {
                        pointExist = YES;
                        i++;
                    }
                } else {
                    if ([subChar isEqualToString: @"-"]) {
                        minusExist = YES;
                    }
                    finished = NO;
                    [tempExpression deleteCharactersInRange: NSMakeRange(i, 1)];
                }
            } else if ([@"e" isEqualToString: subChar]) {
                [tempExpression replaceCharactersInRange: NSMakeRange(i, 1) withString: @"×10ⁿ"];
                i += 3;
            } else {
                i++;
            }
        } else {
            finished = YES;
        }
    } while (!finished);
    
    if (pointExist) {
        if (tempExpression.length > 18) {
            NSRange pointRange = [tempExpression rangeOfString: @"."];
            [tempExpression deleteCharactersInRange: pointRange];
            NSInteger pointLoc = pointRange.location;
            
            NSInteger i = 0;
            if ([tempExpression hasPrefix: @"0"]) {
                BOOL finished = NO;
                do {
                    if ([tempExpression hasPrefix: @"0"]) {
                        [tempExpression deleteCharactersInRange: NSMakeRange(0, 1)];
                        i--;
                    } else {
                        finished = YES;
                    }
                } while (!finished);
            } else{
                i = pointLoc - 1;
            }
            
            [tempExpression insertString: @"." atIndex: 1];
            double exValue = [tempExpression doubleValue];
            tempExpression = [NSMutableString stringWithFormat: @"%.9lg", exValue];
            [tempExpression appendFormat: @"×10ⁿ%ld", (long)i];
        }
        
        if (minusExist) {
            [tempExpression insertString: @"-" atIndex: 0];
        }
    }
    [self caculatePasteExpression: tempExpression];
}

- (void)caculatePasteExpression: (NSString *)expression
{
    [self.expressionString setString: expression];
    [self bracketsPretreat];
    [self doSimpleOperaction];
}


#pragma mark - Pretreat

- (void)expressionPretreatWithTag: (NSUInteger)tag;
{
    NSInteger length = [self.expressionString length];
    if (length) {
        unichar theLastChar = [self.expressionString characterAtIndex: length - 1];
        if (theLastChar == ')' && tag < 10) {
            [self.expressionString appendString: @"×"];
        } else if (theLastChar == ')' && tag == 20) {
            [self.expressionString appendString: @"×0"];
        } else if (!isdigit(theLastChar) && tag == 20) {
            [self.expressionString appendString: @"0"];
        } else if (theLastChar == '.' && tag > 10) {
            [self.expressionString appendString: @"0"];
        } else if (theLastChar == '%' && tag < 10) {
            [self.expressionString appendString: @"×"];
        } else if ([self.expressionString isEqualToString: @"0"] && tag == 0) {
            [self.expressionString setString: @""];
        }
    } else {
        if (tag >= 11 && tag <= 15 && tag != 12) {
            [self.expressionString insertString: @"1" atIndex: 0];
        } else if (tag == 20) {
            [self.expressionString appendString: @"0"];
        }
    }
}

- (void)bracketsPretreat
{
    NSInteger leftBracketCount = 0;
    NSInteger rightBracketCount = 0;
    NSInteger length = [self.expressionString length];
    for (NSInteger i = 0; i < length; i++) {
        unichar tmpChar = [self.expressionString characterAtIndex: i];
        if (tmpChar == '(') {
            leftBracketCount ++;
        } else if (tmpChar == ')') {
            rightBracketCount ++;
        }
    }
    if (leftBracketCount < rightBracketCount) {
        for (NSInteger i = 0; i < rightBracketCount - leftBracketCount; i++) {
            [self.expressionString insertString: @"(" atIndex: 0];
        }
    }
}


#pragma mark - Simple Method

- (BOOL)cleanUpInvaildBrackets
{
    [self rightBracketsSupplement];
    BOOL finish;
    NSInteger leftBracket = 0;
    NSInteger rightBracket = 0;
    NSInteger lastLeftBracket = 0;
    NSInteger lastRightBracket = 0;
    NSMutableString *tempExpression = [NSMutableString stringWithString: self.expressionString];
    do {
        finish = YES;
        NSInteger length = [tempExpression length];
        for (NSInteger i = 0; i < length; i++) {
            unichar tmpChar = [tempExpression characterAtIndex: i];
            if (tmpChar == '(') {
                leftBracket = i;
            } else if (tmpChar == ')') {
                rightBracket = i;
    
                NSRange leftBracketRange = {leftBracket, 1};
                NSRange rightBracketRange = {rightBracket, 1};
                
                if (leftBracket == lastLeftBracket - 1 && rightBracket == lastRightBracket + 1) {
                    [tempExpression replaceCharactersInRange: rightBracketRange withString: @""];
                    [tempExpression replaceCharactersInRange: leftBracketRange withString: @""];
                    leftBracket = 0;
                    rightBracket = 0;
                    lastLeftBracket -= 1;
                    lastRightBracket -= 1;
                    finish = NO;
                    break;
                }
                
                [tempExpression replaceCharactersInRange: leftBracketRange withString: @"["];
                [tempExpression replaceCharactersInRange: rightBracketRange withString: @"]"];
                lastLeftBracket = leftBracket;
                lastRightBracket = rightBracket;
                leftBracket = 0;
                rightBracket = 0;
                finish = NO;
                break;
            }
        }
    } while (!finish);
    
    NSRange compareRange = {0, [tempExpression length]};
    [self replaceBracketWith: tempExpression range: compareRange];
    
    unichar firstChar = [tempExpression characterAtIndex: 0];
    unichar theLastChar = [tempExpression characterAtIndex: [tempExpression length] - 1];

    if (firstChar == '(' && theLastChar == ')') {
        [self determineBracketDeleteRange: tempExpression];
    }
    
    compareRange.location = 0;
    compareRange.length = [tempExpression length];
    [self replaceBracketWith: tempExpression range: compareRange];
    
    BOOL invaildBracketsExist = NO;
    
    if (self.expressionString.length != tempExpression.length) {
        invaildBracketsExist = YES;
    }
    [self.expressionString setString: tempExpression];

    return invaildBracketsExist;
}

- (void)rightBracketsSupplement
{
    NSInteger leftBracketCount = 0;
    NSInteger rightBracketCount = 0;
    NSInteger lastDigitLocation = 0;
    NSInteger length = [self.expressionString length];
    if (length > 0) {
        for (NSInteger i = 0; i < length; i++) {
            unichar tmpChar = [self.expressionString characterAtIndex: i];
            if (tmpChar == '(') {
                leftBracketCount ++;
            } else if (tmpChar == ')') {
                rightBracketCount ++;
            } else if (isdigit(tmpChar) || tmpChar == '.') {
                lastDigitLocation = i;
            }
        }
        unichar tmpChar = [self.expressionString characterAtIndex: length - 1];
        if (tmpChar == '.') {
            [self.expressionString appendString: @"0"];
            lastDigitLocation ++;
        }
        if (leftBracketCount > rightBracketCount) {
            if (lastDigitLocation != 0) {
                for (NSInteger i = 0; i < leftBracketCount - rightBracketCount; i++) {
                    [self.expressionString insertString: @")" atIndex: lastDigitLocation + 1];
                }
            } else {
                for (NSInteger i = 0; i < leftBracketCount - rightBracketCount; i++) {
                    [self.expressionString appendString: @")"];
                }
            }
        }
    }
}

- (BOOL)confirmInvaildBracketsExistWith: (NSString *)expression
{
    NSMutableString *tempExpression = [NSMutableString stringWithString: expression];
    if ([tempExpression length] != 0) {
        if ([tempExpression hasPrefix: @"-"]) {
            NSRange deleteRange = {0, 1};
            [tempExpression deleteCharactersInRange: deleteRange];
        } else if ([tempExpression hasPrefix: @"1÷"]) {
            NSRange deleteRange = {0, 2};
            [tempExpression deleteCharactersInRange: deleteRange];
        }
    }
    [self induceBracketsWithString: tempExpression];
    NSInteger length = [tempExpression length];
    if (length == 0) {
        return YES;
    } else {
        for (NSInteger i = 0; i < [tempExpression length]; i++) {
            NSRange tempRange = {i, 1};
            NSString *subString = [tempExpression substringWithRange: tempRange];
            if ([@"+-×÷√" containsString: subString]) {
                return NO;
            }
        }
        return YES;
    }
}

- (BOOL)lowPriorityLevelExistForMinus: (NSString *)expression
{
    NSMutableString *tempExpression = [NSMutableString stringWithString: expression];
    if ([tempExpression length] != 0) {
        if ([tempExpression hasPrefix: @"-"]) {
            NSRange deleteRange = {0, 1};
            [tempExpression deleteCharactersInRange: deleteRange];
        }
    }
    return [self lowPriorityLevelExistForDivision: tempExpression];
}

- (BOOL)lowPriorityLevelExistForDivision: (NSString *)expression
{
    NSMutableString *tempExpression = [NSMutableString stringWithString: expression];
    for (NSInteger i = 0; i < [tempExpression length]; i++) {
        NSRange tempRange = {i, 1};
        NSString *subString = [tempExpression substringWithRange: tempRange];
        if ([@"+-" containsString: subString]) {
            return YES;
        }
    }
    return NO;
}

- (void)induceBracketsWithString: (NSMutableString *)expression
{
    BOOL finish;
    NSInteger leftBracket = 0;
    NSInteger rightBracket = 0;
    do {
        finish = YES;
        NSInteger length = [expression length];
        for (NSInteger i = 0; i < length; i++) {
            unichar cauChar = [expression characterAtIndex: i];
            if (cauChar == '(') {
                leftBracket = i;
            } else if (cauChar == ')') {
                rightBracket = i;
                if (leftBracket < rightBracket) {
                    NSRange coupleBracketsRange = {leftBracket, rightBracket - leftBracket + 1};
                    [expression replaceCharactersInRange: coupleBracketsRange withString: @""];
                    leftBracket = 0;
                    rightBracket = 0;
                    finish = NO;
                    break;
                }
            }
        }
    } while (!finish);
}

- (void)determineBracketDeleteRange: (NSMutableString *)expression
{
    NSMutableString *tempExpression = [NSMutableString stringWithString: expression];
    NSInteger length = [tempExpression length];
    NSRange leftBracketRange = {0, 1};
    NSRange rightBracketRange = {length - 1, 1};
    [tempExpression replaceCharactersInRange: leftBracketRange withString: @"["];
    [tempExpression replaceCharactersInRange: rightBracketRange withString: @"]"];
    
    [self induceBracketsWithString: tempExpression];
    BOOL bracketExist = [self bracketExist: tempExpression];
    
    length = [expression length];
    if (bracketExist) {
        NSRange deleteRange = {length - 1, 1};
        [expression deleteCharactersInRange: deleteRange];
    } else {
        NSRange deleteRange = {length - 1, 1};
        [expression deleteCharactersInRange: deleteRange];
        deleteRange.location = 0;
        [expression deleteCharactersInRange: deleteRange];
    }
}

- (void)replaceBracketWith: (NSMutableString *)expression range: (NSRange)compareRange
{
    [expression replaceOccurrencesOfString: @"["
                                withString: @"("
                                   options: NSCaseInsensitiveSearch
                                     range: compareRange];
    [expression replaceOccurrencesOfString: @"]"
                                withString: @")"
                                   options: NSCaseInsensitiveSearch
                                     range: compareRange];
}

- (BOOL)bracketExist: (NSString *)expression
{
    for (NSInteger i = 0; i < [expression length]; i++) {
        unichar tmpChar = [expression characterAtIndex: i];
        if (tmpChar == '(' || tmpChar == ')') {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Output Kinds Check

- (BOOL)dynamicAnimationNeeded:(NSString *)expression
{
    NSInteger length = [expression length];
    for (NSInteger i = 0; i < length; i++) {
        NSString *subChar = [expression substringWithRange: NSMakeRange(i, 1)];
        if ([@"ⁿ+-×÷√%" containsString: subChar]) {
            return YES;
            break;
        }
    }
    return NO;
}

- (BOOL)operatorExistCheck: (NSString *)expression
{
    NSInteger length = [expression length];
    for (NSInteger i = 0; i < length; i++) {
        NSString *subChar = [expression substringWithRange: NSMakeRange(i, 1)];
        if ([@"ⁿ+-×÷√%" containsString: subChar]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)symbolExistWith: (NSString *)expression
{
    if ([self.operatorsArray count] > 0) {
        NSString *lastExpression = [self.operatorsArray lastObject];
        if ([expression containsString: lastExpression]) {
            NSRange sameRange = [expression rangeOfString: lastExpression];
            NSMutableString *tempExpression = [NSMutableString stringWithString: expression];
            [tempExpression deleteCharactersInRange: sameRange];
            
            NSInteger length = [lastExpression length];
            if (length >= 1) {
                NSString *lastChar = [lastExpression substringFromIndex: length - 1];
                if (tempExpression.length == 1 && ![@"0123456789." containsString: lastChar]) {
                    return YES;
                }
            }
            length = [tempExpression length];
            for (NSInteger i = 0; i < length; i++) {
                NSString *subChar = [tempExpression substringWithRange: NSMakeRange(i, 1)];
                if (![@"0123456789." containsString: subChar]) {
                    return YES;
                }
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)duringBrowseHistory
{
    if (_operatorIndex != 0 || _expressionIndex != 0) {
        return YES;
    }
    return NO;
}

- (BOOL)error
{
    NSInteger length = [self.resultString length];
    for (NSInteger i = 0; i < length; i++) {
        unichar subChar = [self.resultString characterAtIndex: i];
        if (isdigit(subChar)) {
            return NO;
        }
    }
    return YES;
}


#pragma mark - Public String

- (NSString *)entryString
{
    return self.expressionString;
}

- (NSString *)resultString
{
    return self.trendResultString;
}


@end
