//
//  KartViewController.m
//  Kart
//
//  Created by Vivek Jain on 4/22/14.
//  Copyright (c) 2014 Stanford Electric Go Kart. All rights reserved.
//

#import "KartViewController.h"
#import "Bluetooth.h"
#import "KartUIButton.h"

@interface KartViewController ()
@property (strong, nonatomic) IBOutlet KartUIButton *stopButton;
@property (strong, nonatomic) IBOutlet KartUIButton *goButton;
@property (weak, nonatomic) IBOutlet UIView *accelerometerIndicator;

@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (weak, nonatomic) IBOutlet UILabel *loadingBox;
@property (weak, nonatomic) IBOutlet UILabel *connectingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingSpinner;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) Bluetooth *bluetooth;
@end

@implementation KartViewController

static const NSTimeInterval ACCELEROMETER_UPDATE_INTERVAL = 0.1;
static const NSTimeInterval ACCELERATION_UPDATE_INTERVAL = 0.1;

- (CMMotionManager *)motionManager
{
    if (!_motionManager) _motionManager = [[CMMotionManager alloc] init];
    return _motionManager;
}

- (void)setupBluetooth
{
    if (!self.bluetooth) self.bluetooth = [[Bluetooth alloc] init];
    
    self.motionManager.deviceMotionUpdateInterval = ACCELEROMETER_UPDATE_INTERVAL;
    [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            double pitch = data.attitude.pitch;
            if (pitch < -1) pitch = -1;
            if (pitch > 1) pitch = 1;
            CGPoint center = self.accelerometerIndicator.center;
            center.x = self.accelerometerIndicator.superview.bounds.size.width * (pitch + 1) / 2;
            [UIView animateWithDuration:ACCELEROMETER_UPDATE_INTERVAL animations:^() {
                self.accelerometerIndicator.center = center;
            }];
            [self.bluetooth sendSteeringValue:pitch];
        });
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:ACCELERATION_UPDATE_INTERVAL target:self selector:@selector(updateAcceleration:) userInfo:nil repeats:YES];
}

- (void)updateAcceleration:(NSTimer *)timer
{
    if (self.stopButton.isTouchInside) {
        [self.bluetooth sendStop];
    } else if (self.goButton.isTouchInside) {
        [self.bluetooth sendGo];
    }
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
