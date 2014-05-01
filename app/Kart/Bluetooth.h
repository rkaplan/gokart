//
//  Bluetooth.h
//  Kart
//
//  Created by Vivek Jain on 4/22/14.
//  Copyright (c) 2014 Stanford Electric Go Kart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "BLE.h"

extern NSString *const kBluetoothConnectionChanged;

@interface Bluetooth : NSObject <BLEDelegate>

@property (nonatomic) BOOL isConnected;
@property (nonatomic) BOOL didFailToConnect;

// If not currently connected, try to connect again.
- (void)tryToConnect;
// The following functions do nothing if not connected
- (void)sendGo;
- (void)sendStop;
// Send a value between -1.0 (left) and 1.0 (right)
- (void)sendSteeringValue:(double)steer;

@end
