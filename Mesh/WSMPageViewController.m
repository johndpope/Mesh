//
//  WSPageViewController.m
//  FrogScroller
//
//  Created by Cristian A Monterroza on 7/23/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import "WSMPageViewController.h"
#import <objc/runtime.h>

@implementation UIPageViewController (WSMPageViewController)

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
      viewControllerBeforeViewController:(UIViewController *)vc {
    
    return vc.pageIndex > 0 ? [(id<WSMPageViewControllerDataSource>)self.dataSource controllerForPage:(vc.pageIndex - 1)] : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
       viewControllerAfterViewController:(UIViewController *)vc {
    
    BOOL isNotLastPage = (vc.pageIndex < ([(id<WSMPageViewControllerDataSource>)self.dataSource pageCount] - 1));
    return isNotLastPage ? [(id<WSMPageViewControllerDataSource>)self.dataSource controllerForPage:(vc.pageIndex + 1)] : nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

@implementation UIViewController (WSMPageInstantiation)
static const char *const pageIndexKey = "pageIndexKey";

+ (instancetype) controllerForPage: (NSInteger)pageIndex {
    UIViewController *controller = [self new];
    [controller setPageIndex: pageIndex];
    return controller;
}

+ (instancetype) controllerForPage: (NSInteger)pageIndex
                        storyboard: (NSString*) boardIdentifier
                        identifier: (NSString*) controllerIdentifier {
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName: boardIdentifier bundle:nil];
    UIViewController *controller = [mainBoard instantiateViewControllerWithIdentifier: controllerIdentifier];
    controller.pageIndex = pageIndex;
    return controller;
}

- (void) setPageIndex: (NSInteger) pageIndex {
    [self willChangeValueForKey: @"pageIndex"];
    NSLog(@"PageSet: %li", (long)pageIndex);
    objc_setAssociatedObject(self, &pageIndexKey, @(pageIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey: @"pageIndex"];
}

- (NSInteger) pageIndex {
    return [objc_getAssociatedObject(self, &pageIndexKey) integerValue];
}

@end
