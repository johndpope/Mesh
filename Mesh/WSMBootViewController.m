//
//  WSMBootViewController.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/31/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMBootViewController.h"
#import "WSMMeshLogoButton.h"
#import "WSMAuthViewController.h"

@interface WSMBootViewController ()

@property (nonatomic, strong) IBOutlet WSMMeshLogoButton *meshLogo;

@end

@implementation WSMBootViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    return self;
}

- (void)loadView {
    [super loadView];
    [self hideNavigationController];
}

#define mainTabBarControllerSegue @"mainTabBarController"

- (void)viewDidLoad {
    [super viewDidLoad];
    [[WSMUserManager.sharedInstance.currentStateSignal takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {}];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Current User: %@", WSMUserManager.sharedInstance.currentUser);
        NSLog(@"UserManager Auth: %i", WSMUserManager.authenticated);
        NSLog(@"LYRManager: %i", [[LYRClient sharedClient] isUserAuthenticated]);
        if (self.currentUser) {
            [self performSegueWithIdentifier:mainTabBarControllerSegue sender:self];
        } else {
            WSMAuthViewController *authenticationController = [self.mainStoryboard instantiateViewControllerWithIdentifier:WSM_BOARD_AUTHENTICATION_CONTROLLER];
            authenticationController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:authenticationController animated:YES completion:^{}];
        }
    });
}

- (void)authenticated {
    [self performSegueWithIdentifier:mainTabBarControllerSegue sender:self];
}

#pragma mark - Navigation Controller code!

- (void)showNavigationController {
    NSLog(@"BEGIN We are going to show the Navigation Controller");
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton = YES;
}

- (void)hideNavigationController {
    NSLog(@"BEGIN We are going to hide the Navigation Controller");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
