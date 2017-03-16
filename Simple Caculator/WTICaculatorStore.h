//
//  WTICaculatorBrain.h
//  Caculator
//
//  Created by 吴韬 on 16/9/5.
//  Copyright © 2016年 吴韬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTICaculatorStore : NSObject

@property (strong, nonatomic) NSString *resultString;
@property (strong, nonatomic) NSString *entryString;

- (void)clearAll;
- (void)reverseAll;
- (void)countdownAll;
- (void)caculateWithLastExpression;
- (void)cleanUpAndCaculatePasteExpression: (NSString *)paste;
- (void)inputDigitAndSymbolWithTag: (NSUInteger)tag;
+ (instancetype)shareString;

- (BOOL)error;
- (BOOL)duringBrowseHistory;
- (BOOL)cleanUpInvaildBrackets;
- (BOOL)operatorExistCheck: (NSString *)expression;
- (BOOL)dynamicAnimationNeeded: (NSString *)expression;

- (void)saveData;
- (void)clearHistory;
- (void)appendOpreators: (NSString *)expression;
- (void)replaceOpreators: (NSString *)expression;
- (void)appendExpression: (NSString *)expression;

- (BOOL)backToLastOperator;
- (BOOL)backToLastExpression;
- (BOOL)returnToNextOperator;
- (BOOL)returnToNextExpression;
- (BOOL)appendExpressionCheck: (NSString *)expression;
- (NSString *)redundantSymbolCleanUp: (NSString *)expression;

- (void)removeUnuselessOperator;
- (void)resettingOperatorAndExpression;

- (NSMutableArray *)historyModels;
- (void)historySecletedAtIndexPath: (NSIndexPath *)indexPath;
- (void)deleteHistoryAtIndexPath: (NSIndexPath *)indexPath;

@end
