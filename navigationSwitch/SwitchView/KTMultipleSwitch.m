//
//  KTMultipleSwitch.m
//  MDDUnitBase
//
//  Created by khayra on 2019/1/14.
//  Copyright © 2019 Khayra. All rights reserved.
//

#import "KTMultipleSwitch.h"

@interface KTMultipleSwitchLayer : CALayer

@end

@implementation KTMultipleSwitchLayer
- (instancetype)init {
    if (self = [super init]) {
        self.masksToBounds = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.cornerRadius = 4.0;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    [super setCornerRadius:4.0];
}

+ (Class)layerClass{
    return [KTMultipleSwitchLayer class];
}

@end

@interface KTMultipleSwitch()
@property (nonatomic, strong) UIView *labelContentView;
@property (nonatomic, strong) UIView *selectedLabelContentView;
@property (strong, nonatomic) UIView *lineView;
@property (nonatomic, strong) UIImageView *tracker;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) NSMutableArray *selectedLabels;
@property (nonatomic, strong) NSMutableArray *selectedButtomView;
@property (nonatomic, strong) UIView *maskTracker;
@property (nonatomic, assign) CGPoint beginPoint;
@end

@implementation KTMultipleSwitch

+ (Class)layerClass{
    return [KTMultipleSwitchLayer class];
}

- (instancetype)initWithItems:(NSArray *)items {
    if (self = [self init]) {
        // 创建子控件
        [self setupSubviewsWithItems:items];
        
        [self.tracker addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleFont = [UIFont systemFontOfSize:12];
        _titleColor = [UIColor redColor];
        _selectedTitleColor = [UIColor whiteColor];
        _spacing = 0;
        _contentInset = 0;
        _lineColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.tracker) {
        if ([keyPath isEqualToString:@"frame"]) {
            self.maskTracker.frame = self.tracker.frame;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIControl Override

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    _beginPoint = [touch locationInView:self];
    NSInteger index = [self indexForPoint:_beginPoint];
    self.selectedSegmentIndex = index;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGRect contentRect = CGRectInset(self.bounds, self.contentInset, self.contentInset);
    
    CGPoint currentPoint = [touch locationInView:self];
    CGFloat diff = currentPoint.x - _beginPoint.x;
    CGRect trackerFrame = self.tracker.frame;
    trackerFrame.origin.x += diff;
    trackerFrame.origin.x = MAX(MIN(CGRectGetMinX(trackerFrame),contentRect.size.width - trackerFrame.size.width), 0);
    self.tracker.frame = trackerFrame;
    _beginPoint = currentPoint;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    NSInteger index = [self indexForPoint:self.tracker.center];
    self.selectedSegmentIndex = index;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    NSInteger index = [self indexForPoint:self.tracker.center];
    self.selectedSegmentIndex = index;
}

// 根据一个点，取出离该点最近的label对应的index
- (NSInteger)indexForPoint:(CGPoint)point {
    CGRect contentRect = CGRectInset(self.bounds, self.contentInset, self.contentInset);
    NSInteger index = MAX(0, MIN(_labels.count - 1, point.x / (contentRect.size.width / (CGFloat)(_labels.count))));
    NSLog(@"%f---%f", contentRect.size.width,(contentRect.size.width/2));
    return index;
}

#pragma mark - setter

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    _selectedSegmentIndex = MAX(0, MIN(selectedSegmentIndex, _labels.count-1));
    UILabel *label = _labels[_selectedSegmentIndex];
    CGPoint trackerCenter = self.tracker.center;
    trackerCenter.x = label.center.x;
    self.tracker.center = trackerCenter;
    // 这行代码主要是为了走一遍KVO监听的方法
    self.tracker.frame = self.tracker.frame;
}

- (void)setContentInset:(CGFloat)contentInset {
    _contentInset = contentInset;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setSpacing:(CGFloat)spacing {
    _spacing = spacing;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setTrackerColor:(UIColor *)trackerColor {
    _trackerColor = trackerColor;
    self.tracker.backgroundColor = _trackerColor;
}

- (void)setTrackerImage:(UIImage *)trackerImage {
    _trackerImage = trackerImage;
    self.tracker.image = _trackerImage;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [_labels setValue:_titleColor forKeyPath:@"textColor"];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    [_selectedLabels setValue:_selectedTitleColor forKeyPath:@"textColor"];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    [_labels setValue:_titleFont forKeyPath:@"font"];
}

- (void)setSelectedTitleFont:(UIFont *)selectedTitleFont {
    _selectedTitleFont = selectedTitleFont;
    [_selectedLabels setValue:_selectedTitleFont forKeyPath:@"font"];
}

#pragma mark - 添加子控件

- (void)setupSubviewsWithItems:(NSArray *)items {
    
    self.labels = [NSMutableArray array];
    self.selectedLabels = [NSMutableArray array];
    self.selectedButtomView = [NSMutableArray array];
    
    // 第一层
    {
        UIView *labelContentView = [[UIView alloc] init];
        labelContentView.userInteractionEnabled = NO;
        labelContentView.layer.masksToBounds = YES;
        [self addSubview:labelContentView];
        _labelContentView = labelContentView;
        
        for (int i = 0; i < items.count; i++) {
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = items[i];
            label.textColor = [UIColor blackColor];
            [labelContentView addSubview:label];
            [self.labels addObject:label];
        }
        UIImageView *tracker = [[UIImageView alloc] init];
        tracker.userInteractionEnabled = NO;
        tracker.layer.masksToBounds = YES;
        tracker.backgroundColor = [UIColor redColor];
        [labelContentView addSubview:tracker];
        _tracker = tracker;
    }
    // 第二层
    {
        UIView *selectedLabelContentView = [[UIView alloc] init];
        selectedLabelContentView.userInteractionEnabled = NO;
        selectedLabelContentView.layer.masksToBounds = YES;
        [self addSubview:selectedLabelContentView];
        _selectedLabelContentView = selectedLabelContentView;
        
        for (int i = 0; i < items.count; i++) {
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = items[i];
            label.textColor = [UIColor whiteColor];
            [selectedLabelContentView addSubview:label];
            [self.selectedLabels addObject:label];
            
            UIView *bView = [[UIView alloc]init];
            bView.backgroundColor = [UIColor blackColor];
            bView.layer.cornerRadius = 3.0/2;
            bView.clipsToBounds = YES;
            [selectedLabelContentView addSubview:bView];
            [self.selectedButtomView addObject:bView];
        }
        UIView *maskTracker = [[UIView alloc] init];
        maskTracker.userInteractionEnabled = NO;
        maskTracker.backgroundColor = [UIColor redColor];
        _maskTracker = maskTracker;
        
        // 设置selectedLabelContentView的maskView，stackView是UIView的非渲染型子类，它无法设置backgroundColor,maskView等属性
        _selectedLabelContentView.maskView = maskTracker;
    }
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.userInteractionEnabled = NO;
        _lineView.layer.masksToBounds = YES;
        _lineView.backgroundColor = [UIColor clearColor];
    }
    return _lineView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = CGRectInset(self.bounds, self.contentInset, self.contentInset);
    self.labelContentView.frame = contentRect;
    self.selectedLabelContentView.frame = contentRect;
    
    CGFloat labelW =  (contentRect.size.width - _spacing * self.labels.count) / self.labels.count;
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        label.frame = CGRectMake(self->_spacing * 0.5 + idx * (labelW + self->_spacing) , 0, labelW, contentRect.size.height);
    }];
    [self.selectedLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        label.frame = CGRectMake(self->_spacing * 0.5 + idx * (labelW + self->_spacing), 0, labelW, contentRect.size.height);
    }];
    
    [self.selectedButtomView enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.frame = CGRectMake(labelW*idx+((labelW/2) - 10.0), contentRect.size.height-3.0, 20.0, 3.0);
    }];
    
    CGFloat averageWidth = contentRect.size.width / self.labels.count;
    self.tracker.frame = CGRectMake(_selectedSegmentIndex * averageWidth, 0, averageWidth, contentRect.size.height);
    
    for (int i = 1; i < self.labels.count; i++) {
        UIView *l = [[UIView alloc]init];
        l.backgroundColor = _lineColor;
        l.frame = CGRectMake(averageWidth*i-0.5, 0, 0.5, self.bounds.size.height);
        [self addSubview:l];
    }
}

- (void)dealloc {
    [self.tracker removeObserver:self forKeyPath:@"frame"];
}

@end
