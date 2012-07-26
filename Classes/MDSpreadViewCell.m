//
//  MDSpreadViewCell.m
//  MDSpreadViewDemo
//
//  Created by Dimitri Bouniol on 10/15/11.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software, associated artwork, and documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//  2. Neither the name of Mochi Development, Inc. nor the names of its
//     contributors or products may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  
//  Mochi Dev, and the Mochi Development logo are copyright Mochi Development, Inc.
//  
//  Also, it'd be super awesome if you credited this page in your about screen :)
//  

#import "MDSpreadViewCell.h"
#import "MDSpreadView.h"

@interface MDSpreadViewCell ()

@property (nonatomic, readwrite, copy) NSString *reuseIdentifier;
@property (nonatomic, readwrite, assign) MDSpreadView *spreadView;
@property (nonatomic, retain) MDSortDescriptor *sortDescriptorPrototype;
@property (nonatomic) MDSpreadViewSortAxis defaultSortAxis;

@property (nonatomic, readonly) UILongPressGestureRecognizer *_tapGesture;
@property (nonatomic, retain) MDIndexPath *_rowPath;
@property (nonatomic, retain) MDIndexPath *_columnPath;

@end

@interface MDSpreadView ()

- (BOOL)_touchesBeganInCell:(MDSpreadViewCell *)cell;
- (void)_touchesEndedInCell:(MDSpreadViewCell *)cell;
- (void)_touchesCancelledInCell:(MDSpreadViewCell *)cell;

@end

@implementation MDSpreadViewCell

@synthesize backgroundView, highlighted, highlightedBackgroundView, reuseIdentifier, textLabel, detailTextLabel, style, objectValue, _tapGesture, spreadView, sortDescriptorPrototype, defaultSortAxis, _rowPath, _columnPath;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:@"_MDDefaultCell"];
}

- (id)initWithStyle:(MDSpreadViewCellStyle)aStyle reuseIdentifier:(NSString *)aReuseIdentifier
{
    if (!aReuseIdentifier) return nil;
    if (self = [super initWithFrame:CGRectZero]) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.reuseIdentifier = aReuseIdentifier;
//        self.layer.shouldRasterize = YES;
//        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        style = aStyle;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewCell.png"]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.contentStretch = CGRectMake(2./imageView.frame.size.width, 2./imageView.frame.size.height, 1./imageView.frame.size.width, 1./imageView.frame.size.height);
        self.backgroundView = imageView;
        [imageView release];
        
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MDSpreadViewCellSelected.png"]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.contentStretch = CGRectMake(2./imageView.frame.size.width, 2./imageView.frame.size.height, 1./imageView.frame.size.width, 1./imageView.frame.size.height);
        self.highlightedBackgroundView = imageView;
        [imageView release];
        
        UILabel *label = [[UILabel alloc] init];
		label.opaque = YES;
		label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:18];
		label.highlightedTextColor = [UIColor blackColor];
        self.textLabel = label;
        [label release];
        
        label = [[UILabel alloc] init];
		label.opaque = YES;
		label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:18];
		label.highlightedTextColor = [UIColor blackColor];
        self.detailTextLabel = label;
        [label release];
        
//        _tapGesture = [[UILongPressGestureRecognizer alloc] init];
//        _tapGesture.cancelsTouchesInView = NO;
//        _tapGesture.delaysTouchesEnded = NO;
//        _tapGesture.delegate = self;
//        _tapGesture.minimumPressDuration = 0;
//        [self addGestureRecognizer:_tapGesture];
//        [_tapGesture release];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _shouldCancelTouches = ![spreadView _touchesBeganInCell:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_shouldCancelTouches)
        [spreadView _touchesEndedInCell:self];
    
    _shouldCancelTouches = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_shouldCancelTouches)
        [spreadView _touchesCancelledInCell:self];
    
    _shouldCancelTouches = NO;
}

- (void)setBackgroundView:(UIView *)aBackgroundView
{
    [backgroundView removeFromSuperview];
    [aBackgroundView retain];
    [backgroundView release];
    backgroundView = aBackgroundView;
    
    [self insertSubview:backgroundView atIndex:0];
    [self setNeedsLayout];
}

- (void)setHighlightedBackgroundView:(UIView *)aHighlightedBackgroundView
{
    [highlightedBackgroundView removeFromSuperview];
    [aHighlightedBackgroundView retain];
    [highlightedBackgroundView release];
    highlightedBackgroundView = aHighlightedBackgroundView;
    
    if (highlighted) {
        highlightedBackgroundView.alpha = 1;
    } else {
        highlightedBackgroundView.alpha = 0;
    }
    [self insertSubview:highlightedBackgroundView aboveSubview:self.backgroundView];
    [self setNeedsLayout];
}

- (void)setTextLabel:(UILabel *)aTextLabel
{
    [textLabel removeFromSuperview];
    [aTextLabel retain];
    [textLabel release];
    textLabel = aTextLabel;
    
    textLabel.highlighted = highlighted;
    [self addSubview:textLabel];
    [self setNeedsLayout];
}

- (void)setDetailTextLabel:(UILabel *)aTextLabel
{
    [detailTextLabel removeFromSuperview];
    [aTextLabel retain];
    [detailTextLabel release];
    detailTextLabel = aTextLabel;
    
    detailTextLabel.highlighted = highlighted;
    [self addSubview:detailTextLabel];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    backgroundView.frame = self.bounds;
    highlightedBackgroundView.frame = self.bounds;
    textLabel.frame = CGRectMake(10, 2, self.bounds.size.width-20, self.bounds.size.height-3);
}

- (void)setHighlighted:(BOOL)isHighlighted
{
    [self setHighlighted:isHighlighted animated:NO];
}

- (void)prepareForReuse
{
    self.highlighted = NO;
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)setHighlighted:(BOOL)isHighlighted animated:(BOOL)animated
{
    highlighted = isHighlighted;
    
    textLabel.opaque = !isHighlighted;
    detailTextLabel.opaque = !isHighlighted;
    if (highlighted) {
        textLabel.backgroundColor = [UIColor clearColor];
        detailTextLabel.backgroundColor = [UIColor clearColor];
    } else {
        textLabel.backgroundColor = [UIColor whiteColor];
        detailTextLabel.backgroundColor = [UIColor whiteColor];
    }
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            if (highlighted) {
                highlightedBackgroundView.alpha = 1;
            } else {
                highlightedBackgroundView.alpha = 0;
            }
            textLabel.highlighted = highlighted;
            detailTextLabel.highlighted = highlighted;
        }];
    } else {
        if (highlighted) {
            highlightedBackgroundView.alpha = 1;
        } else {
            highlightedBackgroundView.alpha = 0;
        }
        textLabel.highlighted = highlighted;
        detailTextLabel.highlighted = highlighted;
    }
}

- (id)objectValue
{
    return self.textLabel.text;
}

- (void)setObjectValue:(id)anObject
{
    [anObject retain];
    [objectValue release];
    objectValue = anObject;
    
    if ([objectValue respondsToSelector:@selector(description)]) {
        self.textLabel.text = [objectValue description];
    }
}

- (void)dealloc
{
    [sortDescriptorPrototype release];
    [spreadView release];
    [objectValue release];
    [backgroundView release];
	[_rowPath release];
    [_columnPath release];
    [highlightedBackgroundView release];
    [textLabel release];
    [reuseIdentifier release];
    [super dealloc];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    if (detailTextLabel.text) {
        return [NSString stringWithFormat:@"%@, %@", self.detailTextLabel.text, self.textLabel.text];
    }
    
    return textLabel.text;
}

- (NSString *)accessibilityHint
{
    return @"Double tap to show more information.";
}

- (UIAccessibilityTraits)accessibilityTraits
{
    if (self.highlighted) {
        return UIAccessibilityTraitSelected;
    }
    return UIAccessibilityTraitNone;
}

@end
