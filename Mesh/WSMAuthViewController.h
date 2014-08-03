//
//  WSMAuthViewController.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/30/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMViewController.h"

typedef NS_ENUM(NSUInteger, WSMAuthControllerType) {
    kWSMAuthControllerTypeSignUp,
    kWSMAuthControllerTypeSignIn
};

typedef NS_ENUM(NSUInteger, WSMAuthTableViewState) {
    kWSMAuthTableViewStateHidden,
    kWSMAuthTableViewStateShown,
    kWSMAuthTableViewStateRaised
};

@interface WSMAuthViewController : WSMViewController;

@end
