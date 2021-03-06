//
//  ImageEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 4/25/13.
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

#import "ImageEnvoy.h"

#import "Image.h"
#import "JSKDataMiner.h"
#import "SystemMessage.h"

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

 


- (id)initWithManagedObject:(Image *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID = managedObject.intramuralID;
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        }
        
        self.dateSaved = managedObject.dateSaved;
        
        
        UIImage *image = [SystemMessage cachedImage:self.intramuralID];
        if (!image)
        {
            image = [UIImage imageWithData:managedObject.imageData];
            [SystemMessage cacheImage:image key:self.intramuralID];
        }
        self.image = image;
        
        
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
    ImageEnvoy *envoy = [[ImageEnvoy alloc] initWithManagedObject:managedObject];
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
    
    if (!self.intramuralID)
    {
        self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        model.intramuralID = self.intramuralID;
    }
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
//    // This is the outbound Managed Object ID to String tango.
//    if (self.managedObjectID)
//    {
//        NSString *objectIDString = [[self.managedObjectID URIRepresentation] absoluteString];
//        [aCoder encodeObject:objectIDString forKey:@"managedObjectID"];
//    }
    
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
//        // This is the inbound String to Managed Object ID tango.
//        NSString *objectIDString = [aDecoder decodeObjectForKey:@"managedObjectID"];
//        if (objectIDString)
//        {
//            self.managedObjectID = [JSKDataMiner localObjectIDForImported:objectIDString];
//            if (!self.managedObjectID)
//            {
//                self.importedObjectString = objectIDString;
//                //                debugLog(@"managedObjectID not found in local store %@", objectIDString);
//            }
//        }
        
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
