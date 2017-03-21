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
#import "WTITableViewCell.h"
#import "WTIHistoryModel.h"
#import "WTIRGBEngine.h"
#import "Setting.h"

#define LEVEL_RADIUS 5
#define HELP_LABEL_LAYOUT_DIVIDE 60
#define SLIDER_MARGIN_LAYOUT 58

#define CELL_HEADER_HEIGHT 20
#define CELL_BORDER 10
#define CELL_DEFAULT_HEIGHT 28
#define CELL_EDIT_OFFSET 50

#define HISTORY_VIEW_DEFAULT 0
#define HISTORY_VIEW_OFFSET 280
#define HISTORY_VIEW_TOP_MARGIN 64
#define HISTORY_VIEW_BOTTOM_MARGIN 44

#define LINE_MARGIN 25
#define RIGHT_BUTTON_MARGIN 25
#define RIGHT_BUTTON_OFFSET -100



@interface WTISettingViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) BOOL soundOn;
@property (assign, nonatomic) BOOL colorReversed;
@property (assign, nonatomic) BOOL historyClosed;
@property (assign, nonatomic) BOOL historyViewHidden;

@property (strong, nonatomic) UIColor *changedColor;
@property (strong, nonatomic) UIColor *temporaryColor;

@property (weak, nonatomic) IBOutlet UIImageView *historyImageView;
@property (weak, nonatomic) IBOutlet UIImageView *soundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backHistoryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundColorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundColorFrameImageView;

@property (weak, nonatomic) IBOutlet UILabel *helpLabel;

@property (weak, nonatomic) IBOutlet UILabel *historyHolderLabel;

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

@property (weak, nonatomic) IBOutlet UIButton *clearAllButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UIButton *backHistoryButton;
@property (weak, nonatomic) IBOutlet UIButton *closeHistoryButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *ramdomButton;
@property (weak, nonatomic) IBOutlet UIButton *resettingButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseColorButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseSettingButton;
@property (weak, nonatomic) IBOutlet UIButton *backgroundColorButton;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *historyContentView;
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider6;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divider7;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottonLineMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clearButtonMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editButtonMargin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftHueMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightHueMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *helpLabelHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *levelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyContentViewHeight;

@end

@implementation WTISettingViewController

static NSString *help = @"Simple Caculator calculates result automatically with expression. During typing, Simple Caculator reverse bracket, completing brackets intelligent.\n\nSome buttons have various functions:\n\nTap Clear Button to delete the last input or the couple of redundant brackets.\n\nLong press Clear Button to clear all.\n\nLong press Minus/Division button to reverse/count down the whole expression. \n\nLong press Bracket button to clear all redundant brackets.\n\n\nSome tips for result area:\n\nSwipe Left to Undo.Swipe Right to Redo.\n\nSwipe Down to start a new expression with the current result.\n\nSwipe Up to browse history.\n\n Hold on result area to copy, paste or use result.\n\n";

static NSString *cellIdentifier = @"WTITableViewCell";
static NSString *historyHolderNoneData = @"Previous answers will appear here.";
static NSString *historyHolderClosed = @"Open history function to record answers.";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self basicSetting];
    [self deployAreaOfColorDisk];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGSize helpLabelSize = [self.helpLabel sizeThatFits: CGSizeMake(SCREEN_WIDTH - HELP_LABEL_LAYOUT_DIVIDE, CGFLOAT_MAX)];
    self.helpLabelHight.constant = helpLabelSize.height;
    
    self.divider1.constant = (SCREEN_WIDTH - SLIDER_MARGIN_LAYOUT * 2  - LEVEL_RADIUS * 16) / 7.0;
    self.divider2.constant = self.divider1.constant;
    self.divider3.constant = self.divider1.constant;
    self.divider4.constant = self.divider1.constant;
    self.divider5.constant = self.divider1.constant;
    self.divider6.constant = self.divider1.constant;
    self.divider7.constant = self.divider1.constant;
    
    if (_historyViewHidden) {
        self.historyContentViewHeight.constant = HISTORY_VIEW_DEFAULT;
    } else {
        self.historyContentViewHeight.constant = SCREEN_HEIGHT - HISTORY_VIEW_TOP_MARGIN - HISTORY_VIEW_BOTTOM_MARGIN;
        self.scrollView.contentOffset = CGPointMake(0, HISTORY_VIEW_OFFSET - HISTORY_VIEW_TOP_MARGIN);
        self.scrollView.scrollEnabled = NO;
    }
}


#pragma mark - Basic Setting

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
    
    self.clearAllButton.alpha = 0;
    self.settingButton.alpha = 0;
    self.reverseSettingButton.alpha = 0;

    
    [self.editButton setTitle: @"Edit" forState: UIControlStateNormal];

    self.scrollView.delaysContentTouches = NO;
    
    self.backgroundColorImageView.image = [self.backgroundColorImageView.image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    self.backgroundColorImageView.tintColor = [self backgroundColor];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _soundOn = [defaults boolForKey: soundsOnKey];
    _historyClosed = [defaults boolForKey: historyCloseKey];
    _historyViewHidden = [defaults boolForKey: historyViewHiddenKey];
    _colorReversed = [defaults boolForKey: colorReversedKey];

    [self changeSoundsButtonTitleAnimated: NO];
    [self changeHistoryLabelText];
    [self alphaControlAnimated: NO];
}

- (void)deployAreaOfColorDisk
{
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
    
    [self configLevelButtons];
    [self enlageButtonEdge];
    [self changeReverseButton];
}

- (void)enlageButtonEdge
{
    [self.settingButton         setEnlargeEdgeWithTop: 20.0 right: 20.0 bottom: 20.0 left: 20.0];
    [self.reverseSettingButton  setEnlargeEdgeWithTop: 20.0 right: 20.0 bottom: 20.0 left: 20.0];
    [self.resettingButton       setEnlargeEdgeWithTop: 5.0  right: 5.0  bottom: 5.0 left: 5.0];
    [self.closeHistoryButton    setEnlargeEdgeWithTop: 5.0  right: 5.0  bottom: 5.0 left: 0];
    [self.editButton            setEnlargeEdgeWithTop: 5.0  right: 5.0  bottom: 5.0 left: 0];
    [self.clearAllButton        setEnlargeEdgeWithTop: 5.0  right: 5.0  bottom: 5.0 left: 0];
}

- (void)configLevelButtons
{
    NSInteger level = [[NSUserDefaults standardUserDefaults] integerForKey: colorLevelKey];
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
}

- (void)formatButtonShape: (UIButton *)button
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1.0, 1.0, 1.0, 0.5});
    
    [button.layer setCornerRadius: 4.0];
    [button.layer setBorderWidth: 1.0];
    [button.layer setBorderColor: colorref];
    
    [button addTarget: self action: @selector(backgroundButtonTouched:) forControlEvents: UIControlEventTouchDown];
    [button addTarget: self action: @selector(backgroundButtonTapEnded:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [button setEnlargeEdgeWithTop: 10.0 right: 0  bottom: 10.0 left: 0];
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

- (void)changeSoundsButtonTitleAnimated: (BOOL)animation
{
    if (_soundOn) {
        [self.soundButton setTitle: @"Sounds On" forState: UIControlStateNormal];
    } else {
        [self.soundButton setTitle: @"Sounds Off" forState: UIControlStateNormal];
    }
    if (animation) {
        [UIView animateWithDuration: 0.15 animations:^{
            self.soundImageView.alpha = 0;
        } completion:^(BOOL finished) {
            if (_soundOn) {
                [self.soundImageView setImage: [UIImage imageNamed: @"SoundOn"]];
            } else {
                [self.soundImageView setImage: [UIImage imageNamed: @"SoundOff"]];
            }
            [UIView animateWithDuration: 0.15 animations:^{
                self.soundImageView.alpha = 1.0;
            }];
        }];
    } else {
        if (_soundOn) {
            [self.soundImageView setImage: [UIImage imageNamed: @"SoundOn"]];
        } else {
            [self.soundImageView setImage: [UIImage imageNamed: @"SoundOff"]];
        }
    }
}

- (void)changeHistoryLabelText
{
    if (_historyClosed) {
        self.historyHolderLabel.text = historyHolderClosed;
        [self.closeHistoryButton setTitle: @"Record History" forState: UIControlStateNormal];
    } else {
        self.historyHolderLabel.text = historyHolderNoneData;
        [self.closeHistoryButton setTitle: @"Close History" forState: UIControlStateNormal];
    }
}


#pragma mark - Animation

- (void)alphaControlAnimated: (BOOL)animation
{
    if (_historyViewHidden) {
        self.editButton.alpha = 0.0;
        self.backHistoryButton.alpha = 0.0;
        self.backHistoryImageView.alpha = 0.0;
        
        self.soundButton.alpha = 1.0;
        self.soundImageView.alpha = 1.0;
        self.historyButton.alpha = 1.0;
        self.historyImageView.alpha = 1.0;
        self.backgroundColorButton.alpha = 1.0;
        self.backgroundColorImageView.alpha = 1.0;
        self.backgroundColorFrameImageView.alpha = 1.0;
        
        self.topLineView.alpha = 0.5;
        self.bottomLineView.alpha = 0.5;
        
        self.historyHolderLabel.alpha = 0.0;
    } else {
        self.soundButton.alpha = 0.0;
        self.soundImageView.alpha = 0.0;
        self.historyButton.alpha = 0.0;
        self.historyImageView.alpha = 0.0;
        self.backgroundColorButton.alpha = 0.0;
        self.backgroundColorImageView.alpha = 0.0;
        self.backgroundColorFrameImageView.alpha = 0.0;
        
        self.backHistoryButton.alpha = 1.0;
        self.backHistoryImageView.alpha = 1.0;
        
        if ([self historyExist]) {
            self.editButton.alpha = 1.0;
            self.historyTableView.alpha = 1.0;
            self.historyHolderLabel.alpha = 0.0;
            self.topLineView.alpha = 0.0;
        } else {
            self.editButton.alpha = 0.0;
            self.historyTableView.alpha = 0.0;
            
            self.topLineView.alpha = 0.0;
            self.bottomLineView.alpha = 0.0;
            
            if (!animation) {
                self.historyHolderLabel.alpha = 1.0;
            }
        }
    }
}

- (void)constrainsAnimation
{
    self.topLineMargin.constant = SCREEN_WIDTH;
    self.bottonLineMargin.constant = SCREEN_WIDTH;
    self.editButtonMargin.constant = RIGHT_BUTTON_OFFSET;
    self.clearButtonMargin.constant = RIGHT_BUTTON_OFFSET;
    
    [UIView animateWithDuration: 0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.topLineMargin.constant = LINE_MARGIN;
        self.bottonLineMargin.constant = LINE_MARGIN;
        self.editButtonMargin.constant = RIGHT_BUTTON_MARGIN;
        self.clearButtonMargin.constant = RIGHT_BUTTON_MARGIN;
    }];
}

- (void)imageViewAnimation
{
    [UIView animateWithDuration: 0.3 animations:^{
        if (_historyViewHidden) {
            CGAffineTransform  transform = CGAffineTransformRotate(self.backHistoryImageView.transform, M_PI/4);
            self.backHistoryImageView.transform = transform;
        } else {
            CGAffineTransform  transform = CGAffineTransformRotate(self.historyImageView.transform, -M_PI/4);
            self.historyImageView.transform = transform;
        }
    } completion:^(BOOL finished) {
        if (_historyViewHidden) {
            CGAffineTransform  transform = CGAffineTransformRotate(self.backHistoryImageView.transform, -M_PI/4);
            self.backHistoryImageView.transform = transform;
        } else {
            CGAffineTransform  transform = CGAffineTransformRotate(self.historyImageView.transform, M_PI/4);
            self.historyImageView.transform = transform;
        }
    }];
}

- (void)clearAnimation
{
    [UIView animateWithDuration: 0.5 animations:^{
        [self alphaControlAnimated: YES];
        self.clearAllButton.alpha = 0;
    }];
    [UIView animateWithDuration: 0.8 animations:^{
        self.historyHolderLabel.alpha = 1.0;
    }];
    [self constrainsAnimation];
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
    [self changeSoundsButtonTitleAnimated: YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: _soundOn forKey: soundsOnKey];
    [defaults synchronize];
}

- (IBAction)cancelBackgroundColorChange:(UIButton *)sender
{
    self.hueSlider.value = 0;
    self.saturateSlider.value = 0;
    self.brightSlider.value = 0;
    
    self.lastLevel.selected = NO;
    [self.lastLevel.layer setBorderWidth: 1.0];
    self.lastLevel.backgroundColor = [UIColor clearColor];
    
    [self configLevelButtons];
    self.temporaryColor = [self backgroundColor];
    WTIMainViewController *mvc = [self rootController];
    [mvc settingChanged: self.temporaryColor colorLevel: self.lastLevel.tag reverse: _colorReversed soundOn: _soundOn];
}

- (IBAction)displayHistoryTableView:(UIButton *)sender
{
    _historyViewHidden = !_historyViewHidden;
    
    if (self.historyTableView.editing) {
        [self.historyTableView setEditing: NO animated: YES];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: _historyViewHidden forKey: historyViewHiddenKey];
    [defaults synchronize];
    
    CGFloat contentOffsetY = 0;
    if (_historyViewHidden) {
        self.historyContentViewHeight.constant = HISTORY_VIEW_DEFAULT;
    } else {
        self.historyContentViewHeight.constant = SCREEN_HEIGHT - HISTORY_VIEW_TOP_MARGIN - HISTORY_VIEW_BOTTOM_MARGIN;
        contentOffsetY = HISTORY_VIEW_OFFSET - HISTORY_VIEW_TOP_MARGIN;
    }
    
    [self changeHistoryLabelText];
    [self imageViewAnimation];
    
    [UIView animateWithDuration: 0.3 animations:^{
        [self.view layoutIfNeeded];
        self.scrollView.contentOffset = CGPointMake(0, contentOffsetY);
        [self alphaControlAnimated: NO];
        self.clearAllButton.alpha = 0;
    } completion:^(BOOL finished) {
        _historyViewHidden ? (self.scrollView.scrollEnabled = YES) :
                             (self.scrollView.scrollEnabled = NO);
    }];
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
                                                        self.backgroundColorImageView.tintColor = [self backgroundColor];
                                                    }];
    [alert addAction: cancel];
    [alert addAction: confirm];
    
    [self presentViewController: alert animated:YES completion:nil];
}

- (IBAction)closeHistory:(UIButton *)sender
{
    UIAlertController *alert;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];

    if (!_historyClosed) {
        alert = [UIAlertController alertControllerWithTitle: @"Close History"
                                                    message: @"Close this function will clean all data recorded."
                                             preferredStyle: UIAlertControllerStyleAlert];
    } else {
        alert = [UIAlertController alertControllerWithTitle: @"Open History"
                                                    message: @"You answers will be record."
                                             preferredStyle: UIAlertControllerStyleAlert];
    }
    
    UIAlertAction *close = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action)
    {
         _historyClosed = !_historyClosed;
          [[NSUserDefaults standardUserDefaults] setBool: _historyClosed forKey: historyCloseKey];
          [[NSUserDefaults standardUserDefaults] synchronize];
        
          [self changeHistoryLabelText];
          if (_historyClosed) {
              [[WTICaculatorStore shareString] clearHistory];
              [self.historyTableView reloadData];
          }
      }];
    [alert addAction: cancel];
    [alert addAction: close];
    [self presentViewController: alert animated:YES completion:nil];
}

- (IBAction)clearHistory:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Clear History"
                                                                   message: @"Are you sure to clear history?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
    UIAlertAction *clear = [UIAlertAction actionWithTitle: @"Clear" style: UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
        [[WTICaculatorStore shareString] clearHistory];
        [self.historyTableView reloadData];
        [self clearAnimation];
    }];
    
    [alert addAction: cancel];
    [alert addAction: clear];
    [self presentViewController: alert animated:YES completion:nil];
}

- (IBAction)editHistory:(UIButton *)sender
{
    if (!self.historyTableView.hidden) {
        [self.historyTableView setEditing: !self.historyTableView.editing animated: YES];
        [self.historyTableView beginUpdates];
        [self.historyTableView endUpdates];
        if (self.historyTableView.editing) {
            [self.editButton setTitle: @"Done" forState: UIControlStateNormal];
            [UIView animateWithDuration: 0.3 animations:^{
                self.clearAllButton.alpha = 1.0;
            }];
        } else {
            [self.editButton setTitle: @"Edit" forState: UIControlStateNormal];
            [UIView animateWithDuration: 0.3 animations:^{
                self.clearAllButton.alpha = 0.0;
            }];
        }
    } else {
        [self.editButton setTitle: @"Edit" forState: UIControlStateNormal];
    }
}

- (IBAction)resetting:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Resetting"
                                                                   message: @"Are you sure to reset Simple Caculator?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
    UIAlertAction *resetting = [UIAlertAction actionWithTitle: @"Reset"
                                                        style: UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){[self reset];}];
 
    [alert addAction: cancel];
    [alert addAction: resetting];
    [self presentViewController: alert animated:YES completion:nil];
}


#pragma mark - Functions

- (void)reset
{
    self.hueSlider.value = 0;
    self.saturateSlider.value = 0;
    self.brightSlider.value = 0;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setBool: YES forKey: soundsOnKey];
    [defaults setBool: NO forKey: colorReversedKey];
    [defaults setBool: YES forKey: historyViewHiddenKey];
    [defaults setBool: NO forKey: historyCloseKey];

    [defaults setInteger: DEFAULT_LEVEL forKey: colorLevelKey];
    UIColor *backgroundColor = DEFAULT_COLOR;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject: backgroundColor];
    [defaults setObject: colorData forKey: backgroundColorKey];
    [defaults synchronize];
    
    _historyClosed = NO;
    _historyViewHidden = YES;
    _colorReversed = NO;
    _soundOn = YES;
    
    self.temporaryColor = backgroundColor;
    self.changedColor = backgroundColor;
    self.backgroundColorImageView.tintColor = backgroundColor;

    [self changeReverseButton];
    [self changeHistoryLabelText];
    [self changeSoundsButtonTitleAnimated: NO];
    [self levelButtonSelected: self.level3];
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

- (void)reload
{
    [self.editButton setTitle: @"Edit" forState: UIControlStateNormal];
    [self.historyTableView reloadData];
    [self alphaControlAnimated: NO];
}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [WTICaculatorStore shareString].historyModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    WTIHistoryModel *historyModel = [[WTICaculatorStore shareString].historyModels objectAtIndex: section];
    if (section == [[WTICaculatorStore shareString].historyModels count] - 1) {
        return historyModel.expressionArray.count + 1;
    }
    return historyModel.expressionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTITableViewCell *cell = [WTITableViewCell cellWithTableView: tableView];

    WTIHistoryModel *historyModel = [[WTICaculatorStore shareString].historyModels objectAtIndex: indexPath.section];
    if (indexPath.section == [[WTICaculatorStore shareString].historyModels count] - 1) {
        if (indexPath.row == historyModel.expressionArray.count) {
            cell.textLabel.text = @"";
            cell.userInteractionEnabled = NO;
            return cell;
        }
    }
    
    cell.textLabel.text = [historyModel.expressionArray objectAtIndex: indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WTIHistoryModel *historyModel = [[WTICaculatorStore shareString].historyModels objectAtIndex: section];

    CGSize tableViewSize = tableView.frame.size;
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableViewSize.width - 5.0, CELL_HEADER_HEIGHT)];
    
    sectionHeaderView.layer.cornerRadius = 10;
    sectionHeaderView.backgroundColor = UICOLOR(0, 0, 0, 0.1);
    
    UILabel *label = [[UILabel alloc] initWithFrame: sectionHeaderView.frame];
    
    label.text = historyModel.dateString;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName: @"HelveticaNeue-Light" size: 15.0f];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentRight;
    
    [sectionHeaderView addSubview:label];
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CELL_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTIHistoryModel *historyModel = [[WTICaculatorStore shareString].historyModels objectAtIndex: indexPath.section];

    if (indexPath.section == [[WTICaculatorStore shareString].historyModels count] - 1) {
        if (indexPath.row == historyModel.expressionArray.count) {
            return CELL_DEFAULT_HEIGHT;
        }
    }
    
    CGFloat width = tableView.frame.size.width;
    if (tableView.editing) {
        width -= CELL_EDIT_OFFSET;
    }

    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.font = [UIFont fontWithName: @"HelveticaNeue-Light" size: 15.0f];
    
    tempLabel.numberOfLines = 0;
    tempLabel.text = [historyModel.expressionArray objectAtIndex: indexPath.row];
    
    CGSize fitSize = [tempLabel sizeThatFits: CGSizeMake(width, CGFLOAT_MAX)];
    return fitSize.height + CELL_BORDER;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[WTICaculatorStore shareString] historySecletedAtIndexPath: indexPath];
    [self returnMainInterface: nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[WTICaculatorStore shareString] deleteHistoryAtIndexPath: indexPath];
        if (tableView.numberOfSections != [WTICaculatorStore shareString].historyModels.count) {
            [tableView deleteSections: [NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            [tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
        }
        if (![self historyExist]) {
            [self clearAnimation];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTIHistoryModel *historyModel = [[WTICaculatorStore shareString].historyModels objectAtIndex: indexPath.section];
    
    if (indexPath.section == [[WTICaculatorStore shareString].historyModels count] - 1) {
        if (indexPath.row == historyModel.expressionArray.count) {
            return UITableViewCellEditingStyleNone;
        }
    }
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)historyExist
{
    if ([WTICaculatorStore shareString].historyModels.count == 0) {
        return NO;
    } else if ([WTICaculatorStore shareString].historyModels.count == 1) {
        WTIHistoryModel *historyModel = [[WTICaculatorStore shareString].historyModels firstObject];
        if (historyModel.expressionArray.count == 0) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        CGFloat verticalOffset = scrollView.contentOffset.y;
        CGFloat alpha = 1.0 - verticalOffset / 120.0;
        alpha = alpha > 0 ? alpha : 0;
        alpha = alpha < 1.0 ? alpha : 1.0;
        
        _historyViewHidden = [[NSUserDefaults standardUserDefaults] boolForKey: historyViewHiddenKey];
        if (!_historyViewHidden) {
            self.headerView.alpha = 0;
            self.resettingButton.alpha = 1.0;
            self.reverseSettingButton.alpha = 0;
        } else {
            self.headerView.alpha = alpha;
            self.settingButton.alpha = alpha;
            self.reverseSettingButton.alpha = 1.0 - alpha;
        }
    }
}


#pragma mark - Background Color

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
