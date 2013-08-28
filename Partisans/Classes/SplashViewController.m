//
//  SplashViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 8/8/13.
//
//  Copyright (c) 2013, Joshua Kaden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SplashViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "SystemMessage.h"


@interface SplashViewController () 

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *closeButton;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, assign) CGImageRef drawnImage;
@property (nonatomic, assign) BOOL isScrambled;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *tiles;
@property (nonatomic, strong) NSArray *scrambledTiles;
@property (nonatomic, strong) UIView *triggerView;
@property (nonatomic, strong) UITapGestureRecognizer *triggerGesture;
@property (nonatomic, assign) BOOL shouldCycle;
@property (nonatomic, strong) CABasicAnimation *animation;

- (void)buildLayer;
- (void)toggleState;
- (void)scramble;
- (void)unscramble;
//- (CAAnimation *)animationForX:(NSInteger)x Y:(NSInteger)y;
- (void)timerFired:(id)sender;
- (void)assembleTiles:(CALayer *)layer;
- (void)scrambleTiles;
- (CGPoint)destinationForPoint:(CGPoint)point;
- (void)moveLayer:(CALayer *)layer to:(CGPoint)point;
- (void)applyTriggerView;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
- (IBAction)closeButtonPressed:(id)sender;


@end


//static CGFloat kMaxWidth = 725.0f;
//static CGFloat kMaxHeight = 725.0f;
static CGFloat kXSlices = 10.0f;
static CGFloat kYSlices = 5.0f;


@implementation SplashViewController

@synthesize imageView = m_imageView;
@synthesize image = m_image;
@synthesize imageLayer = m_imageLayer;
@synthesize drawnImage = m_drawnImage;
@synthesize isScrambled = m_isScrambled;
@synthesize timer = m_timer;
@synthesize tiles = m_tiles;
@synthesize scrambledTiles = m_scrambledTiles;
@synthesize triggerView = m_triggerView;
@synthesize triggerGesture = m_triggerGesture;
@synthesize closeButton = m_closeButton;
@synthesize shouldCycle = m_shouldCycle;
@synthesize animation = m_animation;


- (void)dealloc
{
    self.imageView.image = nil;
    [self.timer invalidate];
    [self.triggerView removeGestureRecognizer:self.triggerGesture];
    self.animation.delegate = nil;
    
    [m_imageView release];
    [m_image release];
    [m_imageLayer release];
    [m_timer release];
    [m_tiles release];
    [m_scrambledTiles release];
    [m_triggerView release];
    [m_triggerGesture release];
    [m_closeButton release];
    [m_animation release];
    
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationItem setLeftBarButtonItem:self.closeButton animated:NO];
    
//    self.title = NSLocalizedString(@"Partisans", @"Partisans  --  title");
    
    self.drawnImage = self.imageView.image.CGImage;
    
    [self buildLayer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    self.timer = timer;
    
    
//    CGFloat width = self.view.frame.size.width;
//    CGFloat height = self.view.frame.size.height;
//    CGFloat x = 0.0f;
//    CGFloat y = 0.0f;
    
//    CGFloat width = kMaxWidth;
//    CGFloat height = kMaxHeight;
//    CGFloat x = kMinX;
//    CGFloat y = kMinY;

    //    self.imageLayer = [CALayer layer];
//    self.imageLayer.frame = imageViewLayer.frame;
//    self.imageLayer.contentsGravity = kCAGravityResizeAspectFill;
//    self.imageLayer.masksToBounds = YES;
//    [self.view.layer addSublayer:self.imageLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (void)timerFired:(id)sender
{
    if (self.isScrambled)
    {
        [self.timer invalidate];
        [self toggleState];
        [self applyTriggerView];
    }
    else
    {
        [self toggleState];
    }
}

- (void)toggleState
{
    if (self.isScrambled)
    {
        [self unscramble];
        self.isScrambled = NO;
        [self.timer invalidate];
    }
    else
    {
        [self scrambleTiles];
        [self scramble];
        self.isScrambled = YES;
    }
}

- (void)buildLayer
{
    CGSize imageSize = CGSizeMake(CGImageGetWidth(self.drawnImage),
                                  CGImageGetHeight(self.drawnImage));
    
    CALayer *layer = [[CALayer alloc] init];
    layer.bounds = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    layer.position = self.imageView.center;
    
    [self assembleTiles:layer];
    
    self.imageLayer = layer;
    [layer release];
    [self.imageView.layer addSublayer:self.imageLayer];
    
    self.imageView.image = nil;
}

- (void)moveLayer:(CALayer *)layer to:(CGPoint)point
{
    if (!self.animation)
    {
        CABasicAnimation *animation = [[CABasicAnimation alloc] init];
        animation.keyPath = @"position";
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.duration = 0.75f;
        self.animation = animation;
        [animation release];
    }
    
    self.animation.fromValue = [layer valueForKey:@"position"];
    self.animation.toValue = [NSValue valueWithCGPoint:point];
    layer.position = point;
    [layer addAnimation:self.animation forKey:@"position"];
}


- (void)scramble
{
    // First collect the destination points.
    // Then perform the animation.
    
    NSMutableArray *valueList = [[NSMutableArray alloc] initWithCapacity:self.tiles.count];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (CALayer *layer in self.imageLayer.sublayers)
    {
        CGPoint point = [self destinationForPoint:layer.position];
        NSValue *value = [NSValue valueWithCGPoint:point];
        [valueList addObject:value];
    }
    [pool drain];
    
    NSInteger index = 0;
    for (CALayer *layer in self.imageLayer.sublayers)
    {
        CGPoint point = [[valueList objectAtIndex:index] CGPointValue];
        [self moveLayer:layer to:point];
        index++;
    }
    
    [valueList release];
    
//        CGPoint position = layer.position;
//        CAAnimation *animation = [self animationForX:position.x Y:position.y];
//        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:animation, @"position", nil];
//        layer.actions = dictionary;
//        [dictionary release];
//        
//        layer.opacity = 0.0f;
//    }
}

- (void)unscramble
{
    [self scramble];
}

//- (CAAnimation *)animationForX:(NSInteger)x Y:(NSInteger)y
//{
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    group.delegate = self;
//    group.duration = 2.0f;
//    
//    CABasicAnimation *opacity = [CABasicAnimation
//                                 animationWithKeyPath:@"opacity"];
//    opacity.fromValue = [NSNumber numberWithDouble:1.0f];
//    opacity.toValue = [NSNumber numberWithDouble:1.0f];
//    
//    CABasicAnimation *position = [CABasicAnimation
//                                  animationWithKeyPath:@"position"];
//    position.timingFunction = [CAMediaTimingFunction
//                               functionWithName:kCAMediaTimingFunctionEaseIn];
//    CGPoint dest = [self destinationForX:x Y:y];
////    CGPoint dest = CGPointMake(0.0f, 0.0f);  //[self randomDestinationX:x Y:y imageSize:size];
//    position.toValue = [NSValue valueWithCGPoint:dest];
//    
//    group.animations = [NSArray arrayWithObjects:opacity, position, nil];
//    return group;
//}

//- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
//{
//    NSArray *sublayers = [NSArray arrayWithArray:[self.imageLayer sublayers]];
//    for (CALayer *layer in sublayers)
//    {
//        [layer removeFromSuperlayer];
//    }
//}


- (void)assembleTiles:(CALayer *)floorLayer
{
    CGFloat width = floorLayer.frame.size.width;
    CGFloat height = floorLayer.frame.size.height;
    
    NSUInteger ceiling = kXSlices * kYSlices;
    NSMutableArray *layerList = [[NSMutableArray alloc] initWithCapacity:ceiling];
    for (int x = 0; x < kXSlices; x++)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        for (int y = 0; y < kYSlices; y++)
        {
            CGRect frame = CGRectMake((width / kXSlices) * x,
                                      (height / kYSlices) * y,
                                      width / kXSlices,
                                      height / kYSlices);
            CALayer *layer = [[CALayer alloc] init];
            layer.frame = frame;
            
            CGImageRef subimage = CGImageCreateWithImageInRect(self.drawnImage, frame);
            layer.contents = (id)subimage;
            CFRelease(subimage);
            [layerList addObject:layer];
            [layer release];
        }
        
        [pool drain];
    }
    
    NSArray *tiles = [[NSArray alloc] initWithArray:layerList];
    [layerList release];
    self.tiles = tiles;
    [tiles release];
    
    
    for (CALayer *layer in self.tiles)
    {
        [floorLayer addSublayer:layer];
//        layer.opacity = 0.0f;
    }
}

- (void)scrambleTiles
{
    NSMutableArray *scrambledList = [[NSMutableArray alloc] initWithArray:self.tiles];
    NSUInteger count = [scrambledList count];
    for (NSUInteger i = 0; i < count; i++)
    {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [scrambledList exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    NSArray *scrambledTiles = [[NSArray alloc] initWithArray:scrambledList];
    [scrambledList release];
    self.scrambledTiles = scrambledTiles;
    [scrambledTiles release];
}

- (CGPoint)destinationForPoint:(CGPoint)point
{
    CGPoint returnValue = CGPointZero;
    if (self.isScrambled)
    {
        NSInteger index = 0;
        for (CALayer *layer in self.scrambledTiles)
        {
            if (layer.position.x == point.x && layer.position.y == point.y)
            {
                CALayer *matchingLayer = [self.tiles objectAtIndex:index];
                returnValue.x = matchingLayer.position.x;
                returnValue.y = matchingLayer.position.y;
                break;
            }
            index++;
        }
    }
    else
    {
        NSInteger index = 0;
        for (CALayer *layer in self.tiles)
        {
            if (layer.position.x == point.x && layer.position.y == point.y)
            {
                CALayer *matchingLayer = [self.scrambledTiles objectAtIndex:index];
                returnValue.x = matchingLayer.position.x;
                returnValue.y = matchingLayer.position.y;
                break;
            }
            index++;
        }
    }
    return returnValue;
}


#pragma mark - Tap trigger (gesture recognizer)

- (void)applyTriggerView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.triggerGesture = tapGesture;
    [tapGesture release];
    
    UIView *view = [[UIView alloc] initWithFrame:self.imageView.frame];
    view.backgroundColor = [UIColor clearColor];
    [view setOpaque:NO];
    [self.view addSubview:view];
    [view addGestureRecognizer:tapGesture];
    
    self.triggerView = view;
    [view release];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    self.shouldCycle = !self.shouldCycle;
    [self toggleState];
}


@end
