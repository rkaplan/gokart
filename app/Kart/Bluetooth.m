//
//  Bluetooth.m
//  Kart
//
//  Created by Vivek Jain on 4/22/14.
//  Copyright (c) 2014 Stanford Electric Go Kart. All rights reserved.
//

#import "Bluetooth.h"

@interface Bluetooth()
@property (strong, nonatomic) BLE *ble;
@end

@implementation Bluetooth

NSString *const kBluetoothConnectionChanged = @"kBluetoothConnectionChanged";
static const int BLUETOOTH_FIND_TIMEOUT = 2;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self bleSetup];
    }
    
    return self;
}

- (BLE *)ble
{
    if (!_ble) {
        _ble = [[BLE alloc] init];
        [_ble controlSetup];
        _ble.delegate = self;
    }
    return _ble;
}

- (void)notify
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothConnectionChanged object:self];
}

- (void)bleSetup
{
    [self.ble findBLEPeripherals:BLUETOOTH_FIND_TIMEOUT];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, BLUETOOTH_FIND_TIMEOUT * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([self.ble.peripherals count]) {
            self.didFailToConnect = NO;
            [self.ble connectPeripheral:self.ble.peripherals[0]];
        } else {
            self.didFailToConnect = YES;
            [self notify];
        }
    });
}

- (void)bleDidConnect
{
    NSLog(@"Connected");
    self.isConnected = YES;
    [self notify];
}

- (void)bleDidDisconnect
{
    NSLog(@"Disconnected");
    self.isConnected = NO;
    [self notify];
    [self bleSetup];
}

static const int STEER_BYTE = 0x03;

- (void)sendSteeringValue:(int)value
{
    UInt8 buf[3] = {STEER_BYTE, value >> 8, value};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
}

@end
