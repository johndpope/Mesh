//
//  WSMMessagingViewController.h
//  Mesh
//
//  Created by Cristian Monterroza on 8/23/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import <SOMessaging/SOMessagingViewController.h>

@class SOMessagingViewController;

@interface WSMMessagingViewController : SOMessagingViewController

@property (nonatomic, strong) WSMUser *currentUser;
@property (nonatomic, strong) WSMUser *recipient;

@property (nonatomic, strong) NSString *conversationIdentifier;

@end
