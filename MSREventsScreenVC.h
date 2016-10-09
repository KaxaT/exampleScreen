//
//  MSREventsScreenVC.h
//  myasorubka
//
//  Created by Oles Byzhon on 24.08.16.
//  Copyright © 2016 octabrain. All rights reserved.
//

#import "MSRAbstractViewController.h"
#import "MSRCustomSlider.h"
#import "MSRBorderedButton.h"

@interface MSREventsScreenVC : MSRAbstractViewController <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    BOOL _onlyMyEvents;
    NSArray *_currentEvents;
    IBOutlet MSRCustomSlider *_slider;
    IBOutlet UICollectionView *_eventCV;
    IBOutlet MSRBorderedButton *_allEventsBtn;
    IBOutlet MSRBorderedButton *_myEventsBtn;
    IBOutlet UIView *_placeholderView;

}
-(id)initWithMyEvent:(BOOL)onlyMeEvents;
@end
