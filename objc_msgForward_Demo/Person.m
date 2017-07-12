//
//  Person.m
//  objc_msgForward_Demo
//
//  Created by kang on 2017/7/13.
//  Copyright © 2017年 kang. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void) personInstanceMethod {

    NSLog(@"personInstanceMethod");
}

+ (void) personClassMethod {
    
    NSLog(@"personClassMethod");
}

@end
