//
//  KartButton.m
//  Kart
//
//  Created by Vivek Jain on 4/26/14.
//  Copyright (c) 2014 Stanford Electric Go Kart. All rights reserved.
//

#import "KartUIButton.h"

@interface KartUIButton()
@property (strong, nonatomic) UIColor *originalBackgroundColor;
@property (nonatomic) BOOL isHighlighted;
@end

@implementation KartUIButton

static const double HIGHLIGHTED_BRIGHTNESS_MULTIPLIER = 0.75;

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (!self.isHighlighted) {
            self.isHighlighted = YES;
            self.originalBackgroundColor = self.backgroundColor;
            CGFloat h, s, b, a;
            if ([self.backgroundColor getHue:&h saturation:&s brightness:&b alpha:&a]) {
                self.backgroundColor = [UIColor colorWithHue:h
                                                  saturation:s
                                                  brightness:b * HIGHLIGHTED_BRIGHTNESS_MULTIPLIER
                                                       alpha:a];
            }
        }
    } else if (self.isHighlighted) {
        self.isHighlighted = NO;
        self.backgroundColor = self.originalBackgroundColor;
    }
}

@end
