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
@property (weak, nonatomic) IBOutlet UILabel *overlay;
@property (strong, nonatomic) Bluetooth *bluetooth;
@end

@implementation KartViewController

- (Bluetooth *)bluetooth
{
    if (!_bluetooth) _bluetooth = [[Bluetooth alloc] init];
    return _bluetooth;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLayoutConstraint *stopButtonConstrain = [NSLayoutConstraint constraintWithItem:self.stopButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:0
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:.5
                                                                  constant:0];
    NSLayoutConstraint *goButtonConstrain = [NSLayoutConstraint constraintWithItem:self.stopButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:0
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:.5
                                                                  constant:0];
    [self.view addConstraint:stopButtonConstrain];
    [self.view addConstraint:goButtonConstrain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
