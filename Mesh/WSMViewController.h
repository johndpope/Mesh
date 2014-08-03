//
//  WSMViewController.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/31/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSMViewController : UIViewController

@property (nonatomic, strong) WSMUser *currentUser;
@property (nonatomic, strong) UIStoryboard *mainStoryboard;

- (void)authenticated;

@end
