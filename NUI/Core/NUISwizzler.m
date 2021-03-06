//
//  NUISwizzler.m
//  NUIDemo
//
//  Created by Tom Benner on 12/9/12.
//  Copyright (c) 2012 Tom Benner. All rights reserved.
//

#import "NUISwizzler.h"

@implementation NUISwizzler

- (void)swizzleAll
{
    [self swizzleDidMoveToWindow:[UIBarButtonItem class]];
    [self swizzleDidMoveToWindow:[UIButton class]];
    [self swizzleDidMoveToWindow:[UILabel class]];
    [self swizzleDidMoveToWindow:[UINavigationBar class]];
    [self swizzleDidMoveToWindow:[UINavigationItem class]];
    [self swizzleDidMoveToWindow:[UISegmentedControl class]];
    [self swizzleDidMoveToWindow:[UITabBar class]];
    [self swizzleDidMoveToWindow:[UITableViewCell class]];
    [self swizzleDidMoveToWindow:[UITextField class]];
    [self swizzleDidMoveToWindow:[UIView class]];
    
    // didMoveToWindow isn't called on UITabBarItems, so we need to use awakeFromNib instead.
    [self swizzleAwakeFromNib:[UITabBarItem class]];
}

- (void)swizzleAwakeFromNib:(Class)class
{
    [self swizzle:class from:@selector(awakeFromNib) to:@selector(override_awakeFromNib)];
}

- (void)swizzleDidMoveToWindow:(Class)class
{
    [self swizzle:class from:@selector(didMoveToWindow) to:@selector(override_didMoveToWindow)];
}

- (void)swizzle:(Class)class from:(SEL)original to:(SEL)new
{
    Method originalMethod = class_getInstanceMethod(class, original);
    Method newMethod = class_getInstanceMethod(class, new);
    if(class_addMethod(class, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
