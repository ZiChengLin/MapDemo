//
//  ZCAnnotation.h
//  MapDemo
//
//  Created by 林梓成 on 15/7/1.
//  Copyright (c) 2015年 lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// 自定义的大头针的类需要遵守 MKAnnotation协议
@interface ZCAnnotation : NSObject <MKAnnotation>

// 下面三个属性是<MKAnnotation>里面的属性。我们自定义的类要重写它所有不能写错 CLLocationCoordinate2D是结构体
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *subtitle;

// 为了标示每个标注视图（大头针）
@property (nonatomic)NSInteger tag;

@end
