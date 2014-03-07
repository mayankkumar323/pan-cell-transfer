//
//  UIImage+imageCreator.m
//  dragAndDropExample
//
//  Created by Mayank Kumar on 3/6/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

//Hack to create images on the fly

#import "UIImage+imageCreator.h"

static NSArray *colors;

@implementation UIImage (imageCreator)
+ (UIImage *) imageOfSize:(CGSize)size withString:(NSString*)text {
    if (!colors) {
        colors = @[[UIColor blueColor],
                   [UIColor yellowColor],
                   [UIColor purpleColor],
                   [UIColor brownColor],
                   [UIColor redColor],
                   [UIColor greenColor],
                   [UIColor cyanColor],
                   [UIColor magentaColor],
                   [UIColor orangeColor]];
    }
    UIView *aView = [UIView new];
    aView.frame = CGRectMake(0, 0, size.width, size.height);
    
    int rand = arc4random()%9;
    aView.backgroundColor = [colors objectAtIndex:rand];
    UILabel *aLabel = [[UILabel alloc] initWithFrame:aView.bounds];
    
    aLabel.text = text;
    aLabel.font = [UIFont systemFontOfSize:68];
    aLabel.textAlignment = NSTextAlignmentCenter;
    [aView addSubview:aLabel];
    
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size, aView.opaque, 0.0);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
@end
