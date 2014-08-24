//
//  WSMLayerManager.m
//  rendezvous
//
//  Created by Cristian Monterroza on 7/24/14.
//
//

#import "WSMLayerManager.h"
#import "WSMUserManager.h"

@interface WSMLayerManager () <WSMCapabilityProvider>

#pragma mark - Client

@property (nonatomic, strong) LYRClient *client;

#pragma mark - State

@property (nonatomic, strong) WSMUser *currentUser;
@property (nonatomic, strong) RACDisposable *userSubscription;
@property (nonatomic, strong) RACSubject *capabilitySubject;

@end

@implementation WSMLayerManager

WSM_SINGLETON_WITH_NAME(sharedInstance);

- (instancetype)init {
    if ((self = [super init])) {
        _client = [LYRClient sharedClient];
        _client.delegate = self;
        [_client setAppKey:@"8263a0acd7aab93b6689adb00891fbce"];
        [_client start];
    }
    return self;
}

- (RACSubject *)capabilitySubject {
    return WSM_LAZY(_capabilitySubject, RACSubject.subject);
}

- (void)subscribeToUser:(RACSubject *)subject {
    self.userSubscription = [subject subscribeNext:^(WSMUser *user) {
        NSLog(@"User has changed!");
        self.currentUser = user;
    }];
}

- (void)setUserSubscription:(RACDisposable *)userSubscription {
    if (_userSubscription) {
        [_userSubscription dispose];
    }
    _userSubscription = userSubscription;
}

+ (BOOL)requireAuthentication {
    return YES;
}

- (WSMCapabilityState)capabilityState {
    NSLog(@"Layer ON: %i", self.client.isUserAuthenticated);
    if (self.client.isUserAuthenticated) {
        return kWSMCapabilityStateOn;
    } else {
        return kWSMCapabilityStateSettings;
    }
}

#pragma mark - LYRDelegate

- (void)layerClient:(LYRClient *)client didSendMessages:(NSArray *)messages {
    NSLog(@"Sent message: %@", messages);
}

- (void)layerClient:(LYRClient *)client didReceiveMessages:(NSArray *)messages {
    NSLog(@"What? %@", messages);
    [client fetchMessageBodiesForMessages:messages progress:^(float percent) {
        NSLog(@"Progress: %f", percent);
    } completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error!");
        }
    }];
}

- (void)layerClient:(LYRClient *)client didChangeStatus:(LYRClientStatus)status error:(NSError *)error {
    NSLog(@"LYR Status: %i", client.isUserAuthenticated);
    [self.capabilitySubject sendNext:@(client.isUserAuthenticated)];
}

#pragma mark - Capability Provider

+ (NSString *)capabilityDescription {
    return @"Talk to the people around you!";
}

- (RACSignal *)capabilitySignal {
    return RACObserve(self.client, isUserAuthenticated);
}

@end
