//
//  KTMultipleSwitch.h
//  MDDUnitBase
//
//  Created by khayra on 2019/1/14.
//  Copyright © 2019 Khayra. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTMultipleSwitch : UIControl
- (instancetype)initWithItems:(NSArray *)items;

@property(nonatomic) NSInteger selectedSegmentIndex;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *selectedTitleFont;

@property (nonatomic, assign) CGFloat spacing; // label之间的间距
@property (nonatomic, assign) CGFloat contentInset; // 内容内宿边距

@property (nonatomic, copy) UIColor *trackerColor; // 滑块的颜色
@property (nonatomic, copy) UIImage *trackerImage; // 滑块的图片
@property (nonatomic, copy) UIColor *lineColor; // 分割线颜色
@end

NS_ASSUME_NONNULL_END
