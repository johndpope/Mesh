//
//  WSMScanner.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMScanner.h"
#import "WSMUserManager.h"
#import "WSMUser.h"

@interface WSMScanner () <WSMCapabilityProvider>

#pragma mark - Central Properties

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableArray *stagedDevices, *connectedDevices;
@property (nonatomic, strong) NSMutableData *currentTransmission;

@property (nonatomic, strong) NSNumber *inSync;
@property (nonatomic, strong) NSMutableArray *knownDevicesArray; //Unimplemented

#pragma mark - Current State

@property (nonatomic, strong) dispatch_queue_t capabilityQueue;

@property (nonatomic, strong) WSMUser *currentUser;
@property (nonatomic, strong) RACDisposable *userSubscription;
@property (nonatomic, strong) RACSubject *capabilitySubject;

@end

@implementation WSMScanner

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

- (void)registered {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(checkSyncStatus:)
                                       userInfo:nil
                                        repeats:YES];
    });
    //
    //    RAC(self, inSync) = [[RACSignal combineLatest:@[RACObserve(self, nearbyDeviceProperties), RACObserve(self, connectedDevices)]]
    //                         reduceEach:(id)^(NSMutableSet *set, NSMutableDictionary *dictionary) {
    //
    //                             return set.count == dictionary.count;
    //                         }];
}

- (void)checkSyncStatus:(NSTimer *)timer {
    NSLog(@"Are we in sync? D:%lu P:%lu", (unsigned long)self.connectedDevices.count, (unsigned long)self.nearbyDeviceProperties.count);
    for (CBPeripheral *peripheral in self.connectedDevices) {
        if (![self.nearbyDeviceProperties objectForKey:peripheral.identifier.UUIDString]) {
            NSLog(@"Peripheral: %@", peripheral);
            NSLog(@"Services: %@", peripheral.services);
            if (!peripheral.services) {
                [peripheral discoverServices:@[self.serviceUUID]];
            }
        }
    }
    
}

#pragma mark - Lazy Properties

- (CBCentralManager *)centralManager {
    return WSM_LAZY(_centralManager, ({
        [[CBCentralManager alloc] initWithDelegate:self queue:self.capabilityQueue options:@{}];
    }));
}

- (RACSubject *)capabilitySubject {
    return WSM_LAZY(_capabilitySubject, [RACSubject subject]);
}

- (RACSubject *)nearbyDevicePropertiesSignal {
    return WSM_LAZY(_nearbyDevicePropertiesSignal, [RACSubject subject]);
}

#define centralQueueString "com.mesh.cm"

- (dispatch_queue_t)capabilityQueue {
    return WSM_LAZY(_capabilityQueue,
                    dispatch_queue_create(centralQueueString, DISPATCH_QUEUE_SERIAL));
}

- (NSMutableArray *)stagedDevices {
    return WSM_LAZY(_stagedDevices, @[].mutableCopy);
}

- (NSMutableArray *)connectedDevices {
    return WSM_LAZY(_connectedDevices, @[].mutableCopy);
}

- (NSMutableDictionary *)nearbyDeviceProperties {
    return WSM_LAZY(_nearbyDeviceProperties, @{}.mutableCopy);
}

- (NSMutableArray *)knownDevicesArray {
    return WSM_LAZY(_knownDevicesArray, @[].mutableCopy);
}

- (CBUUID *)serviceUUID {
    return WSM_LAZY(_serviceUUID, [CBUUID UUIDWithString:serviceUUIDString]);
}

- (CBMutableCharacteristic *)userPropertiesCharacteristic {
    return WSM_LAZY(_userPropertiesCharacteristic,
                    [WSMScanner characteristicWithUUID:userPropertiesCharacteristicString]);
}

- (CBMutableCharacteristic *)syncCharacteristic {
    return WSM_LAZY(_syncCharacteristic,
                    [WSMScanner characteristicWithUUID:userSyncCharacteristicString]);
}

- (NSMutableData *)currentTransmission {
    return WSM_LAZY(_currentTransmission, [[NSMutableData alloc] init]);
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Manager state did update: %li", central.state);
    WSMCapabilityState state = [WSMScanner capabilityStateFromCentralManager: central];
    [self.capabilitySubject sendNext:[NSNumber numberWithUnsignedInteger:state]];
    switch (central.state) {
        case CBCentralManagerStatePoweredOn: {
            if (self.currentUser) {
                [self startScan];
            }
        } break;
        case CBCentralManagerStatePoweredOff: {} break;
        default: {} break;
    }
}

- (void)startScan {
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"Starting the scan.");
        [self.centralManager scanForPeripheralsWithServices:@[self.serviceUUID]
                                                    options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    if ([self deviceUnknown:peripheral]) {
        NSLog(@"%@", peripheral);
        [self.stagedDevices addObject:peripheral];
        [self.centralManager stopScan];
        [central connectPeripheral:peripheral options:nil];
    }
}

- (BOOL)deviceUnknown:(CBPeripheral *)peripheral {
    for (CBPeripheral *peri in [self.stagedDevices arrayByAddingObjectsFromArray: self.connectedDevices].objectEnumerator) {
        if ([peri.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            return NO;
        }
    }
    return YES;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Staged Devices: %lu", (unsigned long)self.stagedDevices.count);
    CBPeripheral *retainedPeripheral = [self getPreviouslyConnectedButStagedPeripheral:peripheral];
    retainedPeripheral.delegate = self;
    
    [self.connectedDevices addObject:retainedPeripheral];
    [self.stagedDevices removeObject:retainedPeripheral];
    
    [retainedPeripheral discoverServices:@[self.serviceUUID]];
    [self startScan];
    NSLog(@"Staged Devices: %lu Connected to People: %@", (unsigned long)self.stagedDevices.count, self.connectedDevices);
}

- (CBPeripheral *)getPreviouslyConnectedButStagedPeripheral:(CBPeripheral *)newPeripheral {
    for (CBPeripheral *stagedPeripheral in self.stagedDevices) {
        if ([stagedPeripheral.identifier.UUIDString isEqualToString:newPeripheral.identifier.UUIDString]) {
            return stagedPeripheral;
        }
    }
    return nil;
}

/** 
 An attempt to cleanup when things go wrong - usually 1309 error. or you're done with the connection.
 This cancels any subscriptions if there are any, or straight disconnects if not.
 (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"Failed to connect to person: %@", error);
    [self.centralManager stopScan];
    [self cancelConnection:peripheral completionBlock:^{
        [self startScan];
    }];
}

- (void)cancelConnection:(CBPeripheral *)peripheral completionBlock:(void (^)())completionBlock {
    NSLog(@"It has come to this.");
    [self.stagedDevices removeObject:peripheral];
    [self.connectedDevices removeObject:peripheral];
    
    // See if we are subscribed to a characteristic on the peripheral
    for (CBService *service in peripheral.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:peripheral];

    if (completionBlock) completionBlock();
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"This person just left: %@", peripheral);
    [self.connectedDevices removeObject:peripheral];
    [self.nearbyDeviceProperties removeObjectForKey:peripheral.identifier.UUIDString];
    [self.nearbyDevicePropertiesSignal sendNext:self.nearbyDeviceProperties];
}

#pragma mark - Peripheral Delegate
/** 
 The Transfer Service was discovered
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cancelConnection:peripheral completionBlock: nil];
    } else {
        for (CBService *service in peripheral.services) {
            NSLog(@"Discovering characteristics for service %@", service);
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cancelConnection:peripheral completionBlock: nil];
    } else {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:self.syncCharacteristic.UUID.UUIDString]) {
                NSLog(@"Trying to sync characteristic %@", characteristic);
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
            error:(NSError *)error {
    NSLog(@"Characteristic: %@ Error: %@", characteristic, error);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    WSMLog(self.currentTransmission.length == 0, @"Transmission Starting.");
    // And check if it's the right one
    if ([characteristic.UUID.UUIDString isEqual:self.syncCharacteristic.UUID.UUIDString]) {
        NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value
                                                         encoding:NSUTF8StringEncoding];
        
        // Have we got everything we need?
        if ([stringFromData isEqualToString:eomSignal]) {
            // We have, so show the data,
            NSError *err;
            NSMutableDictionary *dictionary =  [CBLJSON JSONObjectWithData:self.currentTransmission
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&err];
            if (err) {
                NSLog(@"Error: %@", err);
                [self cancelConnection:peripheral completionBlock:nil];
            } else {
                CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:localUsersDB error:nil];
                CBLDocument *document = [database existingDocumentWithID:dictionary[@"_id"]];
                if (document) {
                    self.nearbyDeviceProperties[peripheral.identifier.UUIDString] = document.properties;
                    NSLog(@"Nearyby Device Properties: %@", self.nearbyDeviceProperties);
                    [self.nearbyDevicePropertiesSignal sendNext:self.nearbyDeviceProperties];
                } else {
                    //This is incomplete and could be troublesome later on.
                    NSLog(@"Start asking for info since we are not synced!");
                    [peripheral setNotifyValue:YES forCharacteristic:self.userPropertiesCharacteristic];
                }
            }
            self.currentTransmission = NSMutableData.new;
        } else {
            NSLog(@"Appending data.");
            // Otherwise, just add the data on to what we already have
            [self.currentTransmission appendData:characteristic.value];
        }

    } else if ([characteristic.UUID.UUIDString isEqual:self.userPropertiesCharacteristic.UUID.UUIDString]) {
        NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value
                                                         encoding:NSUTF8StringEncoding];
        
        // Have we got everything we need?
        if ([stringFromData isEqualToString:eomSignal]) {
            // We have, so show the data,
            NSError *err;
            NSMutableDictionary *dictionary =  [CBLJSON JSONObjectWithData:self.currentTransmission
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&err];
            if (err) {
                NSLog(@"Error: %@", err);
                [self cancelConnection:peripheral completionBlock:nil];
            } else {
                self.nearbyDeviceProperties[peripheral.identifier.UUIDString] = dictionary;
                NSLog(@"Nearyby DeviceProperties; %@", self.nearbyDeviceProperties);
                [self.nearbyDevicePropertiesSignal sendNext:self.nearbyDeviceProperties];
            }
            self.currentTransmission = NSMutableData.new;
        } else {
            NSLog(@"Appending data.");
            // Otherwise, just add the data on to what we already have
            [self.currentTransmission appendData:characteristic.value];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    NSLog(@"This service left: %@", invalidatedServices);
}

#pragma mark - WSMCapabilityProvider

+ (WSMCapabilityState)capabilityStateFromCentralManager:(CBCentralManager *)central {
    NSLog(@"Central State: %@", central);
    WSMCapabilityState state;
    switch (central.state) {
        case CBCentralManagerStatePoweredOn: {
            state = kWSMCapabilityStateOn;
        } break;
        case CBCentralManagerStatePoweredOff: {
            state = kWSMCapabilityStateSettings;
        } break;
        default: {
            state = kWSMCapabilityStateUnknown;
        } break;
    }
    return state;
}

- (WSMCapabilityState)capabilityState {
    return [WSMScanner capabilityStateFromCentralManager: self.centralManager];
}

+ (NSString *)capabilityDescription {
    return @"Look for other people around you!";
}

- (void)subscribeToUser:(RACSubject *)subject {
    self.userSubscription = [subject subscribeNext:^(WSMUser *user) {
        self.currentUser = user;
        [self startScan];
    }];
}

- (void)setUserSubscription:(RACDisposable *)userSubscription {
    if (_userSubscription) {
        [_userSubscription dispose];
    }
    _userSubscription = userSubscription;
}

+ (BOOL)requireAuthentication {
    return NO;
}

- (RACSignal *)capabilitySignal {
    return (RACSignal *) self.capabilitySubject;
}

- (void)start {
    NSLog(@"Start Scan.");
    [self startScan];
}

- (void)stop {
    for (CBPeripheral *peripheral in [self.stagedDevices arrayByAddingObjectsFromArray: self.connectedDevices].objectEnumerator) {
        [self cancelConnection:peripheral completionBlock:nil];
    }
    [self.centralManager stopScan];
}

@end
