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
@property (nonatomic) BOOL isScanning;

enum {
    THROTTLE = 0x1,
    STEER,
    DISCONNECT,
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

- (void)sendThrottleValue:(double)throttle
{
    int value = throttle * 1000 + 1000;
    if (value < 1000) value = 1000;
    if (value > 2000) value = 2000;
    UInt8 buf[3] = {THROTTLE, value >> 8, value};
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
    if (!self.isConnected && !self.isScanning) {
        self.isScanning = YES;
        [self.ble findBLEPeripherals:BLUETOOTH_FIND_TIMEOUT];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, BLUETOOTH_FIND_TIMEOUT * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.isScanning = NO;
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
    NSLog(@"Bluetooth: disconnect called");
    // It appears sometimes there is some delay in iOS actually
    // disconnecting when we call `cancelPeripheralConnection`, so send a
    // disconnect sequence that we handle in the Arduino code.
    UInt8 buf[3] = {DISCONNECT, 0, 0};
    [self sendThreeBytesIfConnected:buf];
    if (self.ble.activePeripheral) [self.ble.CM cancelPeripheralConnection:self.ble.activePeripheral];
    if (self.ble.peripherals) self.ble.peripherals = nil;
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    
}

-(void) bleDidReceiveData:(unsigned char *) data length:(int) length
{
    
}

@end
