//
//  WSMViewController.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/31/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMViewController.h"

@interface WSMViewController ()

@end

@implementation WSMViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (WSMUser *)currentUser {
    return [[WSMUserManager sharedInstance] currentUser];
}

- (UIStoryboard *)mainStoryboard {
    return WSM_LAZY(_mainStoryboard, [UIStoryboard storyboardWithName:WSM_BOARD_IPHONE_MAIN bundle:nil]);
}

- (void)authenticated {
    
}

@end
