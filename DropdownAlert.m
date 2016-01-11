//
//  DropdownAlert.m
//
//  Created by Zabolotnyy S. on 12.11.15.
//

#import "DropdownAlert.h"

static int kXbuffer = 10; //buffer distance on each side for the text
static int kYbufeer = 10; //buffer distance on top/bottom for the text

@interface DropdownAlert ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, assign) BOOL isShowing;

@end

@implementation DropdownAlert

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupDefaults];
        [self addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didRotate
{
    if (!self.isShowing) return;
    
    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGRect selfFrame = self.frame;
    selfFrame.size.width = maxWidth;

    if (self.titleLabel)
    {
        CGRect titleFrame = self.titleLabel.frame;
        titleFrame.size.width = maxWidth - 2 * kXbuffer;
        titleFrame.size.height = lroundf([self textSize:self.titleLabel.text withFont:self.titleFont
                                            forMaxWidth:CGRectGetWidth(titleFrame)].height);
        
        [self.titleLabel setFrame:titleFrame];
    }
    
    CGRect titleFrame = self.titleLabel.frame;
    if (self.messageLabel)
    {
        CGRect messageFrame = self.messageLabel.frame;
        messageFrame.size.width = maxWidth - 2 * kXbuffer;
        messageFrame.size.height = lroundf([self textSize:self.messageLabel.text withFont:self.messageFont
                                            forMaxWidth:CGRectGetWidth(messageFrame)].height);
        if (titleFrame.origin.y > 0)
        {
            messageFrame.origin.y = CGRectGetMaxY(titleFrame) + kYbufeer;
        }
        else
        {
            messageFrame.origin.y = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame) + kYbufeer;
        }
        [self.messageLabel setFrame:messageFrame];
    }
    
    selfFrame.size.height = MAX(CGRectGetMaxY(self.messageLabel.frame), CGRectGetMaxY(self.titleLabel.frame))  + kYbufeer;
    [UIView animateWithDuration:0.1 animations:^{
        [self setFrame:selfFrame];
    }];
}

- (void)setupDefaults
{
    self.titleFont       = [UIFont boldSystemFontOfSize:17];
    self.messageFont     = [UIFont systemFontOfSize:15];
    
    self.titleColor      = [UIColor whiteColor];
    self.messageColor    = [UIColor whiteColor];
    self.alertColor      = [UIColor orangeColor];
    
    self.animationTime   = 0.5;
    self.showTime        = 3.;
}

#pragma mark - Public methods

- (void)showWithTitle:(NSString*)title andMessage:(NSString*)message
{
    CGFloat statusBarH = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame);
    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGRect selfFrame = CGRectMake(0, 0, maxWidth, 0);
    
    CGRect titleFrame = CGRectZero;
    
    if (title.length)
    {
        titleFrame.origin.x = kXbuffer;
        titleFrame.origin.y = statusBarH + kYbufeer;
        titleFrame.size.width = maxWidth - 2 * kXbuffer;
        titleFrame.size.height = lroundf([self textSize:title withFont:self.titleFont
                                            forMaxWidth:CGRectGetWidth(titleFrame)].height);
        
        self.titleLabel = [self defaultLabelWithFrame:titleFrame];
        [self.titleLabel setTextColor:self.titleColor];
        [self.titleLabel setFont:self.titleFont];
        [self.titleLabel setText:title];
        
        [self addSubview:self.titleLabel];
    }
    
    CGRect messageFrame = CGRectZero;
    
    if (message.length)
    {
        messageFrame.origin.x = kXbuffer;
        messageFrame.size.width = maxWidth - 2 * kXbuffer;
        if (titleFrame.origin.y > 0)
        {
            messageFrame.origin.y = CGRectGetMaxY(titleFrame) + kYbufeer;
        }
        else
        {
            messageFrame.origin.y = statusBarH + kYbufeer;
        }
        
        messageFrame.size.height = lroundf([self textSize:message withFont:self.messageFont
                                              forMaxWidth:CGRectGetWidth(messageFrame)].height);
        
        self.messageLabel = [self defaultLabelWithFrame:messageFrame];
        [self.messageLabel setFont:self.messageFont];
        [self.messageLabel setTextColor:self.messageColor];
        [self.messageLabel setText:message];
        
        [self addSubview:self.messageLabel];
    }
    
    selfFrame.size.height = MAX(CGRectGetMaxY(messageFrame), CGRectGetMaxY(titleFrame))  + kYbufeer;
    selfFrame.origin.y  -= CGRectGetHeight(selfFrame);
    
    [self setFrame:selfFrame];
    [self setBackgroundColor:self.alertColor];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    selfFrame.origin.y = 0;
    
    [UIView animateWithDuration:self.animationTime animations:^
     {
         [self setFrame:selfFrame];
     }
                     completion:^(BOOL finished)
     {
         self.isShowing = YES;
         __weak typeof(self) weakSelf = self;
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.showTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
         {
             if (weakSelf.isShowing)
             {
                 [weakSelf hideView];
             }
         });
     }];
}

#pragma mark - Private

- (void)hideView
{
    CGRect frame = self.frame;
    frame.origin.y -= CGRectGetHeight(self.frame);
    self.isShowing = NO;
    [UIView animateWithDuration:self.animationTime animations:^
     {
         [self setFrame:frame];
     }
                     completion:^(BOOL finished)
     {
         [self removeFromSuperview];
     }];
}

#pragma mark - Utils

- (CGSize)textSize:(NSString*)text withFont:(UIFont*)font forMaxWidth:(CGFloat)width
{
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    
    return textRect.size;
}

- (UILabel*) defaultLabelWithFrame:(CGRect)frame
{
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    [label setNumberOfLines:0];
    return label;
}

@end
