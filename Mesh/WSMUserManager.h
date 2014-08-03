//
//  WSMUserManager.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 daheins. All rights reserved.
//


#import "WSMUser.h"
#import "WSMAdvertiser.h"
#import "WSMScanner.h"
#import "WSMLayerManager.h"

#pragma mark - Enum, Option, block and Global String declarations.

typedef NS_ENUM(NSUInteger, WSMCapabilityState) {
    kWSMCapabilityStateUnknown,
    kWSMCapabilityStateSettings,
    kWSMCapabilityStateOn
};

typedef NS_OPTIONS(NSUInteger, WSMUserManagerState) {
    /** Initial status, while the manager tries to register capabilities. */
    WSMUserManagerStateInitialized  = 1UL << 0,
    /** Session status indicating everything is authorized and ready to go! */
    WSMUserManagerStateAuthorized   = 1UL << 1,
    /** Session status indicating an auth screen needs to be presented. */
    WSMUserManagerStateUnauthorized = 1UL << 2
};

// Temp before further modularization.

#define serviceUUIDString @"9D07C96F-AF59-40C9-80E3-4952173B6580"
#define userPropertiesCharacteristicString @"B19408E1-2D0D-4650-9E45-2DA006C462F5"
#define userSyncCharacteristicString @"B19408E1-2D0D-4650-9E45-2DA006C462F0"

#define eomSignal @"EOM"

/**
 * Manager responsible for handling the capabilities, and CBL database for locals users.
 */
@interface WSMUserManager : NSObject

#pragma mark - Instance Properties

@property (nonatomic, strong, readonly) RACSignal *currentStateSignal;

@property (nonatomic, readonly) WSMUserManagerState managerState;

@property (nonatomic, strong, readonly) WSMUser *currentUser;

@property (nonatomic, strong, readonly) NSArray *nearbyUsers;

#pragma mark - Class Methods

/**
 Returns or creates a WSMUserManager instance which loads the default user.
 If a default user is not specified, the current user returns nil.
 */

+ (instancetype)sharedInstance;

/**
 Calls sharedInstance and provides a dispatch queue which all capability providers will use. 
 */

+ (instancetype)sharedInstanceWithQueue:(dispatch_queue_t)queue;

/**
 Returns NO if there is no currentUser and any registered capability is not authorized.
 */

+ (BOOL)authenticated;

#pragma mark - Instance Methods

/**
 Takes in a vaid JSON dictionary, creates a user object, sets it to current User and returns it.
 */

- (WSMUser *)createDefaultUserWithParams:(NSDictionary *)params;

/**
 Register user capabilites. This can be called prior to setting the current user.
 */

- (void)registerCapabilities:(NSArray *)capabilities;

/**
 Returns a list of authentication delegates (the capability providers).
 */

- (NSDictionary *)authenticationDelegates;


/**
 Returns YES if all capabilities are authorized and the user is authenticated.
 */

//- (BOOL)authorized;

/**
 Starts capabilities. If nil, all registered capabilities will start.
 */

- (void)start:(NSArray *)capabilites;

/**
 Stops capabilities. If nil, all registered capabilities will stop.
 */

- (void)stop:(NSArray *)capabilities;

@end

/**
 Protocol for providing a capability to the user.
 */

@protocol WSMCapabilityProvider <NSObject>

@required

/**
 The singleton responsible for the capability.
 */

+ (instancetype)sharedInstance;

/**
 A short description of the capability. 
 */

+ (NSString *)capabilityDescription;

/**
 A boolean which checks to see if the sharedInstance is authenticated.
 */

+ (BOOL)requireAuthentication;

/**
 A required method to retrieve the current user.
 */

- (WSMUser *)currentUser;

/**
 A required method to set the current user.
 */

- (void)setCurrentUser:(WSMUser *)currentUser;

/**
 A required method to subscribe to currentUser updates.
 */

- (void)subscribeToUser:(RACSubject *)subject;

/**
 A required method to access the userSubscription.
 */

- (RACDisposable *)userSubscription;

/**
 The current state of the capability.
 */

- (WSMCapabilityState)capabilityState;


/**
 A method which should return the current state of the capability.
 */
- (RACSubject *)capabilitySignal;

/**
 A method which starts the current capability.
 */

- (void)start;

/**
 A method which ends the current capability.
 */

- (void)stop;

@optional

/**
 Called on capability registration.
 Nothing which depends on the current user, or queues should be created prior to this method.
 */

- (void)registered;

- (NSMutableDictionary *)nearbyDeviceProperties;

- (RACSubject *)nearbyDevicePropertiesSignal;

- (void)setCapabilityQueue:(dispatch_queue_t)queue;

@end