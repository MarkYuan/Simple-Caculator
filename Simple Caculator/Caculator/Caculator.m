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
        description = [NSString stringWithFormat: @"%Lf",self.number];
    } else if (self.type == TYPE_OPERATOR){
        description = [NSString stringWithFormat: @"%c", self.symbol];
    } else if (self.type == TYPE_ERROR) {
        if (self.error == RESULT_ERROR_DIVICED_ZERO) {
            description = @"Division by zero";
        } else if (self.error == RESULT_ERROR_ROOT_ZERO) {
            description = @"Open root by zero";
        } else if (self.error == RESULT_ERROR_NEGATIVE_OPENROOT) {
            description = @"Negative open root";
        } else if (self.error == RESULT_ERROR_INFINITY) {
            description = @"Positive infinity";
        } else if (self.error == RESULT_ERROR_NEGATIVE_INFINITY) {
            description = @"Negative infinity";
        }
        return @"Unknow error";
    } else {
        description = @"TerminalPoint";
    }
    return description;
}

@end
