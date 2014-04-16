//
//  NSString+MorseCode.h
//  MorseTorch
//
//  Created by Daniel Fairbanks on 4/15/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MorseCode)

+(NSMutableArray *)morseSymbolsForString:(NSString *)morseString;

+(NSString *)letterForSymbol:(NSString *)morseLetter;

@end
