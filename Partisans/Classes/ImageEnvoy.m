//
//  ImageEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 4/25/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "ImageEnvoy.h"
#import "Image.h"
#import "JSKDataMiner.h"

@implementation ImageEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize importedObjectString = m_importedObjectString;

@synthesize dateSaved = m_dateSaved;
@synthesize image = m_image;
@synthesize imageDate = m_imageDate;
@synthesize imageLatitude = m_imageLatitude;
@synthesize imageLongitude = m_imageLongitude;
@synthesize imageSource = m_imageSource;

 
- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_importedObjectString release];
    
    [m_dateSaved release];
    [m_image release];
    [m_imageDate release];
    
    [super dealloc];
}


- (id)initWithManagedObject:(Image *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID = managedObject.intramuralID;
        
        self.dateSaved = managedObject.dateSaved;
        self.image = [UIImage imageWithData:managedObject.imageData];
        self.imageDate = managedObject.imageDate;
        self.imageLatitude = [managedObject.imageLatitude doubleValue];
        self.imageLongitude = [managedObject.imageLongitude doubleValue];
        self.imageSource = (UIImagePickerControllerSourceType)[managedObject.imageSource integerValue];
        
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
//            self.isNative = YES;
        }
    }
    
    return self;
}


+ (ImageEnvoy *)envoyFromManagedObject:(Image *)managedObject
{
    ImageEnvoy *envoy = [[[ImageEnvoy alloc] initWithManagedObject:managedObject] autorelease];
    return envoy;
}



- (NSString *)description
{
    NSString *importedObjectString = self.importedObjectString;
    if (!importedObjectString)
    {
        importedObjectString = @"";
    }
    
    NSString *intramuralIDString = self.intramuralID;
    if (!intramuralIDString)
    {
        intramuralIDString = @"";
    }
    
    NSString *managedObjectString = self.managedObjectID.debugDescription;
    if (!managedObjectString)
    {
        managedObjectString = @"";
    }
    
    NSString *dateSavedString = [self.dateSaved description];
    if (!dateSavedString)
    {
        dateSavedString = @"";
    }
    
    NSString *imageDateString = [self.imageDate description];
    if (!imageDateString)
    {
        imageDateString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"ImageEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              importedObjectString, @"importedObjectString",
                              managedObjectString, @"managedObjectID",
                              dateSavedString, @"dateSaved",
                              imageDateString, @"imageDate",
                              [NSNumber numberWithDouble:self.imageLatitude].description, @"imageLatitude",
                              [NSNumber numberWithDouble:self.imageLongitude].description, @"imageLongitude",
                              [NSNumber numberWithInteger:self.imageSource].description, @"imageSource", nil];
    return descDict.description;
}



#pragma mark - Commits

- (void)commit
{
    [self commitInContext:nil];
}


- (void)commitInContext:(NSManagedObjectContext *)context
{
    if (!context)
    {
        context = [JSKDataMiner sharedInstance].mainObjectContext;
    }
    
    Image *model = nil;
    if (self.managedObjectID)
    {
        model = (Image *)[context objectWithID:self.managedObjectID];
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    }
    
    model.intramuralID = self.intramuralID;

    model.dateSaved = self.dateSaved;
    model.imageData = UIImageJPEGRepresentation(self.image, 1.0f);
    model.imageDate = self.imageDate;
    model.imageLatitude = [NSNumber numberWithDouble:self.imageLatitude];
    model.imageLongitude = [NSNumber numberWithDouble:self.imageLongitude];
    model.imageSource = [NSNumber numberWithInteger:self.imageSource];
    
    
    // Make sure the envoy knows the new managed object ID, if this is an add.
    if (!self.managedObjectID)
    {
        NSError *error = nil;
        [context obtainPermanentIDsForObjects:[NSArray arrayWithObject:model] error:&error];
        if (!error)
        {
            self.managedObjectID = model.objectID;
        }
    }
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // This is the outbound Managed Object ID to String tango.
    if (self.managedObjectID)
    {
        NSString *objectIDString = [[self.managedObjectID URIRepresentation] absoluteString];
        [aCoder encodeObject:objectIDString forKey:@"managedObjectID"];
    }
    
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    
    [aCoder encodeObject:self.dateSaved forKey:@"dateSaved"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.imageDate forKey:@"imageDate"];
    [aCoder encodeDouble:self.imageLatitude forKey:@"imageLatitude"];
    [aCoder encodeDouble:self.imageLongitude forKey:@"imageLongitude"];
    [aCoder encodeInteger:self.imageSource forKey:@"imageSource"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        // This is the inbound String to Managed Object ID tango.
        NSString *objectIDString = [aDecoder decodeObjectForKey:@"managedObjectID"];
        if (objectIDString)
        {
            self.managedObjectID = [JSKDataMiner localObjectIDForImported:objectIDString];
            if (!self.managedObjectID)
            {
                self.importedObjectString = objectIDString;
                //                debugLog(@"managedObjectID not found in local store %@", objectIDString);
            }
        }
        
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        
        self.dateSaved = [aDecoder decodeObjectForKey:@"dateSaved"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.imageDate = [aDecoder decodeObjectForKey:@"imageDate"];
        self.imageLatitude = [aDecoder decodeDoubleForKey:@"imageLatitude"];
        self.imageLongitude = [aDecoder decodeDoubleForKey:@"imageLongitude"];
        self.imageSource = [aDecoder decodeIntegerForKey:@"imageSource"];
    }
    
    return self;
}

@end
