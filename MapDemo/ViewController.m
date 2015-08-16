//
//  ViewController.m
//  MapDemo
//
//  Created by 林梓成 on 15/7/1.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ZCAnnotation.h"  // 自定义的标注视图

@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locmgr;   // 位置管理者
@property (strong, nonatomic) MKMapView *mapView;          // 地图视图

@end

@implementation ViewController

/**
 *  懒加载：把这个属性的初始化方法写在自己的getter方法里面叫做懒加载
 *  好处：一、不会出现没有初始化就使用
 *       二、一个属性使用懒加载的形式，会在什么时候调用的时候才开辟内存空间。即点语法调用的时候
 *
 *  @return
 */
- (CLLocationManager *)locmgr {
    
    if (_locmgr == nil) {
        
        _locmgr = [[CLLocationManager alloc] init];
    }
    return _locmgr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        [self.locmgr requestAlwaysAuthorization];       // 一直授权
        [self.locmgr requestWhenInUseAuthorization];    // 当使用的时候才授权
    }
    
    // 创建地图
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_mapView];
    
    // 设置地图的类型
    self.mapView.mapType = MKMapTypeStandard;
    
    // 显示用户的位置(需真机)
    self.mapView.showsUserLocation = YES;
    
    self.mapView.delegate = self;
    
    [self.mapView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addAnnot:)]];
}


#pragma makr MKMapViewDelegate delegate function
/**
 *  更新用户位置信息的方法
 *
 *  @param mapView      地图
 *  @param userLocation 用户位置
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    NSLog(@"lon = %f, lan = %f", userLocation.location.coordinate.longitude, userLocation.location.coordinate.latitude);
    
    // 显示位置气泡内容
    userLocation.title = @"中国广州";
    userLocation.subtitle = @"天河区东莞庄路";
    
    // 设置地图的精确度以及显示用户位置的信息
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    
    // 设置地图显示的范围
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [mapView setRegion:region];
}

/**
 *  自定义标注视图（大头针）
 *
 *  @param mapView    <#mapView description#>
 *  @param annotation <#annotation description#>
 *
 *  @return <#return value description#>
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        // 如果是用户的位置、我们就不做任何编辑直接返回
        return nil;
    }
    
    // 创建重用标识符
    static NSString *identifier = @"anno";
    // 重用队列
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    // 创建大头针
    if (pin == nil) {
        
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    // 设置大头针向下坠落的效果
    pin.animatesDrop = YES;
    
    // 设置大头针颜色
    pin.pinColor = MKPinAnnotationColorGreen;
    
    // 设置气泡是否显示
    pin.canShowCallout = YES;
    
    
    // 创建气泡的左右两个按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton setImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
    
    pin.leftCalloutAccessoryView = leftButton;
    leftButton.tag = 10086;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton setImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
    
    pin.rightCalloutAccessoryView = rightButton;
    rightButton.tag = 10010;

    return pin;
}

/**
 *  点击大头针上面的气泡所执行的方法
 *
 *  @param mapView <#mapView description#>
 *  @param view    <#view description#>
 *  @param control <#control description#>
 */
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if (control == [self.view viewWithTag:10086]) {
        
        NSLog(@"左边是10086");
    } else {
        NSLog(@"右边是10010");
    }
    
}

/**
 *  点击地图上的标注视图所执行的方法
 *
 *  @param mapView <#mapView description#>
 *  @param view    <#view description#>
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    NSLog(@"view == %@", view);
    
}

/**
 *  地图区域发生改变时执行的方法
 *
 *  @param mapView  <#mapView description#>
 *  @param animated <#animated description#>
 */
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    NSLog(@"地图区域发生了改变");
    
}

// 长按手势添加标注视图
- (void)addAnnot:(UILongPressGestureRecognizer *)longPress {
    
    // 获取点击的点
    CGPoint point = [longPress locationInView:longPress.view];
    // 转化为地图上的2d坐标
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    // 创建一个标注视图
    ZCAnnotation *annotation = [[ZCAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = @"GuangZhou";
    annotation.subtitle = @"DongGuanZhuang Lu";
    
    static NSInteger a = 1;
    annotation.tag = a;
    a++;
    
    // 把标注视图添加到地图上
    [self.mapView addAnnotation:annotation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
