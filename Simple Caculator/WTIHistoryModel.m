//
//  WTIHistoryModel.m
//  Simple Caculator
//
//  Created by 吴韬 on 17/3/11.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import "WTIHistoryModel.h"

@interface WTIHistoryModel() <NSCoding>

@end

@implementation WTIHistoryModel

static NSString * const dateStringKey = @"dateStringKey";
static NSString * const expressionArrayKey = @"expressionArrayKey";

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.expressionArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: self.dateString forKey: dateStringKey];
    [aCoder encodeObject: self.expressionArray forKey: expressionArrayKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.dateString = [aDecoder decodeObjectForKey: dateStringKey];
        self.expressionArray = [aDecoder decodeObjectForKey:expressionArrayKey];
    }
    return self;
}

@end
