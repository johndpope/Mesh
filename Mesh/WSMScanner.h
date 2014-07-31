//
//  WSMScanner.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 daheins. All rights reserved.
//

#import "WSMUserManager.h"

@interface WSMScanner : NSObject <WSMCapabilityProvider, CBCentralManagerDelegate, CBPeripheralDelegate>

+ (instancetype)sharedInstance;

#pragma mark - Service Variables
@property (nonatomic, strong) CBUUID *serviceUUID;

@property (nonatomic, strong) CBMutableCharacteristic *userPropertiesCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *syncCharacteristic;

@property (nonatomic, strong) NSMutableDictionary *nearbyDeviceProperties;
@property (nonatomic, strong) RACSubject *nearbyDevicePropertiesSignal;

@end
