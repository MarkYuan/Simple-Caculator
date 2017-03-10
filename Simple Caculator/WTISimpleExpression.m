//
//  SimpleExpression.m
//  Caculator
//
//  Created by 吴韬 on 16/9/6.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import "WTISimpleExpression.h"
#import "Caculator.h"
#import "Setting.h"

@interface WTISimpleExpression()

@property (strong, nonatomic) NSMutableArray *caculatorsArray;
@property (strong, nonatomic) NSString *expressionString;

@end

@implementation WTISimpleExpression

- (instancetype)init
{
    self = [super init];
    if (self) {
        _caculatorsArray = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - pretreat

- (NSMutableArray *)induceCaculatorsFromString: (NSString *)expression
{
    self.expressionString = expression;
    [self.caculatorsArray removeAllObjects];
    
    NSInteger digitLoc = 0;
    NSInteger digitLen = 0;
    NSInteger length = [self.expressionString length];
    
    for (NSInteger i = 0; i < length; i++) {
        unichar cauChar = [self.expressionString characterAtIndex: i];
        if (isdigit(cauChar) || cauChar == '.') {
            digitLen += 1;
            if (i + 1 < length) {
                unichar nextChar = [self.expressionString characterAtIndex: i + 1];
                if (!isdigit(nextChar) && nextChar != '.') {
                    [self addDigitAt: digitLoc Length: digitLen];
                    digitLen = 0;
                }
            } else {
                [self addDigitAt: digitLoc Length: digitLen];
            }
        } else {
            [self addOperatorWithSymbol: cauChar];
            digitLoc = i + 1;
        }
    }
    [self addProtectionCaculator];
    return self.caculatorsArray;
}

- (void)addProtectionCaculator
{
    Caculator *startCau = [[Caculator alloc] init];
    Caculator *endCau = [[Caculator alloc] init];
    startCau.type = TYPE_TERMINAL;
    endCau.type = TYPE_TERMINAL;
    [self.caculatorsArray insertObject: startCau atIndex: 0];
    [self.caculatorsArray addObject: endCau];
}

- (void)addProtectionCaculator: (NSMutableArray *)caculatorsArray
{
    Caculator *startCau = [[Caculator alloc] init];
    Caculator *endCau = [[Caculator alloc] init];
    startCau.type = TYPE_TERMINAL;
    endCau.type = TYPE_TERMINAL;
    [caculatorsArray insertObject: startCau atIndex: 0];
    [caculatorsArray addObject: endCau];
}

- (void)addDigitAt: (NSInteger)digitLoc Length: (NSInteger)digitLen
{
    NSRange digitRange = {digitLoc, digitLen};
    NSString *digitString = [self.expressionString substringWithRange: digitRange];
    Caculator *tempCau = [[Caculator alloc] init];
    tempCau.type = TYPE_NUMBER;
    tempCau.number = [NSDecimalNumber decimalNumberWithString: digitString];
    [self.caculatorsArray addObject: tempCau];
}

- (void)addOperatorWithSymbol: (unichar)tmpChar
{
    Caculator *tempCau = [[Caculator alloc] init];
    tempCau.type = TYPE_OPERATOR;
    tempCau.symbol = tmpChar;
    [self.caculatorsArray addObject: tempCau];
}


#pragma mark - Format Output

- (NSString *)formatOutputResult: (NSDecimalNumber *)decimalNumber rounded: (BOOL)rounded
{
    double result = [decimalNumber doubleValue];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.roundingMode = NSNumberFormatterRoundHalfUp;
    numberFormatter.roundingIncrement = @0.00000000000000001;
    numberFormatter.exponentSymbol = @"#e";
    numberFormatter.formatWidth = 18;
    numberFormatter.maximumFractionDigits = 17;
    if (result >= 1 || result <= -1) {
        NSString *scientificString = [NSString stringWithFormat: @"%.19lg", result];
        if ([scientificString containsString: @"e"]) {
            numberFormatter.numberStyle = NSNumberFormatterScientificStyle;
            numberFormatter.maximumFractionDigits = 10;
        }
    }
    
    NSDecimalNumber *outputNumber = [decimalNumber copy];
    NSString *pointString = decimalNumber.stringValue;
    if ([pointString containsString: @"."]) {
        NSInteger pointLoc = [pointString rangeOfString: @"."].location;
        if (pointString.length >= 39) {
            short decimalLen = pointString.length - pointLoc - 2;
            outputNumber = [NSDecimalNumber roundingDecimalNumber: outputNumber scale: decimalLen];
        }
    }
      
    NSMutableString *decimalString = [NSMutableString stringWithString: outputNumber.stringValue];
    BOOL approximatelyEqualneeded = rounded;
    if ([decimalString containsString: @"."]) {
        NSInteger pointLoc = [decimalString rangeOfString: @"."].location;
        [decimalString deleteCharactersInRange: NSMakeRange(0, pointLoc + 1)];
        if (decimalString.length > 17) {
            [decimalString deleteCharactersInRange: NSMakeRange(0, 17)];
            for (NSInteger i = 0; i < decimalString.length; i++) {
                NSString *subString = [decimalString substringWithRange: NSMakeRange(i, 1)];
                if (![subString isEqualToString: @"0"]) {
                    approximatelyEqualneeded = YES;
                    break;
                }
            }
        }
    }
    
    NSMutableString *outputString = [NSMutableString stringWithString: [numberFormatter stringFromNumber: outputNumber]];
    [outputString replaceOccurrencesOfString: @" "
                                  withString: @""
                                     options: NSCaseInsensitiveSearch
                                       range: NSMakeRange(0, outputString.length)];
    [outputString replaceOccurrencesOfString: @"#"
                                  withString: @" "
                                     options: NSCaseInsensitiveSearch
                                       range: NSMakeRange(0, outputString.length)];
    if (![outputString containsString: @"."]) {
        [outputString insertString: @" " atIndex: 0];
    }
    if (approximatelyEqualneeded) {
        [outputString insertString: @"≈" atIndex: 0];
    }
    
    return outputString;
}


//- (NSString *)formatOutputResult: (long double)result
//{
//    NSMutableString *tempResultString;
//    if (result >= 1 || result <= -1) {
//        tempResultString = [NSMutableString stringWithFormat: @"%.19Lg", result];
//        NSLog(@"%@",tempResultString);
//        BOOL isNegative = [self removeMinusIfNegative: tempResultString];
//        BOOL approximatelyEqualneeded = NO;
//        NSInteger length = [tempResultString length];
//        NSInteger pointLoc = 0;
//        NSInteger eLoc = 0;
//        
//        for (NSInteger i = 0; i < length; i++) {
//            unichar tmpChar = [tempResultString characterAtIndex: i];
//            if (tmpChar == '.') {
//                pointLoc = i;
//            } else if (tmpChar == 'e') {
//                eLoc = i;
//                [tempResultString insertString: @" " atIndex: i];
//                i ++;
//            } else if (tmpChar == '+') {
//                NSRange deleteRange = {i, 1};
//                [tempResultString deleteCharactersInRange: deleteRange];
//                break;
//            }
//        }
//        
//        if (!eLoc && length >= 20 && pointLoc) {
//            approximatelyEqualneeded = YES;
//            [tempResultString deleteCharactersInRange: NSMakeRange(length - 1, 1)];
//        }
//        
//        if (pointLoc) {
//            if (eLoc - pointLoc > 9) {
//                NSRange digitRange = {0, eLoc};
//                NSString *digitString = [tempResultString substringToIndex: eLoc];
//                long double digit = [self longDoubleValueWith: digitString];
//                NSString *induceString = [NSString stringWithFormat: @"%.10Lg", digit]; //科学计数法表示的必有一位整数，Lg可删除末尾的0
//                [tempResultString replaceCharactersInRange: digitRange withString: induceString];
//            }
//            NSInteger comma = pointLoc - 3;
//            while (comma > 0) {
//                [tempResultString insertString: @"," atIndex: comma];
//                comma -= 3;
//                pointLoc ++;
//            }
//        } else {
//            NSInteger comma = [tempResultString length] - 3;
//            while (comma > 0) {
//                [tempResultString insertString: @"," atIndex: comma];
//                comma -= 3;
//            }
//            if (result >= 1) {
//                [tempResultString insertString: @" " atIndex: 0];
//            }
//        }
//        if (isNegative) {
//            [tempResultString insertString: @"-" atIndex: 0];
//        }
//        if (approximatelyEqualneeded) {
//            [tempResultString insertString: @"≈" atIndex: 0];
//        }
//        
//    } else if (result > LDBL_MIN || result < -LDBL_MIN) {
//        long double tempRes = result;
//        long double output = result;
//        tempRes *= powl(10, 16);
//        long double integer;
//        long double mecimal = modfl(tempRes, &integer);
//        if (mecimal >= 0.5) {
//            output += (1 - mecimal) * powl(0.1, 16);
//        }
//        tempResultString = [NSMutableString stringWithFormat: @"%.16Lf", output];
//        BOOL isNegative = [self removeMinusIfNegative: tempResultString];
//        BOOL stop = NO;
//        while (!stop) {
//            NSInteger length = [tempResultString length];
//            unichar theLastChar = [tempResultString characterAtIndex: length - 1];
//            if (theLastChar == '0' || theLastChar == '.') {
//                NSRange deleteRange = {length - 1, 1};
//                [tempResultString deleteCharactersInRange: deleteRange];
//                stop = NO;
//            } else {
//                stop = YES;
//            }
//        }
//        if ([tempResultString length] == 0) {
//            tempResultString = [NSMutableString stringWithString: @"≈0"];
//        } else {
//            result *= powl(10, 17);
//            long double integer;
//            long double mecimal = modfl(result, &integer);
//            int temp = (int)(mecimal * 10000);
//            float tempF = temp / 10.0;
//            float integerF;
//            float fifth = modff(tempF, &integerF);
//            if (fifth >= 0.5) {
//                result += (1.0 - fifth) * 0.0001;
//            }
//            NSMutableString *mecimalString = [NSMutableString stringWithFormat: @"%.4Lf", result];
//            NSInteger length = [mecimalString length];
//            for (NSInteger i = 0; i < length; i++) {
//                unichar tmpChar = [mecimalString characterAtIndex: i];
//                if (tmpChar == '.') {
//                    NSRange mecimalRange = {0, i + 1};
//                    [mecimalString deleteCharactersInRange: mecimalRange];
//                    break;
//                }
//            }
//            if (isNegative) {
//                [tempResultString insertString: @"-" atIndex: 0];
//            }
//            length = [mecimalString length];
//            for (NSInteger i = 0; i < length; i++) {
//                unichar tmpChar = [mecimalString characterAtIndex: i];
//                if (tmpChar != '0') {
//                    [tempResultString insertString: @"≈" atIndex: 0];
//                    break;
//                }
//            }
//        }
//    } else {
//        tempResultString = [NSMutableString stringWithString: @"0"];
//    }
//    return tempResultString;
//}

//- (long double)longDoubleValueWith: (NSString *)digitString
//{
//    BOOL pointPart = NO;
//    int digitCounts = 0;
//    long double value = 0.0;
//    long double valueDecimal = 0.0;
//    long double decimalTimes = 1.0;
//    for (int i = 0; i < [digitString length]; i++) {
//        unichar tmpChar = [digitString characterAtIndex: i];
//        if (isdigit(tmpChar)) {
//            if (!pointPart) {
//                value = value * 10 + tmpChar - '0';
//            } else {
//                decimalTimes *= 10;
//                valueDecimal = valueDecimal * 10 + tmpChar - '0';
//            }
//            digitCounts ++;
//        } else if (tmpChar == '.') {
//            pointPart = YES;
//        }
//        if (digitCounts == 18) {
//            break;
//        }
//    }
//    value += valueDecimal / decimalTimes;
//    return value;
//}

//- (BOOL)removeMinusIfNegative: (NSMutableString *)resultString
//{
//    unichar miunsChar = [resultString characterAtIndex: 0];
//    if (miunsChar == '-') {
//        NSRange miunsRange = {0, 1};
//        [resultString deleteCharactersInRange: miunsRange];
//        return YES;
//    }
//    return NO;
//}

@end
