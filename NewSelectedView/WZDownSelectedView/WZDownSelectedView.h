//
//  WZDownSelectedView.h
//  NewSelectedView
//
//  Created by wangzheng on 17/8/23.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZDownSelectedView;
@protocol WZDownSelectedViewDelegate <NSObject>

@required
- (void)downSelectedView:(WZDownSelectedView *)selectedView didSelectedAtIndex:(NSIndexPath *)indexPath;

@end

@interface WZDownSelectedView : UIView

@property (nonatomic, weak) id<WZDownSelectedViewDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *listArray;


@property (nonatomic, strong) UIFont *font;       // 字体大小
@property (nonatomic, strong) UIColor *textColor; // 字体颜色
@property (nonatomic, assign) NSTextAlignment textAlignment; // 对齐方式
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy, readonly) NSString *showText; // 当前展示的内容
@property (nonatomic, copy) void (^downSelectedBlock)(NSInteger selectIndex,NSString *selectText);

@property (nonatomic, assign) BOOL isHideCoverView; // 是否展示蒙板

@property (nonatomic, assign) NSInteger limitcount;   // 页面上展示的最大行数,超过的滑动

- (void)show;
- (void)close;

@end
