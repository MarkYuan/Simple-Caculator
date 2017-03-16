//
//  WTIString.m
//  Simple Caculator
//
//  Created by 吴韬 on 17/3/12.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import "WTIString.h"

@interface WTIString() <NSCoding ,NSCopying>

@end

@implementation WTIString

static NSString * const stringKey = @"stringKey";

- (instancetype)initWithString: (NSString *)string
{
    self = [super init];
    if (self) {
        self.string = [string copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: self.string forKey: stringKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.string = [aDecoder decodeObjectForKey: stringKey];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    WTIString *newString = [[WTIString alloc] init];
    NSString *str = [self.string copy];
    newString.string = str;
    
    return newString;
}

@end
