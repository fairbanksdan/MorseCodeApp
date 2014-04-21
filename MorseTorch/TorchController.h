//
//  TorchController.h
//  MorseTorch
//
//  Created by Daniel Fairbanks on 4/16/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TorchControllerDelegate <NSObject>

@optional
-(void)displayNewLetter:(NSString *)newLetter;
-(void)doneTransmitting;


@end

@interface TorchController : NSObject

@property (nonatomic, unsafe_unretained) id<TorchControllerDelegate> delegate;

- (void)convertMorseCode:(NSString *)morseString;

-(void)cancelSending;

@end
