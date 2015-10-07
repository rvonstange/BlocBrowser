//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Robert von Stange on 10/5/15.
//  Copyright (c) 2015 Robert von Stange. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UIButton *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;


@end

@implementation AwesomeFloatingToolbar

-(instancetype) initWithFourTitles:(NSArray *)titles withColors:(NSArray *) colors{
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        if (colors == nil) {
            self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                            [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                            [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                            [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        }
        else {
            self.colors = colors;
        }

        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            UIButton *label = [[UIButton alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            label.titleLabel.font = [UIFont systemFontOfSize:10];
            [label setTitle:titleForThisLabel forState:UIControlStateNormal];
            label.backgroundColor = colorForThisLabel;
            label.tintColor = [UIColor whiteColor];
            [label addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
        for (UIButton *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
    }
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self addGestureRecognizer:self.panGesture];
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
    [self addGestureRecognizer:self.pinchGesture];
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
    self.longPressGesture.numberOfTapsRequired = 0;
    self.longPressGesture.numberOfTouchesRequired = 1;
    self.longPressGesture.minimumPressDuration = .5;
    self.longPressGesture.allowableMovement = 0;
    [self addGestureRecognizer:self.longPressGesture];
    
    
    
    return self;
}



- (void) tappedButton: (UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:button.titleLabel.text];
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [recognizer scale];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchLabels:)]) {
            [self.delegate floatingToolbar:self didPinchLabels:scale];
        }
        
        recognizer.scale = 1.0;
    }
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    //if (recognizer.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:longTouchOccurred:)]) {
            [self.delegate floatingToolbar:self longTouchOccurred:[recognizer minimumPressDuration]];
        }
    //}
    
    /*
    arrary of colors
    offset 1
    loop
     
    */
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark - Touch Handling

- (UIButton *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UIButton *)subview;
    } else {
        return nil;
    }
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton*label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}
@end
