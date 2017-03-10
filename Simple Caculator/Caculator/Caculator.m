//
//  Operator.m
//  Caculator
//
//  Created by 吴韬 on 16/9/7.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import "Caculator.h"

@implementation Caculator

- (NSString *)description
{
    NSString *description;
    if (self.type == TYPE_NUMBER) {
        description = [NSString stringWithFormat: @"%@",self.number];
    } else if (self.type == TYPE_OPERATOR){
        description = [NSString stringWithFormat: @"%c", self.symbol];
    } else if (self.type == TYPE_ERROR) {
        switch (self.error) {
            case RESULT_ERROR_DIVICED_ZERO:
                description = @"Division by zero";
                break;
            case RESULT_ERROR_ROOT_ZERO:
                description = @"Open root by zero";
                break;
            case RESULT_ERROR_NEGATIVE_OPENROOT:
                description = @"Negative open root";
                break;
            case RESULT_ERROR_OVER_FLOW:
                description = @"Number is too big";
                break;
            case RESULT_ERROR_UNDER_FLOW:
                description = @"Number is too small";
                break;
            default:
                description = @"Unknow error";
                break;
        }
    } else {
        description = @"TerminalPoint";
    }
    return description;
}

@end
