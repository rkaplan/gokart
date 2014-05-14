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

enum {
    GO = 0x1,
    STOP = 0x2,
    STEER = 0x3
};

@end

@implementation Bluetooth

NSString *const kBluetoothConnectionChanged = @"kBluetoothConnectionChanged";
static const int BLUETOOTH_FIND_TIMEOUT = 2;
static const NSTimeInterval CHECK_CM_STATE_INTERVAL = 0.1;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self bleSetup];
    }
    
    return self;
}

- (void)notify
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothConnectionChanged object:self];
}

- (void)bleSetup
{
    _ble = [[BLE alloc] init];
    [_ble controlSetup];
    _ble.delegate = self;
    
    [NSTimer scheduledTimerWithTimeInterval:CHECK_CM_STATE_INTERVAL target:self selector:@selector(connectIfInitialized:) userInfo:nil repeats:YES];
}

- (void)connectIfInitialized:(NSTimer *)timer
{
    if (self.ble.CM.state == CBCentralManagerStatePoweredOn) {
        [timer invalidate];
        [self tryToConnect];
    }
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
    [self tryToConnect];
}

- (void)sendSteeringValue:(double)steer
{
    int value = steer * 512 + 512;
    if (value < 0) value = 0;
    if (value > 1023) value = 1023;
    UInt8 buf[3] = {STEER, value >> 8, value};
    [self sendThreeBytesIfConnected:buf];
}

- (void)sendGo
{
    UInt8 buf[3] = {GO, 0, 0};
    [self sendThreeBytesIfConnected:buf];
}

- (void)sendStop
{
    UInt8 buf[3] = {STOP, 0, 0};
    [self sendThreeBytesIfConnected:buf];
}

- (void)sendThreeBytesIfConnected:(UInt8[3]) buf
{
    if (self.isConnected) {
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [self.ble write:data];
    }
}

- (void)tryToConnect
{
    if (!self.isConnected) {
        [self.ble findBLEPeripherals:BLUETOOTH_FIND_TIMEOUT];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, BLUETOOTH_FIND_TIMEOUT * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if ([self.ble.peripherals count]) {
                NSLog(@"Found device");
                self.didFailToConnect = NO;
                [self.ble connectPeripheral:self.ble.peripherals[0]];
            } else {
                NSLog(@"Failed to connect");
                self.didFailToConnect = YES;
                [self notify];
            }
        });
    }
}

- (void)disconnect
{
//    TODO
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    
}

-(void) bleDidReceiveData:(unsigned char *) data length:(int) length
{
    
}

@end
