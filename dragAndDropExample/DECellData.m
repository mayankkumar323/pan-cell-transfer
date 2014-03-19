//
//  DECellData.m
//  dragAndDropExample
//
//  Created by Mayank Home on 3/18/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import "DECellData.h"
#import "UIImage+imageCreator.h"

@implementation DECellData
- (id) initWithString:(NSString*)cellName {
    if (self = [super init]) {
        _cellName = cellName;
        _cellImageView = [[UIImageView alloc] initWithImage:[UIImage imageOfSize:CGSizeMake(200, 200) withString:_cellName]];
    }
    return self;
}
@end
