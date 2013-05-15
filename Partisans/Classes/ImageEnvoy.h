//
//  ImageEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 4/25/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectID;
@class Image;

@interface ImageEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;
@property (nonatomic, strong) NSString *importedObjectString;

@property (nonatomic, strong) NSDate *dateSaved;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDate *imageDate;
@property (nonatomic, assign) double imageLatitude;
@property (nonatomic, assign) double imageLongitude;
@property (nonatomic, assign) UIImagePickerControllerSourceType imageSource;


+ (ImageEnvoy *)envoyFromManagedObject:(Image *)managedObject;

- (id)initWithManagedObject:(Image *)managedObject;

- (void)commit;
- (void)commitInContext:(NSManagedObjectContext *)context;

@end
