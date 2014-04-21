//
//  CameraController.h
//  MorseTorch
//
//  Created by Daniel Fairbanks on 4/17/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CameraControllerDelegate <NSObject>

@end

@interface CameraController : NSObject

@property (nonatomic, unsafe_unretained) id<CameraControllerDelegate> delegate;

-(BOOL)startCapture;
-(BOOL)stopCapture;
-(void)updateBrightnessThreshold:(int)pValue;
-(void)initCapture;

@end
