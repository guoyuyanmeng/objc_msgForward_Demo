//
//  ViewController.m
//  objc_msgForward_Demo
//
//  Created by kang on 2017/6/15.
//  Copyright © 2017年 kang. All rights reserved.
//

#import "ViewController.h"
#import "MsgObject.h"
#import "RuntimeObject.h"
#import <objc/runtime.h>
#import <objc/objc.h>
@interface ViewController ()

@end

@implementation ViewController


void dynamicErrorInfo(id self, SEL _cmd)
{
    NSString * selStr = NSStringFromSelector(_cmd);
    NSLog(@"%@ method ipmlementation in VC \n",selStr);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //http://www.jianshu.com/p/6517ab655be7 warnning 解释
    
    MsgObject *msgObject = [[MsgObject alloc] init];
//    SEL instanceSEL = NSSelectorFromString(@"instanceForwardTest");
//    SEL classSEL = NSSelectorFromString(@"classForwardTest");
//
//    class_addMethod(msgObject.class, instanceSEL, (IMP)dynamicErrorInfo,"@@:");
//    class_addMethod(objc_getMetaClass("MsgObject"), classSEL, (IMP)dynamicErrorInfo,"@@:");
    
//    class_addMethod(msgObject.class, instanceSEL, (IMP)dynamicErrorInfo,"@@:");
//    Class class = objc_getClass("MsgObject");
//    Class superclass = objc_getClass((__bridge void *)class);
//    Class superclass2 = objc_getClass((__bridge void *)superclass);
//    Class metaclass = objc_getMetaClass("MsgObject");
//    Class classSuperclass = MsgObject.superclass;
//    NSLog(@" class isa pointer  %p", class);
//    NSLog(@" superclass isa pointer  %p", superclass);
//    NSLog(@" metaclass isa pointer  %p", metaclass);
//    NSLog(@" classSuperclass isa pointer  %p", classSuperclass);
//    class_addMethod(superclass2, classSEL, (IMP)dynamicErrorInfo,"@@:");
    
//
//
//    NSLog(@"                                            ");
//    NSLog(@"**************************************** \n");
//    NSLog(@"                                            ");
//
    class_addIvar(msgObject.class, "age", 8, 8, "NSString");
    RuntimeObject *runtimeObject = [[RuntimeObject alloc] initWithObject:msgObject];
//    [runtimeObject getAllMethods];
    NSArray *instancePropertyB =  [runtimeObject getAllProperties];
    NSLog(@"instanceProperty:%@",instancePropertyB);
    
    
    NSLog(@"                                            ");
    NSLog(@"**************************************** \n");
    NSLog(@"                                            ");
    
    RuntimeObject *runtimeClass = [[RuntimeObject alloc] initWithObject:objc_getMetaClass("MsgObject")];
//    [runtimeClass getAllMethods];
    NSArray *classProperty =  [runtimeClass getAllProperties];
    NSLog(@"classProperty:%@",classProperty);
    
    NSLog(@"                                            ");
    NSLog(@"**************************************** \n");
    NSLog(@"                                            ");
    
    [self instanceForward:@"instanceForwardTest"];
    [self classFoward:@"classForwardTest"];
    
    NSLog(@"                                            ");
    NSLog(@"**************************************** \n");
    NSLog(@"                                            ");
    
    [self testClassMethodName:@"classForwardTest"];
    [self testInstanceMethodName:@"instanceForwardTest"];
    
    NSLog(@"                                            ");
    NSLog(@"**************************************** \n");
    NSLog(@"                                            ");
    
    
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - 消息转发测试

// 类的消息转发
- (void) classFoward:(NSString *)methodName {
    SEL classSEL = NSSelectorFromString(methodName);
    [MsgObject performSelector:classSEL];
}


// 实例对象消息转发
- (void) instanceForward:(NSString *) methodName {
    MsgObject *obj = [[MsgObject alloc] init];
//    SEL instanceSEL = NSSelectorFromString(methodName);
//    [obj performSelector:instanceSEL];
    
    /**
     * 原文链接：https://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
     * 翻译链接：http://www.jianshu.com/p/6517ab655be7
     *
     */
    
    /**
     *  warning: performSelector may cause a leak because its selector is unknown 产生的原因
     *
     *  在 ARC 下调一个方法，runtime 需要知道对于返回值该怎么办。返回值可能有各种类型：void，int，char，NSString *，id等等。ARC 一般是根
     *  返回值的头文件来决定该怎么办的[3]，一共有以下 4 种情况：
     
     *  1.直接忽略（如果是基本类型比如 void，int这样的）。
     *  2.把返回值先 retain，等到用不到的时候再 release（最常见的情况）。
     *  3.不 retain，等到用不到的时候直接 release（用于 init、copy 这一类的方法，或者标注ns_returns_retained的方法）。
     *  4.什么也不做，默认返回值在返回前后是始终有效的（一直到最近的 release pool 结束为止，用于标注ns_returns_autoreleased的方法）。
     *
     *  而调performSelector:的时候，系统会默认返回值并不是基本类型，但也不会 retain、release，也就是默认采取第 4 种做法。所以如果那个方法本
     *  应该属于前 3 种情况，都有可能会造成内存泄漏。
     *
     *  对于返回void或者基本类型的方法，就目前而言你可以忽略这个 warning，但这样做不一定安全。我看过 Clang 在处理返回值这块儿的几次迭代演进。一
     *  旦开着 ARC，编译器会觉得从performSelector:返回的对象没理由不能 retain，不能 release。在编译器眼里，它就是个对象。所以，如果返回值是
     *  本类型或者void，编译器还是存在会 retain、release 它的可能，然后直接导致 crash。
     *
     */
    
    
    /**
     *  消除warning方法:
     *
     * 1.向 obj 请求那个方法对应的 C 函数指针。
     *  所有的NSObject都能响应methodForSelector:这个方法，
     *  不过也可以用 Objective-C runtime 里的class_getMethodImplementation（只在 protocol 的情况下有用，id<SomeProto>这样的）。
     *  这函数指针叫做IMP，就是typedef过的函数指针（id (*IMP)(id, SEL, ...)[1]）。
     *  它跟方法签名(signature)比较像，虽然可能不是完全一样。
     *
     * 2.得到IMP之后，还需要进行转换，转换后的函数指针包含 ARC 所需的那些细节（比如每个 OC 方法调用都有的两个隐藏参数self和_cmd）。
     *  这就是 
     *  void (*func)(id, SEL) = (void *)imp;
     *  代码干的事（右边的那个(void *)只是告诉编译器，不用报类型强转的 warning)
     *
     * 3.最后一步，调用函数指针。
     *
     */
    SEL selector = NSSelectorFromString(methodName);
//    ((void (*)(id, SEL))[obj methodForSelector:selector])(obj, selector);
    IMP imp = [obj methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(obj, selector);
}

- (void) testClassMethodName:(NSString *)methodName {

    SEL classSEL = NSSelectorFromString(methodName);
    sel_registerName("methodName");
    [MsgObject performSelector:classSEL];
}


- (void) testInstanceMethodName:(NSString *)methodName {
    
    SEL classSEL = NSSelectorFromString(methodName);
    MsgObject *msgObject = [[MsgObject alloc] init];
    IMP imp = [msgObject methodForSelector:classSEL];
    void (*func)(id, SEL) = (void *)imp;
    func(msgObject, classSEL);
}


@end
