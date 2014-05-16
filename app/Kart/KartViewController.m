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
@property (weak, nonatomic) IBOutlet UIView *accelerometerIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *throttleHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *throttleContainerView;

@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (weak, nonatomic) IBOutlet UILabel *loadingBox;
@property (weak, nonatomic) IBOutlet UILabel *connectingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingSpinner;
@property (strong, nonatomic) IBOutlet UILabel *failedToConnectLabel;
@property (strong, nonatomic) IBOutlet UIButton *tryAgainButton;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) Bluetooth *bluetooth;
@end

@implementation KartViewController

static const NSTimeInterval ACCELEROMETER_UPDATE_INTERVAL = 0.1;
static const NSTimeInterval ACCELERATION_UPDATE_INTERVAL = 0.1;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches];
}

- (void)handleTouches:(NSSet *)touches
{
    if ([touches count] == 1) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self.throttleContainerView];
            CGFloat throttle = self.throttleContainerView.bounds.size.height - location.y;
            if (throttle < 0) throttle = 0;
            self.throttleHeightConstraint.constant = throttle;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stop];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stop];
}

- (void)stop
{
    self.throttleHeightConstraint.constant = 0;
}

- (void)updateAcceleration:(NSTimer *)timer
{
    double throttle = self.throttleHeightConstraint.constant / self.throttleContainerView.bounds.size.height;
    [self.bluetooth sendThrottleValue:throttle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBluetooth];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBluetoothConnectionChangedNotification:) name:kBluetoothConnectionChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self.bluetooth disconnect];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self reconnect];
}

- (void)reconnect
{
    [self setFailedToConnectViewsHidden:YES];
    [self setConnectingViewsHidden:NO];
    [self.bluetooth tryToConnect];
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
- (void)setConnectingViewsHidden:(BOOL)hidden
{
    for (UIView *view in @[self.overlay, self.loadingBox, self.connectingLabel, self.connectingSpinner]) {
        view.hidden = hidden;
    }
}

- (void)setFailedToConnectViewsHidden:(BOOL)hidden
{
    for (UIView *view in @[self.overlay, self.failedToConnectLabel, self.tryAgainButton]) {
        view.hidden = hidden;
    }
}

- (void)bluetoothDidConnect
{
    [self setConnectingViewsHidden:YES];
}

- (void)bluetoothDidFailToConnect
{
    [self setConnectingViewsHidden:YES];
    [self setFailedToConnectViewsHidden:NO];
}

- (IBAction)tryAgainButtonPressed:(UIButton *)sender {
    [self reconnect];
}

- (void)bluetoothDidDisconnect
{
    [self setConnectingViewsHidden:NO];
}

@end
