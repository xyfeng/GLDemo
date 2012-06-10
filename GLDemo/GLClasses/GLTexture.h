//
//  OpenGLTexture3D.h
//  NeHe Lesson 06
//
//  Created by Jeff LaMarche on 12/24/08.
//  Copyright 2008 Jeff LaMarche Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GLTexture : NSObject {
	GLuint		texture[1];  
	NSString	*filename;
}
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, assign) CGFloat  fileWidth;
@property (nonatomic, assign) CGFloat  fileHeight;
- (id)initWithFilename:(NSString *)filename;
- (void)use;
+ (void)useDefaultTexture;
@end
