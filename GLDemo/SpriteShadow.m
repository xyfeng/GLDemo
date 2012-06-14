//
//  SpriteShadow.m
//  GLDemo
//
//  Created by XY Feng on 6/13/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import "SpriteShadow.h"
#import "GLProgram.h"

typedef struct {
    Vertex3D geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;    
} TexturedQuad;

@interface SpriteShadow ()
{
    GLuint      positionAttribute;
    GLuint      textureCoordinateAttribute;
    GLuint      matrixUniform;
    GLuint      textureUniform;
    GLuint      blurSizeUniform;
    GLuint      directionUniform;
    
    Matrix3D    projectionMatrix;
}
@property(nonatomic, retain) GLProgram *program;
@property(nonatomic, assign) TexturedQuad quad;
@end

@implementation SpriteShadow
@synthesize program = _program;
@synthesize quad = _quad;
@synthesize texture = _texture;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.program = [[[GLProgram alloc] initWithVertexShaderFilename:@"VShaderBlur" fragmentShaderFilename:@"FShaderBlur"] autorelease];
        [self.program addAttribute:@"position"];
        [self.program addAttribute:@"textureCoordinates"];
        
        if (![self.program link])
        {
            NSLog(@"Link failed");
            
            NSString *progLog = [self.program programLog];
            NSLog(@"Program Log: %@", progLog); 
            
            NSString *fragLog = [self.program fragmentShaderLog];
            NSLog(@"Frag Log: %@", fragLog);
            
            NSString *vertLog = [self.program vertexShaderLog];
            NSLog(@"Vert Log: %@", vertLog);
            
            self.program = nil;
        }
        
        positionAttribute = [self.program attributeIndex:@"position"];
        textureCoordinateAttribute = [self.program attributeIndex:@"textureCoordinates"];
        matrixUniform = [self.program uniformIndex:@"matrix"];
        textureUniform = [self.program uniformIndex:@"texture"];
        blurSizeUniform = [self.program uniformIndex:@"blurSize"];
        directionUniform = [self.program uniformIndex:@"direction"];
        
        TexturedQuad newQuad;
        newQuad.bl.geometryVertex = Vertex3DMake(0.f, 0.f, 0.f);
        newQuad.br.geometryVertex = Vertex3DMake(1024.f, 0.f, 0.f);
        newQuad.tl.geometryVertex = Vertex3DMake(0.f, 768.f, 0.f);
        newQuad.tr.geometryVertex = Vertex3DMake(1024.f, 768.f, 0.f);
        
        newQuad.bl.textureVertex = CGPointMake(0, 0);
        newQuad.br.textureVertex = CGPointMake(1, 0);
        newQuad.tl.textureVertex = CGPointMake(0, 1);
        newQuad.tr.textureVertex = CGPointMake(1, 1);
        self.quad = newQuad;
    }
    return self;
}

- (void)blurVertical
{
    glUniform1i(directionUniform, 1);
    glUniform1f(blurSizeUniform, 1.0/768.0);
    
    glActiveTexture (GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture);
    glUniform1i (textureUniform, 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)blurHorizontal
{
    glUniform1i(directionUniform, 0);
    glUniform1f(blurSizeUniform, 1.0/1024.0);
    
    glActiveTexture (GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture);
    glUniform1i (textureUniform, 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)draw
{
    [self.program use];
    
    long offset = (long)&_quad;
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glEnableVertexAttribArray(positionAttribute);
    
    glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    glEnableVertexAttribArray(textureCoordinateAttribute);
    
    Matrix3DSetOrthoProjection(projectionMatrix, 0.f, 1024.f, 0.f, 768.f, -1024.f, 1024.f);
    glUniformMatrix4fv(matrixUniform, 1, FALSE, projectionMatrix);
    
    [self blurVertical];
    [self blurHorizontal];
    
    glDisableVertexAttribArray(positionAttribute);
    glDisableVertexAttribArray(textureCoordinateAttribute);
}

- (void)dealloc
{
    self.program = nil;
    [super dealloc];
}

@end
