//
//  GuideTaxonXML.m
//  iNaturalist
//
//  Created by Ken-ichi Ueda on 10/3/13.
//  Copyright (c) 2013 iNaturalist. All rights reserved.
//

#import "GuideTaxonXML.h"
#import "GuideImageXML.h"

@implementation GuideTaxonXML
@synthesize guide = _guide;
@synthesize xml = _xml;
@synthesize guidePhotos = _guidePhotos;
@synthesize name = _name;
@synthesize displayName = _displayName;

- (id)initWithGuide:(GuideXML *)guide andXML:(RXMLElement *)xml
{
    self = [super init];
    if (self) {
        self.xml = xml;
        self.guide = guide;
    }
    return self;
}

- (NSArray *)guidePhotos
{
    if (!_guidePhotos) {
        NSMutableArray *guidePhotos = [[NSMutableArray alloc] init];
        [self.xml iterateWithXPath:@"descendant::GuidePhoto|descendant::GuideRange" usingBlock:^(RXMLElement *element) {
            GuideImageXML *gp = [[GuideImageXML alloc] initWithGuideTaxon:self andXML:element];
            [guidePhotos addObject:gp];
        }];
        _guidePhotos = [NSArray arrayWithArray:guidePhotos];
    }
    return _guidePhotos;
}

- (NSString *)localImagePathForSize:(NSString *)size
{
    RXMLElement *href = [self.xml atXPath:[NSString stringWithFormat:@"descendant::GuidePhoto/href[@type='local' and @size='%@']", size]];
    if (href) {
        NSString *imgPath = [self.guide.dirPath stringByAppendingPathComponent:href.text];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
            return imgPath;
        }
    }
    return nil;
}

- (NSString *)remoteImageURLForSize:(NSString *)size
{
    return [self.xml atXPath:[NSString stringWithFormat:@"descendant::GuidePhoto/href[@type='remote' and @size='%@']", size]].text;
}

- (NSString *)name
{
    if (!_name) {
        _name = [[self.xml atXPath:@"descendant::name"] text];
    }
    return _name;
}

- (NSString *)displayName
{
    if (!_displayName) {
        _displayName = [[self.xml atXPath:@"descendant::displayName"] text];
    }
    return _displayName;
}
@end
