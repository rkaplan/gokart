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

- (void)sendSteeringValue:(int)value;

@end
