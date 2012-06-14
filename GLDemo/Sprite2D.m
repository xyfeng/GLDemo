//
//  Sprite2D.m
//  GLDemo
//
//  Created by XY Feng on 6/8/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import "Sprite2D.h"
#import "GLProgram.h"
#import "GLTexture.h"

typedef struct {
    Vertex3D geometryVertex;
    Color   colorVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;    
} TexturedQuad;

@interface Sprite2D()
{
    GLuint      positionAttribute;
    GLuint      colorAttribute;
    GLuint      textureCoordinateAttribute;
    GLuint      matrixUniform;
    GLuint      textureUniform;
    
    Matrix3D    rotationMatrix;
    Matrix3D    translationMatrix;
    Matrix3D    modelViewMatrix;
    Matrix3D    projectionMatrix;
    Matrix3D    matrix;
}
@property(nonatomic, assign) GLProgram *program;
@property(nonatomic, retain) GLTexture *texture;
@property(nonatomic, assign) TexturedQuad quad;
@end

@implementation Sprite2D

@synthesize program = _program;
@synthesize texture = _texture;
@synthesize quad = _quad;
@synthesize position = _position;
@synthesize contentSize = _contentSize;

static GLProgram *GL2DProgram = nil;

- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    if (self) 
    {
        if(!GL2DProgram)
        {
            GL2DProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"VShader2D" fragmentShaderFilename:@"FShader2D"];
            [GL2DProgram addAttribute:@"position"];
            [GL2DProgram addAttribute:@"color"];
            [GL2DProgram addAttribute:@"textureCoordinates"];
            
            if (![GL2DProgram link])
            {
                NSLog(@"Link failed");
                
                NSString *progLog = [GL2DProgram programLog];
                NSLog(@"Program Log: %@", progLog); 
                
                NSString *fragLog = [GL2DProgram fragmentShaderLog];
                NSLog(@"Frag Log: %@", fragLog);
                
                NSString *vertLog = [GL2DProgram vertexShaderLog];
                NSLog(@"Vert Log: %@", vertLog);
                
                GL2DProgram = nil;
            }
        }
        self.program = GL2DProgram;
        
        positionAttribute = [self.program attributeIndex:@"position"];
        colorAttribute = [self.program attributeIndex:@"color"];
        textureCoordinateAttribute = [self.program attributeIndex:@"textureCoordinates"];
        matrixUniform = [self.program uniformIndex:@"matrix"];
        textureUniform = [self.program uniformIndex:@"texture"];
        
        self.texture = [[[GLTexture alloc] initWithFilename:fileName] autorelease];
        
        self.contentSize = CGSizeMake(self.texture.fileWidth, self.texture.fileHeight);
        
        TexturedQuad newQuad;
        newQuad.bl.geometryVertex = Vertex3DMake(0.f, 0.f, 0.f);
        newQuad.br.geometryVertex = Vertex3DMake(self.texture.fileWidth, 0.f, 0.f);
        newQuad.tl.geometryVertex = Vertex3DMake(0, self.texture.fileHeight, 0.f);
        newQuad.tr.geometryVertex = Vertex3DMake(self.texture.fileWidth, self.texture.fileHeight, 0.f);
        
        newQuad.bl.colorVertex = ColorMake(1.f, 1.f, 1.f, 1.f);
        newQuad.br.colorVertex = ColorMake(1.f, 1.f, 1.f, 1.f);
        newQuad.tl.colorVertex = ColorMake(1.f, 1.f, 1.f, 1.f);
        newQuad.tr.colorVertex = ColorMake(1.f, 1.f, 1.f, 1.f);
        
        newQuad.bl.textureVertex = CGPointMake(0, 0);
        newQuad.br.textureVertex = CGPointMake(1, 0);
        newQuad.tl.textureVertex = CGPointMake(0, 1);
        newQuad.tr.textureVertex = CGPointMake(1, 1);
        self.quad = newQuad;
        
    }
    return self;
}

- (void)update
{
    
}

- (void)draw
{
    [self.program use];
    
    glDisable(GL_DEPTH_TEST);
    
    long offset = (long)&_quad;
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glEnableVertexAttribArray(positionAttribute);
    glVertexAttribPointer(colorAttribute, 4, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, colorVertex)));
    glEnableVertexAttribArray(colorAttribute);
    
    glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    glEnableVertexAttribArray(textureCoordinateAttribute);

    Matrix3DSetIdentity(rotationMatrix);
    Matrix3DSetIdentity(translationMatrix);
    Matrix3DSetTranslation(translationMatrix, self.position.x-self.contentSize.width/2, self.position.y-self.contentSize.height/2, self.position.z);
    Matrix3DMultiply(translationMatrix, rotationMatrix, modelViewMatrix);
    Matrix3DSetOrthoProjection(projectionMatrix, 0.f, 1024.f, 0.f, 768.f, -1024.f, 1024.f);
    Matrix3DMultiply(projectionMatrix, modelViewMatrix, matrix);
    glUniformMatrix4fv(matrixUniform, 1, FALSE, matrix);
        
    glActiveTexture (GL_TEXTURE0);
    [self.texture use];
    glUniform1i (textureUniform, 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(positionAttribute);
    glDisableVertexAttribArray(textureCoordinateAttribute);
}
    
- (void)dealloc
{
    [GL2DProgram release];
    self.program = nil;
    [super dealloc];
}

@end
