//
//  MsgObject.m
//  objc_msgForward_Demo
//
//  Created by kang on 2017/6/15.
//  Copyright © 2017年 kang. All rights reserved.
//

#import "MsgObject.h"
#import <objc/runtime.h>
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


+ (BOOL) resolveClassMethod:(SEL)sel {

    BOOL result = [super resolveClassMethod:sel];
    if (!result) {
        NSLog(@"dynamically add class method ");
//        IMP imp = [self methodForSelector:@selector(printErrorInfo:)];
//        IMP imp = [self instanceMethodForSelector:@selector(printErrorInfo:)];
//        class_addMethod(self.superclass, sel, imp,"@@:");
        
        NSString *className  = NSStringFromClass(self);
        class_addMethod(objc_getMetaClass([className UTF8String]), sel, (IMP)printErrorInfo,"@@:");
        
        //出现crash： +[MsgObject classForwardTest]: unrecognized selector sent to class 0x106405258
        //不知道为什么
//        class_addMethod(MsgObject.class, sel, (IMP)printErrorInfo,"@@:");
        
        return [super resolveClassMethod:sel];
    }
    
    return result;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    BOOL result = [super resolveInstanceMethod:sel];
    if (!result) {
        NSLog(@"dynamically add instance method");
//        IMP imp = [self instanceMethodForSelector:@selector(printErrorInfo:)];
//        class_addMethod(self.class, sel, imp,"@@:");
//        NSString *className  = NSStringFromClass(self);
        class_addMethod(self.class, sel, (IMP)printErrorInfo,"@@:");
        return [super resolveInstanceMethod:sel];
    }
    
    return result;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    id result = [super forwardingTargetForSelector:aSelector];
    return result;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    id result = [super methodSignatureForSelector:aSelector];
    return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
//    [self performSelector:anInvocation.selector withObject:nil];
        [super forwardInvocation:anInvocation];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
    [super doesNotRecognizeSelector:aSelector]; // crash
}


@end
