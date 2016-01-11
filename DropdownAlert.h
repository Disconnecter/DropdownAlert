//
//  DropdownAlert.h
//
//  Created by Zabolotnyy S. on 12.11.15.
//

@interface DropdownAlert : UIControl

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *messageFont;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *messageColor;
@property (nonatomic, strong) UIColor *alertColor;

@property (nonatomic, assign) CGFloat animationTime;
@property (nonatomic, assign) CGFloat showTime;

- (void)showWithTitle:(NSString*)title andMessage:(NSString*)message;

@end
