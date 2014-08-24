//
//  WSMAdvertiser.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMAdvertiser.h"
#import "WSMUserManager.h"
#import "WSMUser.h"

@interface WSMAdvertiser () <WSMCapabilityProvider, CBPeripheralDelegate>



@property (nonatomic, strong) CBCentral *currentCentral;
@property (nonatomic, strong) CBCharacteristic *currentCharacteristic;
@property (nonatomic, strong) NSData *currentDataTransmission;
@property (nonatomic) NSUInteger currentDataTransmissionPosition;
@property (nonatomic) BOOL sendingEOM;

#pragma mark - Peripheral Properties

@property (nonatomic, strong) dispatch_queue_t capabilityQueue;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

#pragma mark - Current State

@property (nonatomic, strong) WSMUser *currentUser;
@property (nonatomic, strong) RACDisposable *userSubscription;
@property (nonatomic) RACSubject *capabilitySubject;
@property (nonatomic) WSMCapabilityState advertiserState;

@end

@implementation WSMAdvertiser

#pragma mark - Class Methods

WSM_SINGLETON_WITH_NAME(sharedInstance)

+ (CBMutableCharacteristic *)characteristicWithUUID:(NSString *)uuidString {
    return [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:uuidString]
                                              properties:CBCharacteristicPropertyNotify
                                                   value:nil
                                             permissions:CBAttributePermissionsReadable];
}

- (instancetype)init {
    if (!(self = [super init])) return nil;
    return self;
}

- (void)start {
    [self startAdvertising];
}

- (void)stop {
    [self.peripheralManager stopAdvertising];
}

- (void)subscribeToUser:(RACSubject *)subject {
    self.userSubscription = [subject subscribeNext:^(WSMUser *user) {
        NSLog(@"User has changed!");
        self.currentUser = user;
        [self startAdvertising];
    }];
}

- (void)setUserSubscription:(RACDisposable *)userSubscription {
    if (_userSubscription) {
        [_userSubscription dispose];
    }
    _userSubscription = userSubscription;
}

#pragma mark - Lazy Property Instantiation

- (CBPeripheralManager *)peripheralManager {
    return WSM_LAZY(_peripheralManager, ({
        NSDictionary *info = NSBundle.mainBundle.infoDictionary;
        NSDictionary *options = @{ CBPeripheralManagerOptionShowPowerAlertKey:@1,
                                   CBPeripheralManagerOptionRestoreIdentifierKey:info[@"CFBundleIdentifier"]};
        CBPeripheralManager *manager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                               queue:self.capabilityQueue
                                                                             options:options];
        [manager removeAllServices];
        manager;
    }));
}

- (RACSubject *)capabilitySubject {
    return WSM_LAZY(_capabilitySubject, [RACSubject subject]);
}

#define peripheralQueueString "com.mesh.pm"

- (dispatch_queue_t)capabilityQueue {
    return WSM_LAZY(_capabilityQueue,
                    dispatch_queue_create(peripheralQueueString, DISPATCH_QUEUE_SERIAL));
}

- (CBMutableCharacteristic *)userPropertiesCharacteristic {
    return WSM_LAZY(_userPropertiesCharacteristic,
                    [WSMAdvertiser characteristicWithUUID:userPropertiesCharacteristicString]);
}

- (CBMutableCharacteristic *)syncCharacteristic {
    return WSM_LAZY(_syncCharacteristic,
                    [WSMAdvertiser characteristicWithUUID:userSyncCharacteristicString]);
}

- (CBMutableService *)service {
    return WSM_LAZY(_service, ({
        CBMutableService *newService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:serviceUUIDString]
                                                                      primary:YES];
        newService.characteristics = @[self.userPropertiesCharacteristic, self.syncCharacteristic];
        newService;
    }));
}

#pragma mark - CBPeripheralmanager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"Manager state did update: %li", peripheral.state);
    WSMCapabilityState state = [WSMAdvertiser capabilityStateFromPeripheralManager:peripheral];
    [self.capabilitySubject sendNext:[NSNumber numberWithUnsignedInteger:state]];
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn: {
            NSLog(@"Power On!");
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [self.peripheralManager addService:self.service];
            });
            if (self.currentUser) [self startAdvertising];
        } break;
        case CBPeripheralManagerStatePoweredOff: {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogError(@"Turn on Bluetooth! %d", (int)peripheral.state);
                [[[UIAlertView alloc] initWithTitle:@"Bluetooth must be enabled"
                                            message:@"to configure your device."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            });
            self.advertiserState = kWSMCapabilityStateSettings;
            [peripheral stopAdvertising];
        } break;
        default: {
            self.advertiserState = kWSMCapabilityStateUnknown;
        } break;
    }
}

- (void)startAdvertising {
    if (!self.peripheralManager.isAdvertising && self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        NSDictionary *info = NSBundle.mainBundle.infoDictionary;
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:info[@"CFBundleIdentifier"],
                                                   CBAdvertisementDataServiceUUIDsKey:@[self.service.UUID]}];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        DDLogError(@"Error: %@", error);
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:2.5
                                         target:self
                                       selector:@selector(printAdvertisingState:)
                                       userInfo:nil
                                        repeats:YES];
    });
}

- (void)printAdvertisingState:(NSTimer *)timer {
    NSLog(@"%i", self.peripheralManager.isAdvertising);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        DDLogError(@"Error: %@", error);
        return;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"Read request: %@", request);
    [peripheral respondToRequest:request withResult: CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID.UUIDString isEqualToString: self.syncCharacteristic.UUID.UUIDString]) {
        NSLog(@"Should we sync?");
        if (self.currentUser) {
            __block NSMutableDictionary *dictionary;
            self.currentCentral = central;
            self.currentCharacteristic = characteristic;
            self.currentDataTransmissionPosition = 0;
            self.sendingEOM = NO;
            
            dispatch_semaphore_t putSemaphore = dispatch_semaphore_create(0);
            [[CBLManager sharedInstance] doAsync:^{
                dictionary = self.currentUser.document.properties.mutableCopy;
                dispatch_semaphore_signal(putSemaphore);
            }];
            dispatch_semaphore_wait(putSemaphore, DISPATCH_TIME_FOREVER);
            
            NSDictionary *syncDictionary = [dictionary dictionaryWithValuesForKeys:@[@"_id", @"_rev"]];
            
            NSError *error;
            NSData *data = [CBLJSON dataWithJSONObject:syncDictionary options:0 error:&error];
            if (data) {
                NSLog(@"Grabbing the user dictionary (%lu): %@", (unsigned long)data.length, dictionary);
                self.currentDataTransmission = data;
            } else {
                NSLog(@"NO DATA from Dictionary (%@): %@", error, dictionary);
            }
            
            [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow
                                                     forCentral:central];
            [self sendUserProperties];
        }
    } else if ([characteristic.UUID.UUIDString isEqualToString: self.userPropertiesCharacteristic.UUID.UUIDString]) {
        if (self.currentUser) {
            NSLog(@"Did subscribe: %@", characteristic);
            __block NSMutableDictionary *dictionary;
            __block NSData *avatarData;
            self.currentCentral = central;
            self.currentCharacteristic = characteristic;
            self.currentDataTransmissionPosition = 0;
            self.sendingEOM = NO;
            
            dispatch_semaphore_t putSemaphore = dispatch_semaphore_create(0);
            [[CBLManager sharedInstance] doAsync:^{
                dictionary = self.currentUser.document.properties.mutableCopy;
                if (self.currentUser.attachmentNames.count) {
                    avatarData = [[self.currentUser attachmentNamed:@"avatar"] content];
                }
                dispatch_semaphore_signal(putSemaphore);
            }];
            dispatch_semaphore_wait(putSemaphore, DISPATCH_TIME_FOREVER);
            if (avatarData) {
                dictionary[@"avatar"] = [avatarData base64EncodedStringWithOptions:NSUTF8StringEncoding];
            }
            [dictionary removeObjectForKey:@"_attachments"];
            [dictionary removeObjectForKey:@"_rev"];
            
            NSError *error;
            NSData *data = [CBLJSON dataWithJSONObject:dictionary options:0 error:&error];
            if (data) {
                NSLog(@"Grabbing the user dictionary (%lu): %@", (unsigned long)data.length, dictionary);
                self.currentDataTransmission = data;
            } else {
                NSLog(@"NO DATA from Dictionary (%@): %@", error, dictionary);
            }
            [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow
                                                     forCentral:central];
            [self sendUserProperties];
        }
    }
}

#define DEFAULT_MTU 20
/**
 Sends the next amount of data to the connected central
 */

- (void)sendUserProperties {
    // First up, check if we're meant to be sending an EOM
    if (self.sendingEOM) { // send it
        NSData *eomData = [eomSignal dataUsingEncoding:NSUTF8StringEncoding];
        BOOL didSend = [self.peripheralManager updateValue:eomData
                                         forCharacteristic:self.userPropertiesCharacteristic
                                      onSubscribedCentrals:nil];
        
        // Did it send? Mark it as sent
        self.sendingEOM = !didSend;
        [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyHigh
                                                 forCentral:self.currentCentral];
        WSMLog(didSend, @"Sent: EOM");
        // If it didn't send we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data, unless there is none left.
    if (self.currentDataTransmissionPosition >= self.currentDataTransmission.length) {
        // No data left.  Do nothing
        NSLog(@"Nothing left to send");
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    BOOL didSend = YES;
    while (didSend) {
        // Make the next chunk
        // Work out how big it should be
        NSUInteger amountToSend = self.currentDataTransmission.length - self.currentDataTransmissionPosition;
        if (amountToSend > self.currentCentral.maximumUpdateValueLength) {
            amountToSend = self.currentCentral.maximumUpdateValueLength;
        }
        
        NSUInteger maxAmountToSend = DEFAULT_MTU;
        // Can't be longer than 20 bytes
        if (self.currentCentral) {
            if (self.currentCentral.maximumUpdateValueLength > DEFAULT_MTU) {
                maxAmountToSend = self.currentCentral.maximumUpdateValueLength;
            } else {
                NSLog(@"MTU Ex: %lu", (unsigned long)self.currentCentral.maximumUpdateValueLength);
            }
        }
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.currentDataTransmission.bytes + self.currentDataTransmissionPosition
                                       length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk
                                    forCharacteristic:self.userPropertiesCharacteristic
                                 onSubscribedCentrals:nil];
        NSLog(@"Sending Chunk!");
        if (!didSend) return; // If it didn't work, drop out and wait for the callback to try again.
        
        // It did send, so update our index
        self.currentDataTransmissionPosition += amountToSend;
        
        // Was it the last one?
        if (self.currentDataTransmissionPosition >= self.currentDataTransmission.length) {
            // It was - send an EOM
            // Set this so if the send fails, we'll send it next time
            self.sendingEOM = YES;
            
            BOOL eomSent = [self.peripheralManager updateValue:[eomSignal dataUsingEncoding:NSUTF8StringEncoding]
                                             forCharacteristic:self.userPropertiesCharacteristic
                                          onSubscribedCentrals:nil];
            if (eomSent) {
                // If sent, we're all done
                self.sendingEOM = NO;
                [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyHigh
                                                         forCentral:self.currentCentral];
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    [self sendUserProperties];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    DDLogError(@"We need this for state restoration.");
}

#pragma mark - WSMCapabilityProvider Protocol

+ (WSMCapabilityState)capabilityStateFromPeripheralManager:(CBPeripheralManager *)peripheral {
    WSMCapabilityState state;
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn: {
            state = kWSMCapabilityStateOn;
        } break;
        case CBPeripheralManagerStatePoweredOff: {
            state = kWSMCapabilityStateSettings;
        } break;
        default: {
            state = kWSMCapabilityStateUnknown;
        } break;
    }
    return state;
}

+ (NSString *)capabilityDescription {
    return @"Allow other nearby users to find you.";
}

+ (BOOL)requireAuthentication {
    return NO;
}

- (WSMCapabilityState)capabilityState {
    return [WSMAdvertiser capabilityStateFromPeripheralManager: self.peripheralManager];
}

- (RACSignal *)capabilitySignal {
    return (RACSignal *) self.capabilitySubject;
}

@end
