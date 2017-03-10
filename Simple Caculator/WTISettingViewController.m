//
//  WTISettingViewController.m
//  Caculator
//
//  Created by 吴韬 on 17/2/6.
//  Copyright © 2017年 吴韬. All rights reserved.
//

#import "WTISettingViewController.h"
#import "WTIMainViewController.h"
#import "WTICaculatorStore.h"
#import "WTIRGBEngine.h"
#import "Setting.h"

#define LEVEL_RADIUS 5
#define HELP_LABEL_LAYOUT_DIVIDE 60
#define SLIDER_MARGIN_LAYOUT 58

@interface WTISettingViewController () <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL soundOn;
@property (assign, nonatomic) BOOL colorReversed;
@property (strong, nonatomic) UIColor *changedColor;
@property (strong, nonatomic) UIColor *temporaryColor;

@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@property (weak, nonatomic) IBOutlet UISlider *hueSlider;
@property (weak, nonatomic) IBOutlet UISlider *saturateSlider;
@property (weak, nonatomic) IBOutlet UISlider *brightSlider;

@property (weak, nonatomic) IBOutlet UIButton *level0;
@property (weak, nonatomic) IBOutlet UIButton *level1;
@property (weak, nonatomic) IBOutlet UIButton *level2;
@property (weak, nonatomic) IBOutlet UIButton *level3;
@property (weak, nonatomic) IBOutlet UIButton *level4;
@property (weak, nonatomic) IBOutlet UIButton *level5;
@property (weak, nonatomic) IBOutlet UIButton *level6;
@property (weak, nonatomic) IBOutlet UIButton *level7;
@property (strong, nonatomic) UIButton *lastLevel;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *ramdomButton;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UIButton *resettingButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseColorButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseSettingButton;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider6;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider7;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftHueMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightHueMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *helpLabelHightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *levelWidth;

@end

@implementation WTISettingViewController

static NSString *help = @"Simple Caculator calculates result automatically with expression. During typing, Simple Caculator reverse bracket, completing brackets intelligent.\n\nSome buttons have various functions:\n\nTap Clear Button to delete the last input or the couple of redundant brackets.\n\nLong press Clear Button to clear all.\n\nLong press Minus/Division button to reverse/count down the whole expression. \n\nLong press Bracket button to clear all redundant brackets.\n\n\nSome tips for result area:\n\nSwipe Left to Undo.Swipe Right to Redo.\n\nSwipe Down to start a new expression with the current result.\n\nSwipe Up to browse history.\n\n Hold on result area to copy, paste or use result.\n\n";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self basicSetting];
    [self deployAreaOfColorDisk];
}


#pragma mark - Basic Setting

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGSize helpLabelSize = [self.helpLabel sizeThatFits: CGSizeMake(SCREEN_WIDTH - HELP_LABEL_LAYOUT_DIVIDE, CGFLOAT_MAX)];
    self.helpLabelHightConstraint.constant = helpLabelSize.height;
    
    self.divider1.constant = (SCREEN_WIDTH - SLIDER_MARGIN_LAYOUT * 2  - LEVEL_RADIUS * 16) / 7.0;
    self.divider2.constant = self.divider1.constant;
    self.divider3.constant = self.divider1.constant;
    self.divider4.constant = self.divider1.constant;
    self.divider5.constant = self.divider1.constant;
    self.divider6.constant = self.divider1.constant;
    self.divider7.constant = self.divider1.constant;
}

- (void)basicSetting
{
    self.helpLabel.numberOfLines = 0;
    self.helpLabel.text = help;
    self.iconImage.layer.cornerRadius = self.iconImage.frame.size.width / 5.0;
    self.iconImage.layer.masksToBounds = YES;
    
    self.hueSlider.value = 0;
    self.brightSlider.value = 0;
    self.saturateSlider.value = 0;
    [self.hueSlider setThumbImage: [UIImage imageNamed: @"Thumb"] forState: UIControlStateNormal];
    [self.brightSlider setThumbImage: [UIImage imageNamed: @"Thumb"] forState: UIControlStateNormal];
    [self.saturateSlider setThumbImage: [UIImage imageNamed: @"Thumb"] forState: UIControlStateNormal];
    
    self.settingButton.alpha = 0.0;
    self.reverseSettingButton.alpha = 0.0;
    [self.settingButton setEnlargeEdgeWithTop: 20.0 right: 20.0 bottom: 20.0 left: 20.0];
    [self.reverseSettingButton setEnlargeEdgeWithTop: 20.0 right: 20.0 bottom: 20.0 left: 20.0];
    
    self.scrollView.delaysContentTouches = NO;
    
    _soundOn = [[NSUserDefaults standardUserDefaults] boolForKey: soundsOnKey];
    [self changeSoundsButtonTitle];
}

- (void)deployAreaOfColorDisk
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [self formatLevelButton: self.level0];
    [self formatLevelButton: self.level1];
    [self formatLevelButton: self.level2];
    [self formatLevelButton: self.level3];
    [self formatLevelButton: self.level4];
    [self formatLevelButton: self.level5];
    [self formatLevelButton: self.level6];
    [self formatLevelButton: self.level7];
    [self formatButtonShape: self.confirmButton];
    [self formatButtonShape: self.ramdomButton];
    
    NSInteger level = [defaults integerForKey: colorLevelKey];
    switch (level) {
        case 0: [self changeLevelButton: self.level0];
            break;
        case 1: [self changeLevelButton: self.level1];
            break;
        case 2: [self changeLevelButton: self.level2];
            break;
        case 3: [self changeLevelButton: self.level3];
            break;
        case 4: [self changeLevelButton: self.level4];
            break;
        case 5: [self changeLevelButton: self.level5];
            break;
        case 6: [self changeLevelButton: self.level6];
            break;
        case 7: [self changeLevelButton: self.level7];
            break;
        default:
            break;
    }
    
    _colorReversed = [defaults boolForKey: colorReversedKey];
    [self changeReverseButton];
}

- (void)formatButtonShape: (UIButton *)button
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1.0, 1.0, 1.0, 0.5});
    
    [button.layer setCornerRadius: 4.0];
    [button.layer setBorderWidth: 1.0];
    [button.layer setBorderColor: colorref];
    
    [button addTarget: self action: @selector(backgroundButtonTouched:) forControlEvents: UIControlEventTouchDown];
    [button addTarget: self action: @selector(backgroundButtonTapEnded:) forControlEvents: UIControlEventTouchUpInside];
}

- (void)formatLevelButton: (UIButton *)button
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1.0, 1.0, 1.0, 0.5});
    
    [button.layer setBorderWidth: 1.0];
    [button.layer setBorderColor: colorref];
    [button.layer setCornerRadius: LEVEL_RADIUS];
    
    [button setEnlargeEdgeWithTop: 8.0 right: 8.0 bottom: 8.0 left: 8.0];
}

- (void)changeReverseButton
{
    if (_colorReversed) {
        [self.reverseColorButton setImage: [UIImage imageNamed: @"ColorSymbol"]
                                 forState: UIControlStateNormal];
    } else {
        [self.reverseColorButton setImage: [UIImage imageNamed: @"ReverseColorSymbol"]
                                 forState: UIControlStateNormal];
    }
}

- (void)changeSoundsButtonTitle
{
    if (_soundOn) {
        [self.soundButton setTitle: @"Sounds On" forState: UIControlStateNormal];
    } else {
        [self.soundButton setTitle: @"Sounds Off" forState: UIControlStateNormal];
    }
}


#pragma mark - Event

- (void)backgroundButtonTouched: (UIButton *)button
{
    [button.layer setBorderWidth: 0.0];
    button.backgroundColor = UICOLOR(255, 255, 255, 0.5);
}

- (void)backgroundButtonTapEnded: (UIButton *)button
{
    [button.layer setBorderWidth: 1.0];
    button.backgroundColor = [UIColor clearColor];
}

- (void)changeLevelButton: (UIButton *)button
{
    button.selected = YES;
    [button.layer setBorderWidth: 0.0];
    button.backgroundColor = UICOLOR(255, 255, 255, 0.5);
    self.lastLevel = button;
}


#pragma mark - Action Collection

- (IBAction)returnMainInterface: (UIButton *)sender
{
    WTIMainViewController *mvc = [self rootController];
    NSArray *mvcSubviews = mvc.view.subviews;
    
    self.settingButton.alpha = 0.0;
    self.reverseSettingButton.alpha = 0.0;
    
    for (UIView *view in mvcSubviews) {
        [UIView beginAnimations: @"DisplaySubview" context: nil];
        [UIView setAnimationDuration: 0.4];
        [view setAlpha: 1.0];
        [UIView commitAnimations];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIColor *backgroundColor = [self backgroundColor];
    BOOL soundOn = [defaults boolForKey: soundsOnKey];
    BOOL colorReversed = [defaults boolForKey: colorReversedKey];
    NSInteger colorLevel = [defaults integerForKey: colorLevelKey];
    
    [mvc settingChanged: backgroundColor colorLevel: colorLevel reverse: colorReversed soundOn: soundOn];
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)sound:(UIButton *)sender
{
    _soundOn = !_soundOn;
    [self changeSoundsButtonTitle];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: _soundOn forKey: soundsOnKey];
    [defaults synchronize];
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    WTIMainViewController *mvc = [self rootController];
    if (self.temporaryColor == nil || self.changedColor == nil) {
        UIColor *backgroundColor = [self backgroundColor];
        self.changedColor = WTIRGB(self.hueSlider.value, self.saturateSlider.value, self.brightSlider.value, 1.0, backgroundColor);
    } else {
        self.changedColor = WTIRGB(self.hueSlider.value, self.saturateSlider.value, self.brightSlider.value, 1.0, self.temporaryColor);
    }
    [mvc settingChanged: self.changedColor colorLevel: self.lastLevel.tag reverse: _colorReversed soundOn: _soundOn];
}

- (IBAction)levelButtonSelected: (UIButton *)sender
{
    self.lastLevel.selected = NO;
    [self.lastLevel.layer setBorderWidth: 1.0];
    self.lastLevel.backgroundColor = [UIColor clearColor];
    [self changeLevelButton: sender];
    
    [self backgroundColorChanged];
}

- (IBAction)reverseColorChangeDirection: (UIButton *)sender
{
    _colorReversed = !_colorReversed;
    
    NSInteger derection;
    if (!_colorReversed) {derection = 1;} else {derection = -1;};
    
    CGAffineTransform  transform = CGAffineTransformRotate(sender.transform, M_PI/2 * derection);
    [UIView animateWithDuration: 0.3 animations:^{
        sender.alpha = 0.0;
        sender.transform = transform;
    } completion:^(BOOL finished) {
        CGAffineTransform transform = CGAffineTransformRotate(sender.transform, -M_PI/2 * derection);
        sender.transform = transform;
        [UIView animateWithDuration: 0.25 animations:^{
            sender.alpha = 1.0;
            [self changeReverseButton];
        }];
    }];
    
    [self backgroundColorChanged];
}

- (IBAction)ramdomColor:(UIButton *)sender
{
    self.hueSlider.value = 0;
    self.saturateSlider.value = 0;
    self.brightSlider.value = 0;
    
    WTIMainViewController *mvc = [self rootController];
    self.changedColor = RAMDOM_COLOR;
    self.temporaryColor = [self.changedColor copy];
    [mvc settingChanged: self.changedColor colorLevel: self.lastLevel.tag reverse: _colorReversed soundOn: _soundOn];
}

- (IBAction)confirm: (UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Background Color"
                                                                   message: @"Using the current background color?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action){
                                                        [self confirmBackgroundColor];
                                                    }];
    [alert addAction: cancel];
    [alert addAction: confirm];
    
    [self presentViewController: alert animated:YES completion:nil];
}

- (IBAction)clearHistory:(UIButton *)sender
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Clear History"
                                                                   message: @"Are you sure to clear history?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
    UIAlertAction *clear = [UIAlertAction actionWithTitle: @"Clear" style: UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [[WTICaculatorStore shareString] clearHistory];
                                                      }];
    [alert addAction: cancel];
    [alert addAction: clear];
    [self presentViewController: alert animated:YES completion:nil];
}

- (IBAction)resetting:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Resetting"
                                                                   message: @"Are you sure to reset Simple Caculator?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
    UIAlertAction *resetting = [UIAlertAction actionWithTitle: @"Reset" style: UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){[self reset];}];
 
    [alert addAction: cancel];
    [alert addAction: resetting];
    [self presentViewController: alert animated:YES completion:nil];
}

- (void)reset
{
    self.hueSlider.value = 0;
    self.saturateSlider.value = 0;
    self.brightSlider.value = 0;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setBool: YES forKey: soundsOnKey];
    [defaults setBool: NO forKey: colorReversedKey];
    [defaults setInteger: DEFAULT_LEVEL forKey: colorLevelKey];
    UIColor *backgroundColor = UICOLOR(150, 140, 125, 1.0);
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject: backgroundColor];
    [defaults setObject: colorData forKey: backgroundColorKey];
    [defaults synchronize];
    
    [self levelButtonSelected: self.level7];
    WTIMainViewController *mvc = [self rootController];
    [mvc settingChanged: backgroundColor colorLevel: DEFAULT_LEVEL reverse: NO soundOn: _soundOn];
    [self saveBackgroundImage];
}

- (void)confirmBackgroundColor
{
    if (self.brightSlider.value == self.brightSlider.maximumValue && self.lastLevel.tag == 0) {
        return;
    }
    self.hueSlider.value = 0;
    self.saturateSlider.value = 0;
    self.brightSlider.value = 0;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setBool: _colorReversed forKey: colorReversedKey];
    [defaults setInteger: self.lastLevel.tag forKey: colorLevelKey];
    if (self.changedColor != nil) {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject: self.changedColor];
        [defaults setObject: colorData forKey: backgroundColorKey];
    }
    [defaults synchronize];
    [self saveBackgroundImage];
}


#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat verticalOffset = scrollView.contentOffset.y;
    CGFloat alpha = 1.0 - verticalOffset / 120.0;
    alpha = alpha > 0 ? alpha : 0;
    alpha = alpha < 1.0 ? alpha : 1.0;
    self.headerView.alpha = alpha;
    self.settingButton.alpha = alpha;
    self.reverseSettingButton.alpha = 1.0 - alpha;
}


- (void)backgroundColorChanged
{
    WTIMainViewController *mvc = [self rootController];
    if (self.changedColor == nil) {
        UIColor *backgroundColor = [self backgroundColor];
        [mvc settingChanged: backgroundColor colorLevel: self.lastLevel.tag reverse: _colorReversed soundOn: _soundOn];
    } else {
        [mvc settingChanged: self.changedColor colorLevel: self.lastLevel.tag reverse: _colorReversed soundOn: _soundOn];
    }
}

- (UIColor *)backgroundColor
{
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey: backgroundColorKey];
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData: colorData];
    return backgroundColor;
}

- (void)saveBackgroundImage
{
    WTIMainViewController *mvc = [self rootController];
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path = [documents stringByAppendingPathComponent:@"background.png"];
    [UIImagePNGRepresentation([mvc backgroundImage]) writeToFile: path atomically:YES];
}

- (WTIMainViewController *)rootController
{
    return (WTIMainViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
