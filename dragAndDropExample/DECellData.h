//
//  DECellData.h
//  dragAndDropExample
//
//  Created by Mayank Home on 3/18/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DECellData : NSObject
@property (nonatomic, strong) NSString *cellName;
@property (nonatomic, strong) UIImageView *cellImageView;

- (id) initWithString:(NSString*)cellName;
@end
