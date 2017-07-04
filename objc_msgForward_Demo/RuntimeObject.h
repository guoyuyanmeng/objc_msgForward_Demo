//
//  RuntimeObject.h
//  objc_msgForward_Demo
//
//  Created by kang on 2017/6/22.
//  Copyright © 2017年 kang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RuntimeObject : NSObject

@property (nonatomic,strong) id object;

- (id) initWithObject:(id)object;

/**
 *  获取所有属性及对应的值
 *
 */
-(NSDictionary *)getAllPropertiesAndValues;

/**
 *  获取对象的所有属性
 *
 *  @return 属性数组
 */
- (NSArray *)getAllProperties;

/**
 *  获取对象的所有方法
 */
-(NSArray *)getAllMethods;

@end
