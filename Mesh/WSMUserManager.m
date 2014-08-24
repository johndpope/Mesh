//
//  WSMUserManager.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMUserManager.h"
#import "WSMUser.h"

@interface WSMUserManager ()

#pragma mark - Propery Declarations

@property (nonatomic, strong) NSMutableArray *capabilityProviders;

@property (nonatomic, strong) dispatch_queue_t globalCapabilityQueue;
@property (nonatomic, strong, readwrite) NSArray *nearbyUsers;

#pragma mark - State
@property (nonatomic, strong) WSMUser *currentUser;
@property (nonatomic, strong) RACSubject *userSubject;
@property (nonatomic, readwrite) WSMUserManagerState managerState;
@property (nonatomic, strong) RACSignal *currentStateSignal;

@end

@implementation WSMUserManager

@synthesize currentUser = _currentUser;

#pragma mark - Class Methods.

WSM_SINGLETON_WITH_NAME(sharedInstance)


+ (instancetype)sharedInstanceWithQueue:(dispatch_queue_t)queue {
    [self.sharedInstance setGlobalCapabilityQueue:queue];
    return self.sharedInstance;
}

+ (BOOL)authenticated {
    WSMUserManager *manager = [WSMUserManager sharedInstance];
    return manager.currentUser && manager.capabilitiesAuthorized;
}

#pragma mark - Initialization.

- (instancetype)init {
    if ((self = [super init])) {}
    return self;
}

#pragma mark - Lazy Property Instantiation

- (NSMutableArray *)capabilityProviders {
    return WSM_LAZY(_capabilityProviders, @[].mutableCopy);
}

- (RACSubject *)userSubject {
    return WSM_LAZY(_userSubject, [RACSubject subject]);
}

- (NSArray *)nearbyUsers {
    return WSM_LAZY(_nearbyUsers, @[].mutableCopy);
}

#pragma mark - Methods.

- (NSArray *)authenticationDelegates {
    return [NSArray arrayWithArray: self.capabilityProviders];
}

- (NSArray *)shouldDisplayPermissionControllers {
    return nil;
}

- (void)registerCapabilities:(NSArray *)capabilities {
    NSMutableArray *signals = @[].mutableCopy;
    for (id<WSMCapabilityProvider> provider in capabilities) {
        NSLog(@"Provider Class: %@", provider.class);
        //Provide globalQueue.
        if ([provider respondsToSelector:@selector(setCapabilityQueue:)]) {
            [provider setCapabilityQueue:self.globalCapabilityQueue];
        }
        [self subscribeToProviderSubjects:provider]; //Subscribe to provider states.
        [provider subscribeToUser:self.userSubject]; //Supply the provider with user notifications.
        
        [signals addObject:provider.capabilitySignal]; //Gather up the provider state subjects.
        [self.capabilityProviders addObject:provider]; //Add to list of known Providers
        if ([provider respondsToSelector:@selector(registered)]) {
            [provider registered];
        }
    }
    //Combine the subjects for a global state.
    [self deriveGlobalState:signals];
}

- (void)subscribeToProviderSubjects:(id<WSMCapabilityProvider>)provider {
    [provider.capabilitySignal subscribeNext:^(NSNumber *state) {
        NSLog(@"Provider auth state changed!");
    }];
    
    if (![provider respondsToSelector:@selector(nearbyDevicePropertiesSignal)]) return;
    NSLog(@"Someone can sense devices!");
    
    RAC(self, nearbyUsers) = [[provider nearbyDevicePropertiesSignal] map:^id(NSMutableDictionary *devicePropertyDictionary) {
        NSMutableArray *usersArray = @[].mutableCopy;
        for (NSString *userKey in devicePropertyDictionary) {
            NSMutableDictionary *userProperties = devicePropertyDictionary[userKey];
            if (userProperties.count) {
                [usersArray addObject:[WSMUser userWithProperties:userProperties]];
            }
        }
        return usersArray;
    }];
}

- (void)deriveGlobalState:(NSArray *)signals {
    NSAssert(signals.count == 3, @"This is a hackathon.");
    self.currentStateSignal = [RACSignal combineLatest:signals];
    
    RAC(self, managerState) = [self.currentStateSignal reduceEach:^(NSNumber *state1, NSNumber *state2, NSNumber *state3) {
        NSLog(@"All providers intiated and broadcasting status updates");
        return @0;
    }];
}

- (BOOL)capabilitiesAuthorized {
    for (id<WSMCapabilityProvider> provider in self.capabilityProviders) {
        NSLog(@"Provider: %@ State: %lu", provider.class, provider.capabilityState);
        if (provider.capabilityState != kWSMCapabilityStateOn) return NO;
    }
    return YES;
}

- (void)start:(NSArray *)capabilities {
    for (id<WSMCapabilityProvider> provider in capabilities) {
        if ([provider respondsToSelector:@selector(start)]) {
            NSLog(@"Starting: %@", provider);
            [provider start];
        }
    }
}

- (void)stop:(NSArray *)capabilities {
    for (id<WSMCapabilityProvider> provider in capabilities) {
        if ([provider respondsToSelector:@selector(stop)]) {
            NSLog(@"Starting: %@", provider);
            [provider stop];
        }
    }
}
/**
 Checks to see if there is current user
 */

- (WSMUser *)currentUser {
    return WSM_LAZY(_currentUser, ({
        WSMUser *user = [WSMUser defaultUser];
        if (user) [self.userSubject sendNext:user];
        user;
    }));
}

- (WSMUser *)createDefaultUserWithParams:(NSDictionary *)params {
    return (self.currentUser = [WSMUser createDefaultUserWithProperties:params]);
}

- (void)setCurrentUser:(WSMUser *)currentUser {
    [WSMUser setDefaultUser:currentUser];
    [self.userSubject sendNext:currentUser];
}

@end
