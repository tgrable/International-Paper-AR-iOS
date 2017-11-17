//
//  ARMarker.h
//  InternationalPaper
//
//  Created by Timothy C Grable on 8/31/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ARMarker : NSObject

@property (strong, nonatomic) NSString *markerName;
@property (strong, nonatomic) NSNumber *sortOrder;

@end
