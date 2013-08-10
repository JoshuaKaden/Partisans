//
//  SplashViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 8/8/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "SplashViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "SystemMessage.h"


@interface SplashViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, assign) CGImageRef drawnImage;
@property (nonatomic, assign) BOOL isScrambled;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *tiles;
@property (nonatomic, strong) NSArray *scrambledTiles;

- (void)buildLayer;
- (void)scramble;
- (void)unscramble;
//- (CAAnimation *)animationForX:(NSInteger)x Y:(NSInteger)y;
- (void)timerFired:(id)sender;
- (void)assembleTiles:(CALayer *)layer;
- (void)scrambleTiles;
- (CGPoint)destinationForPoint:(CGPoint)point;
- (void)moveLayer:(CALayer *)layer to:(CGPoint)point;


@end


//static CGFloat kMaxWidth = 725.0f;
//static CGFloat kMaxHeight = 725.0f;
static CGFloat kXSlices = 10.0f;
static CGFloat kYSlices = 10.0f;


@implementation SplashViewController

@synthesize imageView = m_imageView;
@synthesize image = m_image;
@synthesize imageLayer = m_imageLayer;
@synthesize drawnImage = m_drawnImage;
@synthesize isScrambled = m_isScrambled;
@synthesize timer = m_timer;
@synthesize tiles = m_tiles;
@synthesize scrambledTiles = m_scrambledTiles;


- (void)dealloc
{
    self.imageView.image = nil;
    [self.timer invalidate];
    
    [m_imageView release];
    [m_image release];
    [m_imageLayer release];
    [m_timer release];
    [m_tiles release];
    [m_scrambledTiles release];
    
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
    
    self.title = NSLocalizedString(@"Partisans", @"Partisans  --  title");
    
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


- (void)timerFired:(id)sender
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
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.fromValue = [layer valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:point];
    animation.duration = 0.75f;
    layer.position = point;
    [layer addAnimation:animation forKey:@"position"];
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


@end
