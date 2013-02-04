//
//  DLogMacro.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-04-10.
//  Copyright (c) 2010 Rudi Strahl. All rights reserved.
//

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(fmt, ...) 
#endif