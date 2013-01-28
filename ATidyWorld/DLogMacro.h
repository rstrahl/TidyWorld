//
//  DLogMacro.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);