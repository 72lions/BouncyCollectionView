//
//  BouncyCollectionViewFlowLayout.m
//  SpringCollectionView
//
//  Created by Thodoris on 03/03/14.
//  Copyright (c) 2014 72lions. All rights reserved.
//

#import "BouncyCollectionViewFlowLayout.h"

@interface BouncyCollectionViewFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat latestDelta;
@property (nonatomic, assign) BOOL enabled;

@end

@implementation BouncyCollectionViewFlowLayout

-(id)init {
    if (!(self = [super init])) return nil;

    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 40;
    self.itemSize = CGSizeMake(400, 520);
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPathsSet = [NSMutableSet set];
    self.isEnabled = YES;
    return self;
}

-(void)prepareLayout {
    [super prepareLayout];
    
    CGRect visibleRect = CGRectInset((CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -1000, -1000);
    
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];

    NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        BOOL currentlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] firstObject] indexPath]] != nil;
        return !currentlyVisible;
    }]];
    
    [noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }];

    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentlyVisible = [self.visibleIndexPathsSet member:item.indexPath] != nil;
        return !currentlyVisible;
    }]];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];

        springBehaviour.length = 1.0f;
        springBehaviour.damping = 0.8f;
        springBehaviour.frequency = 2.f;

        [self updateItemInSpringBehavior:springBehaviour withTouchLocation:touchLocation];

        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (self.isEnabled) {
        UIScrollView *scrollView = self.collectionView;

        CGFloat delta = newBounds.origin.x - scrollView.bounds.origin.x;

        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            delta = newBounds.origin.y - scrollView.bounds.origin.y;
        }

        self.latestDelta = delta;
        
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        
        [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehavior, NSUInteger idx, BOOL *stop) {

            UICollectionViewLayoutAttributes *item = [self updateItemInSpringBehavior:springBehavior
                                                                    withTouchLocation:touchLocation];

            [self.dynamicAnimator updateItemUsingCurrentState:item];
                
        }];

        return NO;
    }

    return YES;
}

- (UICollectionViewLayoutAttributes*)updateItemInSpringBehavior:(UIAttachmentBehavior *)springBehaviour
                                              withTouchLocation:(CGPoint)touchLocation
{
    static const float cScrollResistanceScalar = 3500.f;

    UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];

    // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
    if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        CGPoint center = item.center;
        CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat scrollResistance = (xDistanceFromTouch) / cScrollResistanceScalar;

        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            scrollResistance = (yDistanceFromTouch) / cScrollResistanceScalar;
        }

        if (self.latestDelta < 0) {
            if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                center.x += floorf(MAX(self.latestDelta, self.latestDelta * scrollResistance));
            } else {
                center.y += floorf(MAX(self.latestDelta, self.latestDelta * scrollResistance));
            }
        } else if (self.latestDelta > 0){
            if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                center.x += floorf(MIN(self.latestDelta, self.latestDelta * scrollResistance));
            } else {
                center.y += floorf(MIN(self.latestDelta, self.latestDelta * scrollResistance));
            }
        }

        item.center = center;
    }
    return item;
}

-(BOOL)isEnabled
{
    return _enabled;
}

-(void)setIsEnabled:(BOOL)isEnabled
{
    _enabled = isEnabled;
}

@end
