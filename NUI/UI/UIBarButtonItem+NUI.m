//
//  UIBarButtonItem+NUI.m
//  NUIDemo
//
//  Created by Tom Benner on 12/9/12.
//  Copyright (c) 2012 Tom Benner. All rights reserved.
//

#import "UIBarButtonItem+NUI.h"

@implementation UIBarButtonItem (NUI)

@dynamic nuiClass;
@dynamic nuiIsApplied;

- (void)initNUI
{
    if (!self.nuiClass) {
        self.nuiClass = @"BarButton";
    }
}

- (void)override_didMoveToWindow
{
    if (!self.nuiIsApplied) {
        [self initNUI];
        [self didMoveToWindowNUI];
        self.nuiIsApplied = [NSNumber numberWithBool:YES];
    }
    [self override_didMoveToWindow];
}

- (void)didMoveToWindowNUI
{
    if (![self.nuiClass isEqualToString:@"none"]) {
        [NUIRenderer renderBarButtonItem:self withClass:self.nuiClass];
    }
}

- (void)setNuiClass:(NSString*)value {
    objc_setAssociatedObject(self, "nuiClass", value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)nuiClass {
    return objc_getAssociatedObject(self, "nuiClass");
}

- (void)setNuiIsApplied:(NSNumber*)value {
    objc_setAssociatedObject(self, "nuiIsApplied", value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)nuiIsApplied {
    return objc_getAssociatedObject(self, "nuiIsApplied");
}

@end
