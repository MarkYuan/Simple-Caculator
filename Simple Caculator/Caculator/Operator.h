//
//  Operator_Basic.h
//  Caculator
//
//  Created by 吴韬 on 16/9/8.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Caculator.h"

typedef enum {
    PRIORITY_GRAND,
    PRIORITY_HIGH,
    PRIORITY_MEDIUM,
    PRIORITY_DEFAULT,
    PRIORITY_LOW,
}SymbolPriority;

typedef enum {
    OPERATOR_UNARY_PRE,
    OPERATOR_UNARY_POST,
    OPERATOR_BINARY_DEFAULT,
}OperatorType;

@interface Operator: NSObject

- (BOOL)caculate: (NSMutableArray *)caculatorsArray
                atIndex: (NSInteger)index
     ofOperatorPriority: (SymbolPriority)priority;

@end
