//
//  WZDownSelectedView.m
//  NewSelectedView
//
//  Created by wangzheng on 17/8/23.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "WZDownSelectedView.h"

#define WZ_COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define kLineColor WZ_COLOR(219, 217, 216, 1)

#define WZ_IMAGENAME(name) [UIImage imageNamed:name]//定义UIImage对象

#define KScreenWidth [UIScreen mainScreen].bounds.size.width

#define KScreenHeight [UIScreen mainScreen].bounds.size.height


CGFloat angleValue(CGFloat angle) {
    return (angle * M_PI) / 180;
}

/// 动画的时间
NSTimeInterval const animationDuration = 0.2f;

@interface WZDownSelectedView () <UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) UITextField *contentTF;
@property (nonatomic, strong) UIButton *clickBtn;
@property (nonatomic, strong) UIImageView *arrowImgView;
@property (nonatomic, strong) UIView *arrowImgBgView;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, assign) BOOL isOpen;
/// 执行打开关闭动画是否结束
@property (nonatomic, assign) BOOL beDone;
@property (nonatomic, assign) NSInteger defaultIndex;

@end

@implementation WZDownSelectedView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit{
    
    self.font = [UIFont systemFontOfSize:14];
    self.textColor = WZ_COLOR(40, 40, 40, 1);
    self.textAlignment = NSTextAlignmentLeft;
    self.defaultIndex = 0;
    // 默认不展开
    self.isOpen = NO;
    // 默认是完成动画的
    self.beDone = YES;
    // 上限默认4
    self.limitcount = 4;

    // 初始化UI
    [self.arrowImgBgView addSubview:self.arrowImgView];
    [self addSubview:self.arrowImgBgView];
    [self addSubview:self.contentTF];
    [self addSubview:self.clickBtn];
}

#pragma mark - action
- (void)clickBtnClicked
{
    if (!self.beDone) return;
    
    /// 关闭页面上其他下拉控件
    for (UIView *subview in self.superview.subviews) {
        if ([subview isKindOfClass:[WZDownSelectedView class]] && subview != self) {
            WZDownSelectedView *donwnSelectedView = (WZDownSelectedView *)subview;
            if (donwnSelectedView.isOpen) {
                [donwnSelectedView close];
            }
        }
    }
    
    if (self.isOpen) {
        [self close];
    } else {
        [self show];
    }
}

#pragma mark - Public
- (void)show{
    
    if (self.isOpen || self.listArray.count == 0) return;
    
    self.beDone = NO;
    
    [self.superview addSubview:self.listTableView];
    [self.superview addSubview:self.coverView];
    
    /// 避免被其他子视图遮盖住
    [self.superview bringSubviewToFront:self.listTableView];
    CGRect listFrame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame), CGRectGetWidth(self.frame), 0);
    [self.listTableView setFrame:listFrame];
    
    CGRect coverFrame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame), CGRectGetWidth(self.frame), KScreenHeight - CGRectGetMaxY(self.frame));
    [self.coverView setFrame:coverFrame];
    
    self.listTableView.rowHeight = CGRectGetHeight(self.frame);
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         if (self.listArray.count > 0) {
                             [self.listTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                       atScrollPosition:UITableViewScrollPositionTop
                                                               animated:YES];
                         }
                         
                         CGRect frame = self.listTableView.frame;
                         NSInteger count = MIN(self.limitcount, self.listArray.count);
                         frame.size.height = count * self.frame.size.height ;
                         
                         /// 防止超出屏幕
                         if (frame.origin.y + frame.size.height > [UIScreen mainScreen].bounds.size.height) {
                             frame.size.height -= frame.origin.y + frame.size.height - [UIScreen mainScreen].bounds.size.height;
                         }
                         [self.listTableView setFrame:frame];
                         
                         self.arrowImgView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         
                         self.beDone = YES;
                         self.isOpen = YES;
                         
                     }
     ];
    
}

- (void)close
{
    // 关闭时 可能存在 点击,所以刷新一下,确保 选中图标 正确显示
    [self.listTableView reloadData];
    
    if (!self.isOpen) return;
    
    
    self.beDone = NO;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                         CGRect frame = self.listTableView.frame;
                         frame.size.height = 0.f;
                         [self.listTableView setFrame:frame];
                         self.arrowImgView.transform = CGAffineTransformRotate(self.arrowImgView.transform, angleValue(-180));
                     }
                     completion:^(BOOL finished) {
                         
                         if (self.coverView.superview) [self.coverView removeFromSuperview];
                         [self.listTableView setContentOffset:CGPointZero animated:NO];
                         if (self.listTableView.superview) [self.listTableView removeFromSuperview];
                         
                         self.coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];;
                         self.beDone = YES;
                         self.isOpen = NO;
                         
                     }
     ];
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *contentLable = [[UILabel alloc] initWithFrame:CGRectMake(8, 2, self.frame.size.width-60, self.frame.size.height-4)];
        contentLable.tag = 1000;
        contentLable.textColor = self.textColor;
        contentLable.font = self.font;
        contentLable.textAlignment = self.textAlignment;
        [cell addSubview:contentLable];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = kLineColor;
        lineView.frame = CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5);
        [cell addSubview:lineView];
    }
    
    cell.accessoryView = indexPath.row == self.defaultIndex ? [[UIImageView alloc] initWithImage:WZ_IMAGENAME(@"checked")] : [[UIImageView alloc] initWithImage:WZ_IMAGENAME(@"")];
    
//    if (self.textAlignment == NSTextAlignmentRight) {
//        cell.accessoryView = [[UIImageView alloc] initWithImage:WZ_IMAGENAME(@"")];
//    }
    
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:1000];
    contentLabel.text = self.listArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.contentTF.text = [_listArray objectAtIndex:indexPath.row];
    self.defaultIndex = indexPath.row;
    [self close];
    if ([self.delegate respondsToSelector:@selector(downSelectedView:didSelectedAtIndex:)]) {
        [self.delegate downSelectedView:self didSelectedAtIndex:indexPath];
    }

    if(self.downSelectedBlock){
        self.downSelectedBlock(indexPath.row,[_listArray objectAtIndex:indexPath.row]);
    }
}




#pragma mark --- setter/getter
- (void)setFont:(UIFont *)font{
    _font = font;
    self.contentTF.font = font;
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    self.contentTF.textColor = textColor;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment{
    _textAlignment = textAlignment;
    self.contentTF.textAlignment = textAlignment;
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    self.contentTF.placeholder = placeholder;
}

- (void)setListArray:(NSArray<NSString *> *)listArray{
    _listArray = listArray;
    
    self.contentTF.text = [listArray firstObject];
    [self.listTableView reloadData];
}

- (NSString *)showText{
    return self.contentTF.text;
}

- (void)setIsHideCoverView:(BOOL)isHideCoverView{
    _isHideCoverView = isHideCoverView;
    self.coverView.hidden = isHideCoverView;
}

- (void)setLimitcount:(NSInteger)limitcount{
    _limitcount = limitcount;
}

#pragma mark --- lazyinit
- (UITextField *)contentTF{
    
    if (!_contentTF) {
        _contentTF = [UITextField new];
        _contentTF.placeholder = @"请点击进行选择";
        _contentTF.enabled = NO;
        _contentTF.backgroundColor = [UIColor whiteColor];
        _contentTF.textColor = self.textColor;
        _contentTF.font = self.font;
        _contentTF.textAlignment = self.textAlignment;
    }
    return _contentTF;
}

- (UIButton *)clickBtn{
    if (!_clickBtn) {
        _clickBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _clickBtn.backgroundColor = [UIColor clearColor];
        _clickBtn.layer.borderColor = kLineColor.CGColor;
        _clickBtn.layer.borderWidth = 0.5f;
        [_clickBtn addTarget:self action:@selector(clickBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clickBtn;
}

- (UIImageView *)arrowImgView
{
    if (!_arrowImgView) {
        _arrowImgView = [UIImageView new];
        _arrowImgView.image = [UIImage imageNamed:@"arrow_up.png"];
        _arrowImgView.transform = CGAffineTransformRotate(self.arrowImgView.transform, angleValue(-180));
    }
    return _arrowImgView;
}

- (UIView *)arrowImgBgView
{
    if (!_arrowImgBgView) {
        _arrowImgBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _arrowImgBgView.backgroundColor = [UIColor clearColor];
    }
    return _arrowImgBgView;
}

- (UITableView *)listTableView
{
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listTableView.layer.borderWidth = 0.5;
        _listTableView.layer.borderColor = kLineColor.CGColor;
        _listTableView.scrollsToTop = NO;
        _listTableView.bounces = NO;
        _listTableView.dataSource = self;
        _listTableView.delegate = self;
        _listTableView.separatorColor = kLineColor;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _listTableView;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectZero];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

#pragma mark - Layout

- (void)updateConstraints
{
    NSLog(@"updateConstraints");
    // 箭头
    self.arrowImgView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:self.arrowImgView
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.arrowImgBgView
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.arrowImgView
                                                                           attribute:NSLayoutAttributeCenterY
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.arrowImgBgView
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1.0
                                                                            constant:0.0]
                                              ]];
    
    self.arrowImgBgView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:self
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.arrowImgBgView
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.arrowImgBgView
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.arrowImgBgView
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.arrowImgBgView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:30]
                                              ]];
    
    // 内容label
    self.contentTF.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:self.contentTF
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:8.0],
                                              [NSLayoutConstraint constraintWithItem:self.contentTF
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.contentTF
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.contentTF
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.arrowImgBgView
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:-20.0]
                                              ]];
    
    self.clickBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:self.clickBtn
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.clickBtn
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.clickBtn
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0.0],
                                              [NSLayoutConstraint constraintWithItem:self.clickBtn
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:0.0]
                                              ]];
    [super updateConstraints];
}



@end
