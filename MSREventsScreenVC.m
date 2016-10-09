//
//  MSREventsScreenVC.m
//  myasorubka
//
//  Created by Oles Byzhon on 24.08.16.
//  Copyright © 2016 octabrain. All rights reserved.
//

#import "MSREventsScreenVC.h"
#import "MSREEventsCell.h"
#import "UIImageView+AFNetworking.h"

@interface MSREventsScreenVC ()

@end

@implementation MSREventsScreenVC

-(id)initWithMyEvent:(BOOL)onlyMeEvents{
    if(self = [super initWithNibName:@"MSREventsScreenVC" bundle:nil]){
        _onlyMyEvents = onlyMeEvents;
        return self;
    }
    return nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [_eventCV registerNib:[UINib nibWithNibName:NSStringFromClass([MSREEventsCell class]) bundle:nil] forCellWithReuseIdentifier:@"eventCell"];
    [self addMenuButtons];
    [self updateEventsData];
    [self customizeSlider];
    [self updateCategoryButtons];
}

-(void)updateEventsData{
    [NETWORKING getEventsPersonal:_onlyMyEvents completion:^(NSArray *events, NSError *error) {
        if(!error){
            _currentEvents = events;
            if(_currentEvents.count<1){
                [_placeholderView setHidden:NO];
            }else{
                [_placeholderView setHidden:YES];
            }
            [_eventCV reloadData];
            [_eventCV layoutIfNeeded];
            [self updateSliderMaxValue];

        }else{
            [self showModalError:error.localizedDescription];
        }
    }];
}

- (void)updateCategoryButtons{
    [_myEventsBtn setSelected:_onlyMyEvents];
    [_allEventsBtn setSelected:!_onlyMyEvents];
}
#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _currentEvents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MSREEventsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"eventCell" forIndexPath:indexPath];
    Event *event = [_currentEvents objectAtIndex:indexPath.item];
    [cell.imgView setImageWithURL:[NSURL URLWithString:event.image]];

    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    Event *curEvent = [_currentEvents objectAtIndex:indexPath.item];
    if(![curEvent.isViewed boolValue]){
        [NETWORKING markEventAsViewed:curEvent.id withCompletion:^(BOOL success, NSError *error) {
            if(success){
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_COUNTER_UPDATE object:nil];
            }else{
                [self showModalError:error.localizedDescription];
            }
        }];
        curEvent.isViewed = [NSNumber numberWithBool:YES];
    }
}
#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_slider setValue:(int)(_eventCV.contentOffset.x/_eventCV.frame.size.width)];
}
#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.frame.size;
}
#pragma mark - UISlider
- (void)customizeSlider{
    UIImage *image = [UIImage imageNamed:@"eventSliderThumb"];
    CGSize newSize = CGSizeMake(16, 15);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [_slider setThumbImage:newImage forState:UIControlStateNormal];
    [_slider setMaximumTrackImage:[[UIImage imageNamed:@"eventSliderPath"] resizableImageWithCapInsets:UIEdgeInsetsMake(50, 50, 1000, 1000)] forState:UIControlStateNormal];
    [_slider setMinimumTrackImage:[[UIImage imageNamed:@"eventSliderPath"] resizableImageWithCapInsets:UIEdgeInsetsMake(50, 50, 1000, 1000)] forState:UIControlStateNormal];
}

- (void)updateSliderMaxValue{
    [_slider setHidden:_currentEvents.count<2];
    [_slider setMaximumValue:_currentEvents.count - 1];
    [_slider setValue:_eventCV.contentOffset.x/_eventCV.frame.size.width];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {

    [_eventCV setContentOffset:CGPointMake(_slider.value* _eventCV.frame.size.width, _eventCV.contentOffset.y)];

}
- (IBAction)sliderTouchUp:(MSRCustomSlider *)sender {
    long intValue = lround(_slider.value);
    [_slider setValue:intValue animated:YES];
    [_eventCV setContentOffset:CGPointMake(intValue * _eventCV.frame.size.width, _eventCV.contentOffset.y)];

}

#pragma mark - Actions

- (IBAction)onFilterBtn:(MSRBorderedButton *)sender {
    _onlyMyEvents = [sender isEqual:_myEventsBtn];
    [self updateCategoryButtons];
    [self updateEventsData];
}


@end
