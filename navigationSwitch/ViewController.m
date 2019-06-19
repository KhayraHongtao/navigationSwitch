//
//  ViewController.m
//  navigationSwitch
//
//  Created by khayra on 2019/6/19.
//  Copyright © 2019 khayra. All rights reserved.
//

#import "ViewController.h"
#import "OViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "KTMultipleSwitch.h"

@interface ViewController (){
    UIViewController *_currentVC;
    int _oneInt;
    int _twoInt;
    int _threeInt;
}
@property (nonatomic, strong) UIView *contentView;
@property (strong, nonatomic) OViewController *oneVC;
@property (strong, nonatomic) TwoViewController *twoVC;
@property (strong, nonatomic) ThreeViewController *threeVC;

@end

@implementation ViewController

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (OViewController *)oneVC {
    if (!_oneVC) {
        _oneVC = [[OViewController alloc]init];
        _oneVC.hidesBottomBarWhenPushed = YES;
    }
    return _oneVC;
}

- (TwoViewController *)twoVC {
    if (!_twoVC) {
        _twoVC = [[TwoViewController alloc]init];
        _twoVC.hidesBottomBarWhenPushed = YES;
    }
    return _twoVC;
}

- (ThreeViewController *)threeVC {
    if (!_threeVC) {
        _threeVC = [[ThreeViewController alloc]init];
        _threeVC.hidesBottomBarWhenPushed = YES;
    }
    return _threeVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _oneInt = 0;
    _twoInt = 0;
    _threeInt = 0;
    [self.view addSubview:self.contentView];
    
    KTMultipleSwitch *kt_switch = [[KTMultipleSwitch alloc] initWithItems:@[@"线上订单",@"服务直购",@"快速预约"]];
    kt_switch.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-130, 32);
    [kt_switch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    kt_switch.selectedTitleColor = [UIColor blackColor];
    kt_switch.titleColor = [UIColor lightTextColor];
    kt_switch.trackerColor = [UIColor whiteColor];
    kt_switch.titleFont = [UIFont systemFontOfSize:16.0];
    kt_switch.selectedTitleFont = [UIFont boldSystemFontOfSize:16.0];
    kt_switch.selectedSegmentIndex = 0;
    self.navigationItem.titleView = kt_switch;
    
    [self addChildViewController:self.oneVC];
    [self addChildViewController:self.twoVC];
    [self addChildViewController:self.threeVC];
    
    _currentVC = self.oneVC;
    _oneInt++;
    
    //调整子视图控制器的Frame已适应容器View
    [self fitFrameForChildViewController:self.oneVC];
    //设置默认显示在容器View的内容
    [self.contentView addSubview:self.oneVC.view];
}

- (void)switchAction:(KTMultipleSwitch *)multipleSwitch {
    NSLog(@"点击了第%zd个",multipleSwitch.selectedSegmentIndex);
    switch (multipleSwitch.selectedSegmentIndex) {
        case 0:{
            if (_oneInt > 0) return;
            _oneInt++;
            _twoInt = 0;
            _threeInt = 0;
            [self fitFrameForChildViewController:self.oneVC];
            [self transitionFromOldViewController:_currentVC toNewViewController:self.oneVC];
        }break;
        case 1:{
            if (_twoInt > 0) return;
            _twoInt++;
            _oneInt = 0;
            _threeInt = 0;
            [self fitFrameForChildViewController:self.twoVC];
            [self transitionFromOldViewController:_currentVC toNewViewController:self.twoVC];
        }break;
        case 2:{
            if (_threeInt > 0) return;
            _threeInt++;
            _oneInt = 0;
            _twoInt = 0;
            [self fitFrameForChildViewController:self.threeVC];
            [self transitionFromOldViewController:_currentVC toNewViewController:self.threeVC];
        }break;
        default:
            break;
    }
    
}

- (void)fitFrameForChildViewController:(UIViewController *)chileViewController{
    CGRect frame = self.contentView.frame;
    frame.origin.y = 0;
    chileViewController.view.frame = frame;
}

//转换子视图控制器
- (void)transitionFromOldViewController:(UIViewController *)oldViewController toNewViewController:(UIViewController *)newViewController {
    [self transitionFromViewController:oldViewController toViewController:newViewController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newViewController didMoveToParentViewController:self];
            self->_currentVC = newViewController;
        }else{
            self->_currentVC = oldViewController;
        }
    }];
}

//移除所有子视图控制器
- (void)removeAllChildViewControllers{
    for (UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.layer.shadowOpacity = 0;
}



@end
