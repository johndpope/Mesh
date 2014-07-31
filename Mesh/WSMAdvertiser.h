//
//  WSMAdvertiser.h
//  Mesh
//
//  Created by Cristian Monterroza on 7/26/14.
//  Copyright (c) 2014 daheins. All rights reserved.
//

@interface WSMAdvertiser : NSObject <CBPeripheralManagerDelegate>

+ (instancetype)sharedInstance;

#pragma mark - Service Variables

@property (nonatomic, strong) CBMutableService *service;
@property (nonatomic, strong) CBMutableCharacteristic *userPropertiesCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *syncCharacteristic; //Not implemented yet.

@end
