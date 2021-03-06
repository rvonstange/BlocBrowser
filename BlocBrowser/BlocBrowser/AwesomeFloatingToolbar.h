//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Robert von Stange on 10/5/15.
//  Copyright (c) 2015 Robert von Stange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional

- (void) floatingToolbar: (AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didPinchLabels:(CGFloat)pinch;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar longTouchOccurred:(CFTimeInterval)time;


@end

@interface AwesomeFloatingToolbar : UIView

- (instancetype) initWithFourTitles:(NSArray *)titles withColors: (NSArray *)colors;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;


@end
