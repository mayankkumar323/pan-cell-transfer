//
//  UIImage+imageCreator.h
//  dragAndDropExample
//
//  Created by Mayank Kumar on 3/6/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imageCreator)
+ (UIImage *) imageOfSize:(CGSize)size withString:(NSString*)text;
@end