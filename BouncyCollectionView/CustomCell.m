//
//  CustomCell.m
//  SpringCollectionView
//
//  Created by Thodoris on 03/03/14.
//  Copyright (c) 2014 72lions. All rights reserved.
//

#import "CustomCell.h"

@interface CustomCell()
@property (nonatomic, strong) UILabel *label;
@end

@implementation CustomCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.label.font = [UIFont boldSystemFontOfSize:60.f];
        self.label.textColor = [UIColor colorWithRed:243.f/255.f green:118.f/255.f blue:6.f/255.f alpha:1];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor colorWithRed:245.f/255.f green:239.f/255.f blue:213.f/255.f alpha:1.f];
        [self.contentView addSubview:self.label];
    }
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];

    self.label.text = @"";
}

- (void)setTitle:(NSString*)title
{
    self.label.text = title;
}

@end
