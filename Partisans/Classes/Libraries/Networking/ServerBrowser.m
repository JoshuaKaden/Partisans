//
//  ServerBrowser.m
//  Partisans
//
//  Copyright (c) 2009 Peter Bakhyryev <peter@byteclub.com>, ByteClub LLC
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "ServerBrowser.h"


// A category on NSNetService that's used to sort NSNetService objects by their name.
@interface NSNetService (BrowserViewControllerAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService*)aService;
@end

@implementation NSNetService (BrowserViewControllerAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService*)aService {
	return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}
@end


// Private properties and methods
@interface ServerBrowser () <NSNetServiceBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *serverList;
@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, assign) BOOL isBrowsing;

// Sort services alphabetically
- (void)sortServers;

@end


@implementation ServerBrowser

@synthesize serverList = m_serverList;
@synthesize delegate = m_delegate;
@synthesize netServiceBrowser = m_netServiceBrowser;
@synthesize isBrowsing = m_isBrowsing;

// Initialize
- (id)init
{
    self = [super init];
    if (self)
    {
        NSMutableArray *servers = [[NSMutableArray alloc] init];
        self.serverList = servers;
    }
  return self;
}


// Cleanup
- (void)dealloc
{
    self.netServiceBrowser.delegate = nil;
    
    
}


// Public server list
- (NSArray *)servers
{
    return [NSArray arrayWithArray:self.serverList];
}


// Start browsing for servers
- (BOOL)start
{
    self.isBrowsing = YES;
    
    // Restarting?
    if (self.netServiceBrowser)
    {
        [self stop];
    }

    NSNetServiceBrowser *netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser = netServiceBrowser;
    if (!self.netServiceBrowser)
    {
        return NO;
    }

    self.netServiceBrowser.delegate = self;
    
    [self.netServiceBrowser searchForServicesOfType:@"_partisans._tcp." inDomain:@""];

    return YES;
}


// Terminate current service browser and clean up
- (void)stop
{
    self.isBrowsing = NO;
    
    if (!self.netServiceBrowser)
    {
        return;
    }

    [self.netServiceBrowser stop];
    [self.netServiceBrowser setDelegate:nil];
    self.netServiceBrowser = nil;

    [self.serverList removeAllObjects];
}


// Sort servers array by service names
- (void)sortServers
{
    [self.serverList sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}


#pragma mark - NSNetServiceBrowser Delegate

// New service was found
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
    // Make sure that we don't have such service already (why would this happen? not sure)
    if (![self.serverList containsObject:netService])
    {
        // Add it to our list
        [self.serverList addObject:netService];
    }

    // If more entries are coming, no need to update UI just yet
    if (moreServicesComing)
    {
        return;
    }

    // Sort alphabetically and let our delegate know
    [self sortServers];
    [self.delegate updateServerList];
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
    // Remove from list
    [self.serverList removeObject:netService];

    // If more entries are coming, no need to update UI just yet
    if (moreServicesComing)
    {
        return;
    }

    // Sort alphabetically and let our delegate know
    [self sortServers];
    [self.delegate updateServerList];
}

@end
