//
//  WSMMessagingViewController.h
//  Mesh
//
//  Created by Cristian Monterroza on 8/23/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import <SOMessaging/SOMessage.h>
#import <SOMessaging/SOMessagingViewController.h>

@interface WSMMessagingViewController : SOMessagingViewController

@property (nonatomic, strong) WSMUser *currentUser;
@property (nonatomic, strong) WSMUser *recipient;

@end
