//
//  WTITableViewCell.m
//  Simple Caculator
//
//  Created by 吴韬 on 17/3/11.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import "WTITableViewCell.h"
#import "Setting.h"

@implementation WTITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellIdentifier = @"WTITableViewCell";
    WTITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (!cell) {
        cell = [[WTITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont fontWithName: @"HelveticaNeue-Light" size: 15.0f];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self modifiDeleteBtn];
}

-(void)modifiDeleteBtn{
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            subView.backgroundColor = [UIColor clearColor];
            for (UIButton *btn in subView.subviews) {
                if ([btn isKindOfClass:[UIButton class]]) {
                    btn.titleLabel.font =[UIFont fontWithName: @"HelveticaNeue-Light" size: 16.0f];
                }
            }
        }
    }
}

@end
