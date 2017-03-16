//
//  WTIMainViewController.m
//  Caculator
//
//  Created by 吴韬 on 16/9/4.
//  Copyright © 2016年 吴韬. All rights reserved.
//
//

#import <AVFoundation/AVFoundation.h>
#import "WTIMainViewController.h"
#import "WTISettingViewController.h"
#import "WTICaculatorStore.h"
#import "WTICoverView.h"
#import "WTIRGBEngine.h"
#import "Setting.h"

#define DIVIDER 1
#define EX_HEIGHT 32
#define EX_DIVIDER 5
#define RST_HEIGHT 75
#define RES_COVER_HEIGHT 90

@interface WTIMainViewController ()

@property (assign, nonatomic) BOOL soundsOn;

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *seperateLine;
@property (weak, nonatomic) IBOutlet WTICoverView *resultCoverView;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *expressionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *expressionScrollView;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *powerButton;
@property (weak, nonatomic) IBOutlet UIButton *squareButton;
@property (weak, nonatomic) IBOutlet UIButton *percentButton;
@property (weak, nonatomic) IBOutlet UIButton *divideButton;
@property (weak, nonatomic) IBOutlet UIButton *multiplyButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *bracketButton;
@property (weak, nonatomic) IBOutlet UIButton *pointButton;

@property (weak, nonatomic) IBOutlet UIButton *zeroButton;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (weak, nonatomic) IBOutlet UIButton *twoButton;
@property (weak, nonatomic) IBOutlet UIButton *threeButton;
@property (weak, nonatomic) IBOutlet UIButton *fourButton;
@property (weak, nonatomic) IBOutlet UIButton *fiveButton;
@property (weak, nonatomic) IBOutlet UIButton *sixButton;
@property (weak, nonatomic) IBOutlet UIButton *sevenButton;
@property (weak, nonatomic) IBOutlet UIButton *eightButton;
@property (weak, nonatomic) IBOutlet UIButton *nineButton;

@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) WTICaculatorStore *caculatorStore;

@property (strong, nonatomic) UIMenuItem *printMenu;
@property (strong, nonatomic) UIMenuItem *pasteMenu;
@property (strong, nonatomic) UIMenuItem *resultMenu;
@property (strong, nonatomic) UIMenuController *pasteCopyMenuController;

@end

@implementation WTIMainViewController

CGFloat squareSideLengthMake(CGFloat screenWidth)
{
    screenWidth = screenWidth - DIVIDER * 3.0;
    screenWidth -= (int)screenWidth % 4;
    return screenWidth / 4.0;
}

CGFloat labelButtomMargin(CGFloat buttonHeight)
{
    return buttonHeight * 5 + DIVIDER * 4;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        _caculatorStore = [WTICaculatorStore shareString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self usersBasicSetting];
    [self adjustSubviewLocation];
    [self addPressGestureRecognizer];
    [self refreshButtonsStatus];
    [self refreshLabelText];
}


#pragma mark - Basic Setting

- (void)usersBasicSetting
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];

    //第一次加载
    if ([defaults boolForKey: firstLunchKey]) {
        [defaults setBool: YES forKey: soundsOnKey];
        [defaults setBool: NO forKey: colorReversedKey];
        [defaults setBool: NO forKey: historyCloseKey];
        [defaults setBool: YES forKey: historyViewHiddenKey];
        [defaults setInteger: DEFAULT_LEVEL forKey: colorLevelKey];
        UIColor *backgroundColor = DEFAULT_COLOR;
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject: backgroundColor];
        [defaults setObject: colorData forKey: backgroundColorKey];
        [defaults synchronize];
        NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *path = [documents stringByAppendingPathComponent:@"background.png"];
        [UIImagePNGRepresentation([self backgroundImage]) writeToFile: path atomically:YES];
    }
    
    NSData *colorData = [defaults objectForKey: backgroundColorKey];
    NSInteger colorLevel = [defaults integerForKey: colorLevelKey];
    BOOL soundOn = [defaults boolForKey: soundsOnKey];
    BOOL colorReversed = [defaults boolForKey: colorReversedKey];
    
    self.gradientLayer = [[CAGradientLayer alloc] init];

    
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData: colorData];
    [self settingChanged: backgroundColor colorLevel: colorLevel reverse: colorReversed soundOn: soundOn];
    
    self.gradientLayer.startPoint = CGPointMake(1, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    self.gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.backView.layer addSublayer: self.gradientLayer];
    
    _soundsOn = [defaults boolForKey: soundsOnKey];
}

- (void)settingChanged: (UIColor *)backgroundColor colorLevel: (NSInteger)colorLevel reverse: (BOOL)colorReversed soundOn:(BOOL)soundOn
{
    _soundsOn = soundOn;
    NSInteger direction;
    if (colorReversed) {direction = -1;} else {direction = 1;};
    CGFloat hOffset = H_OFFSET * colorLevel * LEVEL_RADIO * direction;
    CGFloat sOffset = S_OFFSET * colorLevel * LEVEL_RADIO;
    CGFloat bOffset = B_OFFSET * colorLevel * LEVEL_RADIO;
    UIColor *gradientColor = WTIRGB(hOffset, sOffset, bOffset, 1.0, backgroundColor);
    self.gradientLayer.colors = @[(__bridge id)backgroundColor.CGColor,(__bridge id)gradientColor.CGColor];
    
    [self refreshLabelText];
    [self refreshButtonsStatus];
}

- (UIImage *)backgroundImage
{
    UIGraphicsBeginImageContext(CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}


#pragma mark - Action

- (void)addPressGestureRecognizer
{
    UILongPressGestureRecognizer *clearLongPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget: self
                                               action: @selector(cleanAll:)];
    UILongPressGestureRecognizer *reverseLongPress = [[UILongPressGestureRecognizer alloc]
                                                    initWithTarget: self
                                                    action: @selector(reverseAll:)];
    UILongPressGestureRecognizer *countdownLongPress = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget: self
                                                      action: @selector(countdownAll:)];
    UILongPressGestureRecognizer *cleanUpBracketLongPress = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget: self
                                                      action: @selector(cleanUpInvaildBrackets:)];
    UILongPressGestureRecognizer *copyResultLongPress = [[UILongPressGestureRecognizer alloc]
                                                         initWithTarget: self
                                                         action: @selector(copyOrPasteResult:)];
    UITapGestureRecognizer *resultCoverViewTap = [[UITapGestureRecognizer alloc]
                                               initWithTarget: self
                                               action: @selector(coverViewTapped:)];
    UIPanGestureRecognizer *useResultOrLastExpressionSwipe = [[UIPanGestureRecognizer alloc]
                                                                initWithTarget:self action: @selector(useResultOrLastExpression:)];
    
    [self.cancelButton addGestureRecognizer: clearLongPress];
    [self.minusButton addGestureRecognizer: reverseLongPress];
    [self.divideButton addGestureRecognizer: countdownLongPress];
    [self.bracketButton addGestureRecognizer: cleanUpBracketLongPress];
    [self.resultCoverView addGestureRecognizer: resultCoverViewTap];
    [self.resultCoverView addGestureRecognizer: copyResultLongPress];
    [self.resultCoverView addGestureRecognizer: useResultOrLastExpressionSwipe];
}

- (IBAction)pushSettingInterface:(UIButton *)sender
{
    NSArray *subviews = self.view.subviews;
    
    self.settingButton.alpha = 0.0;
    
    for (UIView *view in subviews) {
        if (view != self.backView && view != self.settingButton) {
            [UIView beginAnimations: @"HideSubview" context: nil];
            [UIView setAnimationDuration: 0.4];
            [view setAlpha: 0.0];
            [UIView commitAnimations];
        } else if (view == self.settingButton) {
            [UIView beginAnimations: @"DisplaySettingButton" context: nil];
            [UIView setAnimationDuration: 0.4];
            [view setAlpha: 1.0];
            [UIView commitAnimations];
        }
    }
    
    WTISettingViewController *svc = [[WTISettingViewController alloc] init];
    svc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [svc reload];
    [self presentViewController: svc animated: YES completion:^{
        svc.settingButton.alpha = 1.0;
        self.settingButton.alpha = 0.0;
    }];
}

- (IBAction)actionCollection: (UIButton *)sender
{
    NSUInteger tag = sender.tag;
    [self displayWithSoundID: 1429];
    
    [self.caculatorStore inputDigitAndSymbolWithTag: tag]; //input方法完毕，才刷新Label
    [self refreshLabelText];
    [self refreshButtonsStatus];
    
    [self.caculatorStore removeUnuselessOperator];
    [self.caculatorStore resettingOperatorAndExpression];
    if ([self.caculatorStore appendExpressionCheck: self.expressionLabel.text]) {
        [self.caculatorStore appendOpreators: self.expressionLabel.text];
    } else {
        [self.caculatorStore replaceOpreators: self.expressionLabel.text];
    }
}

- (void)cleanAll: (UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        [self displayWithSoundID: 1001];
        [self.cancelButton setTitle: @"AC" forState: UIControlStateNormal];
        [self.caculatorStore appendExpression: self.expressionLabel.text];
        
        [self animationForSeperateLineTime: 0.2];
        if ([self.caculatorStore dynamicAnimationNeeded: self.expressionLabel.text])
        {
            [self animationForExpressionLabelDynamic: YES distance: self.expressionLabel.frame.size.width  time: 0.2];
            [self animationForResultLabelIfRefresh: 2 Type: frame_x distance: self.resultLabel.frame.size.width time: 0.2 toOtherSide:NO alphaChanged: YES dynamic: NO];
        } else {
            [self animationForExpressionLabelDynamic: YES distance: self.expressionLabel.frame.size.width  time: 0.2];
            [self animationForResultLabelIfRefresh: 2 Type: frame_x distance: 0 time: 0.2 toOtherSide: NO alphaChanged: YES dynamic: NO];
        }
        [self.caculatorStore clearAll];
        [self.caculatorStore resettingOperatorAndExpression];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.cancelButton setTitle: @"C" forState: UIControlStateNormal];
    }
}

- (void)countdownAll: (UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self displayWithSoundID: 1396];
        [self.caculatorStore countdownAll];
        [self refreshLabelText];
        [self refreshButtonsStatus];
        [self.caculatorStore appendOpreators: self.expressionLabel.text];
        [self.caculatorStore removeUnuselessOperator];
        [self.caculatorStore resettingOperatorAndExpression];
    }
}

- (void)reverseAll: (UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self displayWithSoundID: 1396];
        [self.caculatorStore reverseAll];
        [self refreshLabelText];
        [self refreshButtonsStatus];
        [self.caculatorStore removeUnuselessOperator];
        [self.caculatorStore resettingOperatorAndExpression];
        [self.caculatorStore appendOpreators: self.expressionLabel.text];
    }
}

- (void)cleanUpInvaildBrackets: (UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.caculatorStore cleanUpInvaildBrackets]) {
            [self displayWithSoundID: 1396];
        };
        [self refreshLabelText];
        [self refreshButtonsStatus];
        [self.caculatorStore removeUnuselessOperator];
        [self.caculatorStore resettingOperatorAndExpression];
        [self.caculatorStore appendOpreators: self.expressionLabel.text];
    }
}

- (void)copyOrPasteResult: (UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [gestureRecognizer locationInView: self.resultCoverView];
        [self.resultCoverView becomeFirstResponder];
        if ([self.caculatorStore operatorExistCheck: self.expressionLabel.text]) {
            [self addMenuItemWithResultMenuNeeded: YES];
        } else {
            [self addMenuItemWithResultMenuNeeded: NO];
        }
        [self.pasteCopyMenuController setTargetRect: CGRectMake(location.x, location.y, 0, 0) inView: self.resultCoverView];
        [self.pasteCopyMenuController setMenuVisible: YES animated: YES];
    }
}

- (void)useResultOrLastExpression: (UIPanGestureRecognizer *)gestureRecognizer
{
    static BOOL duringPan = NO;
    [self.pasteCopyMenuController setMenuVisible: NO animated: YES];
    [self.resultCoverView resignFirstResponder];
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged && !duringPan) {
        CGPoint location = [gestureRecognizer translationInView: self.resultCoverView];
        if (fabs(location.x) > 10 || fabs(location.y) > 10) {
            if (fabs(location.x) > fabs(location.y)) {
                if (location.x > 0) {
                    [self animataionAndOperationForSwipeRight];
                } else {
                    [self animataionAndOperationForSwipeLeft];
                }
            } else {
                if (location.y > 0) {
                    [self animataionAndOperationForSwipeDown];
                } else {
                    [self animataionAndOperationForSwipeUp];
                }
            }
        }
        duringPan = YES;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        duringPan = NO;
    }
}


#pragma mark - Animatation and History

- (void)animataionAndOperationForSwipeUp
{
    BOOL unTerminalExpression = [self.caculatorStore backToLastExpression];
    if (self.resultLabel.text.length == 0 || !unTerminalExpression) {
        [self animationForResultLabelIfRefresh: 0 Type: frame_y distance: -15 time: 0.1 toOtherSide: NO alphaChanged: NO dynamic:YES];
        [self displayWithSoundID: 1053];
    } else {
        [self displayWithSoundID: 1318];
        [self animationForSeperateLineTime: 0.15];
        [self animationForExpressionLabelDynamic: YES distance: self.expressionLabel.frame.size.width  time: 0.15];
        [self animationForResultLabelIfRefresh: 1 Type: frame_y distance: -30 time: 0.15 toOtherSide: YES alphaChanged: YES dynamic: YES];
    }
}

- (void)animataionAndOperationForSwipeDown
{
    if ([self.expressionLabel.text isEqualToString: [self.caculatorStore redundantSymbolCleanUp: self.resultLabel.text]] || self.expressionLabel.text.length == 0 || [self.caculatorStore error]) {
        [self animationForResultLabelIfRefresh: 0 Type: frame_y distance: 15 time: 0.1 toOtherSide: NO alphaChanged: NO dynamic:YES];
        [self displayWithSoundID: 1053];
    } else {
        [self displayWithSoundID: 1318];
        [self.caculatorStore removeUnuselessOperator];
        [self.caculatorStore resettingOperatorAndExpression];
        [self.caculatorStore caculateWithLastExpression];
        [self.caculatorStore appendOpreators: self.expressionLabel.text];
        [self.caculatorStore appendExpression: self.expressionLabel.text];
        [self animationForSeperateLineTime: 0.15];
        [self animationForExpressionLabelDynamic: YES distance: 30 time: 0.15];
        [self animationForResultLabelIfRefresh: 3 Type: frame_y distance: 30 time: 0.15 toOtherSide: NO alphaChanged: YES dynamic:NO];
    }
}

- (void)animataionAndOperationForSwipeLeft
{
    BOOL unTerminalOperator = [self.caculatorStore backToLastOperator];
    if (!unTerminalOperator) {
        BOOL unTerminalExpression = [self.caculatorStore backToLastExpression];
        if (!unTerminalExpression) {
            [self displayWithSoundID: 1053];
            [self animationForResultLabelIfRefresh: 0 Type: frame_x distance: -15 time: 0.1 toOtherSide: NO alphaChanged: NO dynamic: YES];
            return;
        } else {
            [self displayWithSoundID: 1318];
            [self animationForSeperateLineTime: 0.15];
            [self animationForExpressionLabelDynamic: YES distance: self.expressionLabel.frame.size.width  time: 0.15];
            [self animationForResultLabelIfRefresh: 1 Type: frame_y distance: -30 time: 0.15 toOtherSide: YES alphaChanged: YES dynamic: YES];
            return;
        }
    }
    [self displayWithSoundID: 1318];
    CGFloat distance = [self distanceForExpressionLabel];
    [self animationForSeperateLineTime: 0.15];
    [self animationForExpressionLabelDynamic: YES distance: distance time: 0.15];
    [self animationForResultLabelIfRefresh: 1 Type: frame_x distance: -30 time: 0.15 toOtherSide: NO alphaChanged: YES dynamic: NO];
}

- (void)animataionAndOperationForSwipeRight
{
    BOOL unTerminalExpression = [self.caculatorStore returnToNextExpression];
    if (!unTerminalExpression) {
        BOOL unTerminalOperator = [self.caculatorStore returnToNextOperator];
        if (!unTerminalOperator) {
            [self displayWithSoundID: 1053];
            [self animationForResultLabelIfRefresh: 0 Type: frame_x distance: 15 time: 0.1 toOtherSide: NO alphaChanged: NO dynamic: YES];
            return;
        } else {
            [self displayWithSoundID: 1318];
            CGFloat distance = [self distanceForExpressionLabel];
            [self animationForSeperateLineTime: 0.15];
            [self animationForExpressionLabelDynamic: YES distance: -distance time: 0.15];
            [self animationForResultLabelIfRefresh: 1 Type: frame_x distance: 30 time: 0.15 toOtherSide: NO alphaChanged: YES dynamic: NO];
            return;
        }
    }
    [self displayWithSoundID: 1318];
    CGFloat distance = [self distanceForExpressionLabel];
    [self animationForSeperateLineTime: 0.15];
    [self animationForExpressionLabelDynamic: YES distance: -distance time: 0.15];
    [self animationForResultLabelIfRefresh: 1 Type: frame_y distance: 30 time: 0.15 toOtherSide: YES alphaChanged: YES dynamic: YES];
}

- (void)animationForSeperateLineTime: (CGFloat)time
{
    [UIView animateWithDuration: time animations:^{
        self.seperateLine.alpha = 0.0;
    } completion:^(BOOL finished) {;
        [UIView animateWithDuration: time animations:^{
            self.seperateLine.alpha = 1.0;
        }];
    }];
}

- (void)animationForExpressionLabelDynamic: (BOOL)dynamicNeeded  distance: (CGFloat)distance time: (CGFloat)time
{
    [UIView animateWithDuration: time animations:^{
        self.expressionLabel.alpha = 0.0;
        if (dynamicNeeded) {
            [self changeFrame: self.expressionLabel Type: frame_x distance: distance];
        }
    } completion:^(BOOL finished) {
        if (dynamicNeeded) {
            [self changeFrame: self.expressionLabel Type: frame_x distance: -distance];
        }
        [UIView animateWithDuration: time animations:^{
            self.expressionLabel.alpha = 1.0;
        }];
    }];
}

- (void)animationForResultLabelIfRefresh: (NSInteger)methodNum Type: (FrameType)type distance: (CGFloat)distance time: (CGFloat)time toOtherSide: (BOOL)otherSide alphaChanged: (BOOL)alphaChanged dynamic: (BOOL)dynamic
{
    [UIView animateWithDuration: time animations:^{
        if (alphaChanged) {
            self.resultLabel.alpha = 0.0;
        }
        [self changeFrame: self.resultLabel Type: type distance: distance];
    } completion:^(BOOL finished) {
        if (dynamic) {
            if (otherSide) {
                [self changeFrame: self.resultLabel Type: type distance: - distance * 2];
            }
            [UIView animateWithDuration: time animations:^{
                if (alphaChanged) {
                    self.resultLabel.alpha = 1.0;
                }
                if (otherSide) {
                    [self changeFrame: self.resultLabel Type: type distance: distance];
                } else {
                    [self changeFrame: self.resultLabel Type: type distance: - distance];
                }
            }];
        } else {
            if (otherSide) {
                [self changeFrame: self.resultLabel Type: type distance: distance];
            } else {
                [self changeFrame: self.resultLabel Type: type distance: - distance];
            }
            [UIView animateWithDuration: time animations:^{
                if (alphaChanged) {
                    self.resultLabel.alpha = 1.0;
                }
            }];
        }
        if (methodNum > 0) {
            [self refreshLabelText];
            [self refreshButtonsStatus];
        }
        if (methodNum > 1) {
            [self.caculatorStore appendOpreators: self.expressionLabel.text];
        }
        if (methodNum > 2) {
            [self.caculatorStore appendExpression: self.expressionLabel.text];
        }
    }];
}

- (CGFloat)distanceForExpressionLabel
{
    CGFloat width = [self.expressionLabel sizeThatFits: CGSizeMake(CGFLOAT_MAX, 30)].width;
    NSAttributedString *attrString = self.expressionLabel.attributedText;
    self.expressionLabel.attributedText = [self formatExpressionLabelTextWith: self.caculatorStore.entryString];
    CGFloat newWidth = [self.expressionLabel sizeThatFits: CGSizeMake(CGFLOAT_MAX, 30)].width;
    self.expressionLabel.attributedText = attrString;
    return newWidth - width;
}

- (void)changeFrame: (UIView *)view Type: (FrameType)type distance: (CGFloat)distance
{
    CGRect rect = view.frame;
    switch (type) {
        case frame_x: rect.origin.x += distance;
            break;
        case frame_y: rect.origin.y += distance;
            break;
        case frame_width: rect.size.width += distance;
            break;
        case frame_height: rect.size.height += distance;
            break;
        default:
            break;
    }
    view.frame = rect;
}

- (void)coverViewTapped: (UITapGestureRecognizer *)gestureRecognizer
{
    if (self.pasteCopyMenuController.isMenuVisible) {
        [self.pasteCopyMenuController setMenuVisible: NO animated: YES];
        [self.resultCoverView resignFirstResponder];
    }
}

- (void)copyResult
{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string=self.resultLabel.text;
    [self.resultCoverView resignFirstResponder];
}

- (void)clipperPaste
{
    [self displayWithSoundID: 1318];
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [self.resultCoverView resignFirstResponder];
    [self.caculatorStore removeUnuselessOperator];
    [self.caculatorStore resettingOperatorAndExpression];
    [self.caculatorStore appendOpreators: self.expressionLabel.text];
    [self.caculatorStore cleanUpAndCaculatePasteExpression: pasteboard.string];
    [self animationForSeperateLineTime: 0.15];
    [self animationForExpressionLabelDynamic: NO distance: 0 time: 0.15];
    [self animationForResultLabelIfRefresh: 2 Type: frame_x distance: 0 time: 0.15 toOtherSide: NO alphaChanged: YES dynamic: NO];
}

- (void)useResult
{
    [self.resultCoverView resignFirstResponder];
    [self animataionAndOperationForSwipeDown];
}

- (void)addMenuItemWithResultMenuNeeded: (BOOL)resultMenuNeeded
{
    if (self.pasteCopyMenuController == nil) {
        self.pasteCopyMenuController = [UIMenuController sharedMenuController];
        self.pasteCopyMenuController.arrowDirection = UIMenuControllerArrowDown;
        self.printMenu = [[UIMenuItem alloc] initWithTitle: @"Copy" action: @selector(copyResult)];
        self.pasteMenu = [[UIMenuItem alloc] initWithTitle: @"Paste" action: @selector(clipperPaste)];
        self.resultMenu = [[UIMenuItem alloc] initWithTitle: @"Use Result" action: @selector(useResult)];
    }
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard.string.length) {
        if (!resultMenuNeeded) {
            self.pasteCopyMenuController.menuItems = @[self.printMenu, self.pasteMenu];
        } else {
            self.pasteCopyMenuController.menuItems = @[self.printMenu, self.pasteMenu, self.resultMenu];
        }
    } else {
        if (!resultMenuNeeded) {
            self.pasteCopyMenuController.menuItems = @[self.printMenu];
        } else {
            self.pasteCopyMenuController.menuItems = @[self.printMenu, self.resultMenu];
        }
    }
}

- (void)displayWithSoundID: (SystemSoundID)soundID
{
    //1001- 1057 1104i 1105 1123i 1125- 1155 1156 1306i 1318c 1361- 1396-- 1429
    // 1018 1051wall 1053wall 1303-- 1318-
    if (_soundsOn) {
        AudioServicesPlaySystemSound(soundID);
    }
}


#pragma mark - Buttons Control

- (void)refreshLabelText
{
    self.resultLabel.attributedText = [self formatResultLabelTextWith: self.caculatorStore.resultString];
    self.expressionLabel.attributedText = [self formatExpressionLabelTextWith: self.caculatorStore.entryString];
    [self refreshLabelLocation];
}

- (void)refreshButtonsStatus
{
    NSString *expression = self.caculatorStore.entryString;
    NSInteger length = [expression length];
    [self enableAllButtons];
    
    if (length == 0) {
        self.cancelButton.enabled = NO;
        [self turnBracketWithTag: 18];
    } else {
        NSString *theLastCharString = [expression substringFromIndex: length - 1];
        if ([@"ⁿ+-×÷(√" containsString: theLastCharString]) {
            if (self.bracketButton.tag != 18) {
                [self turnBracketWithTag: 18];
            }
            [self disableOperatorButtons];
            if (length == 1) {
                if ([theLastCharString isEqualToString: @"-"]) {
                    self.minusButton.enabled = NO;
                }
            } if (length > 1) {
                unichar lastChar = [expression characterAtIndex: length - 2];
                if (!isdigit(lastChar) && lastChar != '.' && lastChar != ')' && lastChar != '%') {
                    if (![theLastCharString isEqualToString: @"√"] && ![theLastCharString isEqualToString: @"("]) {
                        self.minusButton.enabled = NO;
                    }
                }
            }
        } else {
            if (self.bracketButton.tag != 19) {
                [self turnBracketWithTag: 19];
            }
        }
        NSInteger digitCounts = 0;
        for (NSInteger i = length - 1; i >= 0; i--) {
            unichar tmpChar = [expression characterAtIndex: i];
            if (isdigit(tmpChar)) {
                digitCounts++;
            } else if (tmpChar == '.') {
                self.pointButton.enabled = NO;
            } else {
                break;
            }
            if (digitCounts == 18) {
                [self disableDigitButtons];
                break;
            }
        }
    }
}

- (void)turnBracketWithTag: (NSUInteger)tag
{
    if (tag == 18) {
        self.bracketButton.tag = tag;
        [self.bracketButton setTitle: @"(" forState: UIControlStateNormal];
    } else {
        self.bracketButton.tag = tag;
        [self.bracketButton setTitle: @")" forState: UIControlStateNormal];
    }
}

- (void)disableDigitButtons
{
    for (UIButton *button in self.view.subviews) {
        if ((button.tag < 10 || button.tag == 20 )&& [button isKindOfClass: [UIButton class]]) {
            button.enabled = NO;
        }
    }
}

- (void)disableOperatorButtons
{
    for (UIButton *button in self.view.subviews) {
        if (button.tag >= 11 && button.tag <= 17 && button.tag != 16 && button.tag != 12) {
            button.enabled = NO;
        }
    }
}

- (void)enableAllButtons
{
    for (UIButton *button in self.view.subviews) {
        button.enabled = YES;
    }
}


#pragma mark - Frame Adjust

- (void)adjustSubviewLocation
{
    CGSize screenSize = SCREEN_SIZE;
    CGFloat length = squareSideLengthMake(screenSize.width);
    CGFloat buttomMargin = labelButtomMargin(length);
    self.backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.settingButton.frame = CGRectMake(SETTING_H_DIVIDER, SETTING_V_DIVIDER, SETTING_LENGTH, SETTING_LENGTH);
    [self.settingButton setEnlargeEdgeWithTop: 20.0 right: 20.0 bottom: 20.0 left: 20.0];
    
    [self adjustLocationWithButton: self.zeroButton     row: 0 column: 0 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.pointButton    row: 0 column: 1 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.bracketButton  row: 0 column: 2 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.plusButton     row: 0 column: 3 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.oneButton      row: 1 column: 0 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.twoButton      row: 1 column: 1 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.threeButton    row: 1 column: 2 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.minusButton    row: 1 column: 3 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.fourButton     row: 2 column: 0 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.fiveButton     row: 2 column: 1 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.sixButton      row: 2 column: 2 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.multiplyButton row: 2 column: 3 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.sevenButton    row: 3 column: 0 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.eightButton    row: 3 column: 1 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.nineButton     row: 3 column: 2 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.divideButton   row: 3 column: 3 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.cancelButton   row: 4 column: 0 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.powerButton    row: 4 column: 1 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.squareButton   row: 4 column: 2 width: length height: length inSize: screenSize];
    [self adjustLocationWithButton: self.percentButton  row: 4 column: 3 width: length height: length inSize: screenSize];
    
    [self adjustDisplayAreaLocationWithLabelButtomMargin: buttomMargin size: screenSize];
}

- (void)refreshLabelLocation
{
    //    CGRect expressionRect = [attributedString boundingRectWithSize: CGSizeMake(CGFLOAT_MAX, 30) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context: nil];
    
    //需要先更新attributedText，否则label的尺寸仍然是未更新值
    CGSize expressionSize = [self.expressionLabel sizeThatFits: CGSizeMake(CGFLOAT_MAX, 30)];
    
    if (expressionSize.width > SCREEN_WIDTH - EX_DIVIDER * 2) {
        CGRect rect = self.expressionScrollView.bounds;
        rect.origin.x = 0;
        rect.origin.y = 0;
        self.expressionScrollView.bounds = rect;
        rect.size.width = expressionSize.width;
        self.expressionScrollView.contentSize = rect.size;
        self.expressionScrollView.contentOffset = CGPointMake(rect.size.width - self.expressionScrollView.bounds.size.width, 0);
        //子控件的frame是相对于scrollView的contentSize而言的
        self.expressionLabel.frame = rect;
    } else {
        self.expressionScrollView.contentSize = CGSizeMake(0, 0);
        self.expressionLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH - EX_DIVIDER * 2, self.expressionLabel.frame.size.height);
    }
}

- (void)adjustDisplayAreaLocationWithLabelButtomMargin: (CGFloat)buttomMargin size: (CGSize)screenSize
{
    CGFloat ey = screenSize.height - buttomMargin - EX_HEIGHT;
    CGRect expressionLabelFrame = CGRectMake(0, 0, screenSize.width - EX_DIVIDER * 2, EX_HEIGHT);
    CGRect expressionScrollViewFrame = CGRectMake(EX_DIVIDER, ey, screenSize.width - EX_DIVIDER * 2, EX_HEIGHT);
    self.expressionLabel.frame = expressionLabelFrame;
    self.expressionScrollView.frame = expressionScrollViewFrame;
    self.expressionScrollView.contentSize = CGSizeMake(0, 0);
    self.expressionScrollView.showsHorizontalScrollIndicator = NO;
    
    self.seperateLine.frame = CGRectMake(0, ey - DIVIDER, screenSize.width, DIVIDER);
    
    CGFloat ry = ey - RST_HEIGHT - DIVIDER;
    CGRect resultLabelFrame = CGRectMake(EX_DIVIDER, ry, screenSize.width - EX_DIVIDER * 2, RST_HEIGHT);
    self.resultLabel.frame = resultLabelFrame;
    
    CGRect resultCoverFrame = self.resultLabel.frame;
    resultCoverFrame.size.height = RES_COVER_HEIGHT;
    resultCoverFrame.origin.y -= (RES_COVER_HEIGHT - RST_HEIGHT) * 0.5 + 15;
    self.resultCoverView.frame = resultCoverFrame;
}

- (void)adjustLocationWithButton: (UIButton *)button row: (NSInteger)row column: (NSInteger)column width: (CGFloat)width height: (CGFloat)height inSize: (CGSize)size
{
    CGFloat x;
    CGFloat gap = size.width - (width + DIVIDER) * 4;
    if (gap >= 2) {
        x = floorf(gap / 2) + column * (width + DIVIDER);
    } else {
        x = column * (width + DIVIDER);
    }
    CGFloat y = size.height - row * (height + DIVIDER) - height;
    CGRect currectFrame = CGRectMake(x, y, width, height);
    button.frame = currectFrame;
}


#pragma mark - Format Display

- (NSAttributedString *)formatResultLabelTextWith: (NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: string];
    NSInteger length = [string length];
    BOOL pointExist = NO;
    BOOL minusExist = NO;
    
    [attributedString addAttribute: NSFontAttributeName value: [UIFont fontWithName: @"HelveticaNeue-UltraLight" size: 75.0f] range: NSMakeRange(0, length)];
    
    for (NSInteger i = 0; i < length; i++) {
        NSString *tmpString = [string substringWithRange: NSMakeRange(i, 1)];
        if ([tmpString isEqualToString: @","]) {
            [attributedString addAttribute: NSFontAttributeName value:
             [UIFont fontWithName: @"HelveticaNeue-Light" size: 30.0f] range:NSMakeRange(i, 1)];
        } else if ([tmpString isEqualToString: @"."]) {
            pointExist = YES;
            [attributedString addAttribute: NSFontAttributeName value:
             [UIFont fontWithName: @"HelveticaNeue-Light" size: 30.0f] range:NSMakeRange(i, 1)];
        } else if ([tmpString isEqualToString: @"≈"]) {
            [attributedString addAttribute: NSKernAttributeName value: @(10) range: NSMakeRange(i, 1)];
        } else if ([tmpString isEqualToString: @"-"]) {
            minusExist = YES;
        }
    }
    return attributedString;
}

- (NSAttributedString *)formatExpressionLabelTextWith: (NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: string];
    NSInteger length = [string length];
    for (NSInteger i = 0; i < length; i++) {
        NSString *tmpString = [string substringWithRange: NSMakeRange(i, 1)];
        if ([@"+-×÷" containsString: tmpString]) {
            NSDictionary *attributes = @{NSKernAttributeName: @(3),
                                         NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 18.0f],
                                         NSBaselineOffsetAttributeName: @(1)};
            [attributedString setAttributes: attributes range: NSMakeRange(i, 1)];
            
        } else if ([tmpString isEqualToString: @"."]) {
            [attributedString addAttribute: NSFontAttributeName value:
             [UIFont fontWithName: @"HelveticaNeue-Light" size: 15.0f] range:NSMakeRange(i, 1)];
        } else {
            if (i + 1 < [string length]) {
                NSString *nextCharString = [string substringWithRange: NSMakeRange(i + 1, 1)];
                if ([@"+-×÷" containsString: nextCharString]) {
                    [attributedString addAttribute: NSKernAttributeName value: @(3) range: NSMakeRange(i, 1)];
                }
            }
        }
    }
    if (length != 0) {
        NSString *tmpString = [string substringWithRange: NSMakeRange(length - 1, 1)];
        if (![@"+-×÷" containsString: tmpString]) {
            [attributedString addAttribute: NSKernAttributeName value: @(3) range: NSMakeRange(length - 1, 1)];
        }
    }
    return attributedString;
}



@end
