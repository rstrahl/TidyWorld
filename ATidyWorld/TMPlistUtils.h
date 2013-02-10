//
//  RSPlist.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-02-01.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMPlistUtils : NSObject

/** Reads from a Plist */
+ (id)readPlist:(NSString *)fileName;
/** Writes a given data structure into a Plist */
+ (void)writePlist:(id)plist fileName:(NSString *)fileName;

@end
