//
//  KartViewController.m
//  Kart
//
//  Created by Vivek Jain on 4/22/14.
//  Copyright (c) 2014 Stanford Electric Go Kart. All rights reserved.
//

#import "KartViewController.h"
#import "Bluetooth.h"

@interface KartViewController ()
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (strong, nonatomic) IBOutlet UIView *overlay;
@property (strong, nonatomic) IBOutlet UILabel *loadingBox;
@property (strong, nonatomic) IBOutlet UILabel *connectingLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *connectingSpinner;

@property (strong, nonatomic) Bluetooth *bluetooth;
@end

@implementation KartViewController

- (void)setupBluetooth
{
    if (!self.bluetooth) self.bluetooth = [[Bluetooth alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBluetooth];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBluetoothConnectionChangedNotification:) name:kBluetoothConnectionChanged object:nil];
}

- (void)handleBluetoothConnectionChangedNotification:(NSNotification *)notification
{
    if (self.bluetooth.isConnected) {
        [self bluetoothDidConnect];
    } else  {
        if (self.bluetooth.didFailToConnect) {
            [self bluetoothDidFailToConnect];
        } else {
            [self bluetoothDidDisconnect];
        }
    }
}

// Views that are shown while bluetooth is connecting.
- (NSArray *)connectingViews
{
    return @[self.overlay, self.loadingBox, self.connectingLabel, self.connectingSpinner];
}

- (void)bluetoothDidConnect
{
    for (UIView *view in [self connectingViews]) {
        view.hidden = YES;
    }
}

- (void)bluetoothDidFailToConnect
{
}

- (void)bluetoothDidDisconnect
{
    for (UIView *view in [self connectingViews]) {
        view.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
