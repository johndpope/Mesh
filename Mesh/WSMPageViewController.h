//
//  WSPageViewController.h
//  FrogScroller
//
//  Created by Cristian A Monterroza on 7/23/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

/*
 WSPageViewControllerDataSource extends the original DataSource be requiring two methods.
 The factory Page Instantiation methods depend on the implementation of these methods.
 */

@protocol WSMPageViewControllerDataSource <UIPageViewControllerDataSource>
@required

/**
 Informs the WSPageViewController what is the last page.
 */
- (NSInteger) pageCount;

/**
 Allows for differnet UIViewControllers to be generated depending on PageIndex. 
 It is recommended that the Page factory methods be used when instantiating controllers.
 A generic implementation could simply return a [UIViewController controllerForPage:].
 */
- (UIViewController *) controllerForPage: (NSInteger) pageIndex;

@end

@interface UIPageViewController (WSMPageViewController)

/**
 This method returns pages with values as low as "0" (zero) before the current page.
 It is expected that the current viewcontroller have a valid page number.
 */

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
      viewControllerBeforeViewController:(UIViewController *)vc;

/**
 This method returns pages with values as high as the last page as set by the UIPageControllerDataSource object returns.
 It is expected that the current viewcontroller have a valid page number.
 */

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
       viewControllerAfterViewController:(UIViewController *)vc;

@end

@interface UIViewController (WSMPageInstantiation)

/**
 The pageIndex property is set through an associated object. 
 */

@property (nonatomic) NSInteger pageIndex;

/**
 Default factory method when creating a UIViewController without a storyboard.
 The UIViewControllers init method will be called and the pageIndex will be set right after.
 This allows for customization as early as the loadView method (called before viewDidLoad).
 */

+ (instancetype) controllerForPage: (NSInteger)pageIndex;

/**
 Default factory method when creating a UIViewController with a storyboard.
 The UIViewControllers init method will be called and the pageIndex will be set right after.
 This allows for customization as early as the loadView method (called before viewDidLoad).
 */

+ (instancetype) controllerForPage: (NSInteger)pageIndex
                        storyboard: (NSString*) boardIdentifier
                        identifier: (NSString*) controllerIdentifier;

@end
