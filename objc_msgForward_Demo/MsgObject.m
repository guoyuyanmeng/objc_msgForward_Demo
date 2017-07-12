//
//  MsgObject.m
//  objc_msgForward_Demo
//
//  Created by kang on 2017/6/15.
//  Copyright © 2017年 kang. All rights reserved.
//

#import "MsgObject.h"
#import <objc/runtime.h>

#import "Person.h"

@implementation MsgObject


//id dynamicMethod(id self, SEL _cmd)
//{
//    NSLog(@"%s:动态添加的方法",__FUNCTION__);
//    return @"1";
//}


//IMP class_getMethodImplementation(Class cls, SEL sel) {
//    if (!cls || !sel) return nil;
//    IMP imp = lookUpImpOrNil(cls, sel);
//    if (!imp) return _objc_msgForward; //_objc_msgForward 用于消息转发
//    return imp;
//}
//
//IMP lookUpImpOrNil(Class cls, SEL sel) {
//    if (!cls->initialize()) {
//        _class_initialize(cls);
//    }
//    
//    Class curClass = cls;
//    IMP imp = nil;
//    do { //先查缓存,缓存没有时重建,仍旧没有则向父类查询
//        if (!curClass) break;
//        if (!curClass->cache) fill_cache(cls, curClass);
//        imp = cache_getImp(curClass, sel);
//        if (imp) break;
//    } while (curClass = curClass->superclass);
//    
//    return imp;
//}

//- (void) printErrorInfo:(SEL)sel {
//    
//    NSString * selStr = NSStringFromSelector(sel);
//    NSLog(@"%@ does`t implementation",selStr);
//}


void printErrorInfo(id self, SEL _cmd)
{
    NSString * selStr = NSStringFromSelector(_cmd);
    NSLog(@"%@ does`t implementation \n",selStr);
    
}

//+ (void) printErrorInfo:(SEL)sel {
//    
//    NSString * selStr = NSStringFromSelector(sel);
//    NSLog(@"%@ does`t implementation",selStr);
//}




/*
 消息转发第一级响应方法：动态添加方法
 1、resolveClassMethod
 2、resolveInstanceMethod
 */
+ (BOOL) resolveClassMethod:(SEL)sel {

    NSLog(@"resolveClassMethod");
    BOOL result = [super resolveClassMethod:sel];
    
//    if (!result) {
    
        /*
         NSLog(@"dynamically add class method ");
         //        IMP imp = [self methodForSelector:@selector(printErrorInfo:)];
         //        IMP imp = [self instanceMethodForSelector:@selector(printErrorInfo:)];
         //        class_addMethod(self.superclass, sel, imp,"@@:");
        
         NSString *className  = NSStringFromClass(self);
         class_addMethod(objc_getMetaClass([className UTF8String]), sel, (IMP)printErrorInfo,"@@:");
        */
        
        /* 
         出现crash： +[MsgObject classForwardTest]: unrecognized selector sent to class 0x106405258
         不知道为什么
         class_addMethod(MsgObject.class, sel, (IMP)printErrorInfo,"@@:");
        */
//        return [super resolveClassMethod:sel];
//    }
    
    return result;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"resolveInstanceMethod");
    BOOL result = [super resolveInstanceMethod:sel];
//    if (!result) {
        /*
         NSLog(@"dynamically add instance method");
         //        IMP imp = [self instanceMethodForSelector:@selector(printErrorInfo:)];
         //        class_addMethod(self.class, sel, imp,"@@:");
         //        NSString *className  = NSStringFromClass(self);
         class_addMethod(self.class, sel, (IMP)printErrorInfo,"@@:");
         */
//        return [super resolveInstanceMethod:sel];
//    }
    
    return result;
}


/*
 消息转发第二级方法：转发消息到其他对象
 forwardingTargetForSelector
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
//    id result = [super forwardingTargetForSelector:aSelector];
//    NSLog(@"forwardingTargetForSelector");
//    return result;
    
    Person *person = [[Person alloc]init];
    return person;
}

+ (id)forwardingTargetForSelector:(SEL)aSelector {
    id result = [super forwardingTargetForSelector:aSelector];
    NSLog(@"forwardingTargetForSelector");
    return result;
}

/*
 消息转发第三级方法：转发消息到其他对象（多个）
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    id result = [super methodSignatureForSelector:aSelector];
    
    NSLog(@"methodSignatureForSelector");
    return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
//    [self performSelector:anInvocation.selector withObject:nil];
        [super forwardInvocation:anInvocation];
    NSLog(@"forwardInvocation");
}

/*
 消息转发第四级方法：消息未处理的提示
 */
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
    NSLog(@"doesNotRecognizeSelector");
    [super doesNotRecognizeSelector:aSelector]; // crash
}


@end
