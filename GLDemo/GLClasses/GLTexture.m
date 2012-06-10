//
//  OpenGLTexture3D.m
//  NeHe Lesson 06
//
//  Created by Jeff LaMarche on 12/24/08.
//  Copyright 2008 Jeff LaMarche Consulting. All rights reserved.
//

#import "GLTexture.h"

@implementation GLTexture
@synthesize filename;
@synthesize fileWidth;
@synthesize fileHeight;

- (id)initWithFilename:(NSString *)inFilename
{
	if ((self = [super init]))
	{
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
        
		self.filename = inFilename;
		glGenTextures(1, &texture[0]);
		glBindTexture(GL_TEXTURE_2D, texture[0]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.filename ofType:nil]];
        if (image == nil)
            return nil;
        
        self.fileWidth = image.size.width;
        self.fileHeight = image.size.height;
        
        GLuint width = CGImageGetWidth(image.CGImage);
        GLuint height = CGImageGetHeight(image.CGImage);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        void *imageData = malloc( height * width * 4 );
        CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
        CGContextTranslateCTM (context, 0, height);
        CGContextScaleCTM (context, 1.0, -1.0);
        CGColorSpaceRelease( colorSpace );
        CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
        CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        CGContextRelease(context);
        
        free(imageData);
        [image release];
	}
	return self;
}
+ (void)useDefaultTexture
{
	glBindTexture(GL_TEXTURE_2D, 0);
}
- (void)use
{
	glBindTexture(GL_TEXTURE_2D, texture[0]);
}
- (void)dealloc
{
	glDeleteTextures(1, &texture[0]);
	[filename release];
	[super dealloc];
}
@end
