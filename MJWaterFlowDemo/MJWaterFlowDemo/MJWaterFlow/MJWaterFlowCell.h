//
//  MJWaterFlowCell.h
//  瀑布流
//
//  Created by 王梦杰 on 16/1/12.
//  Copyright (c) 2016年 Mooney_wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJWaterFlowCell : UIView

@property(nonatomic, copy)NSString *identifier;

- (instancetype)initWithReuseIdentifier:(NSString *)identifier;

@end
