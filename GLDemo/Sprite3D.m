//
//  Sprite3D.m
//  GLDemo
//
//  Created by XY Feng on 6/8/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import "Sprite3D.h"
#import "GLProgram.h"

typedef struct {
    Vertex3D geometryVertex;
    Color    colorVertex;
} RectVertex;

typedef struct {
    RectVertex bl;
    RectVertex br;
    RectVertex tl;
    RectVertex tr;    
} RectQuad;

@interface Sprite3D()
{
    GLuint      positionAttribute;
    GLuint      colorAttribute;
    GLuint      matrixUniform;
    
    Matrix3D    rotationMatrix;
    Matrix3D    translationMatrix;
    Matrix3D    modelViewMatrix;
    Matrix3D    projectionMatrix;
    Matrix3D    matrix;
}
@property(nonatomic, assign) GLProgram *program;
@property(nonatomic, assign) RectQuad quad;
@end

@implementation Sprite3D
@synthesize program = _program;
@synthesize color = _color;
@synthesize quad = _quad;
@synthesize position = _position;
@synthesize contentSize = _contentSize;
@synthesize angle = _angle;

static GLProgram *GL3DProgram = nil;

- (id)initWithContentSize:(CGSize)contentSize Alignment:(SpriteAlignment)alignment
{
    self = [super init];
    if (self)
    {
        if(!GL3DProgram)
        {
            GL3DProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"VShader3D" fragmentShaderFilename:@"FShader3D"];
            [GL3DProgram addAttribute:@"position"];
            [GL3DProgram addAttribute:@"color"];
            [GL3DProgram addAttribute:@"textureCoordinates"];
            
            if (![GL3DProgram link])
            {
                NSLog(@"Link failed");
                
                NSString *progLog = [GL3DProgram programLog];
                NSLog(@"Program Log: %@", progLog); 
                
                NSString *fragLog = [GL3DProgram fragmentShaderLog];
                NSLog(@"Frag Log: %@", fragLog);
                
                NSString *vertLog = [GL3DProgram vertexShaderLog];
                NSLog(@"Vert Log: %@", vertLog);
                
                GL3DProgram = nil;
            }
        }
        self.program = GL3DProgram;
        
        positionAttribute = [self.program attributeIndex:@"position"];
        colorAttribute = [self.program attributeIndex:@"color"];
        matrixUniform = [self.program uniformIndex:@"matrix"];
        
        self.contentSize = contentSize;
        
        RectQuad newQuad;
        
        if (alignment == SPRITE_ALIGN_LEFT) {
            newQuad.bl.geometryVertex = Vertex3DMake(0.f, -self.contentSize.height/2/1024, 0.f);
            newQuad.br.geometryVertex = Vertex3DMake(self.contentSize.width/1024, -self.contentSize.height/2/1024, 0.f);
            newQuad.tl.geometryVertex = Vertex3DMake(0.f, self.contentSize.height/2/1024, 0.f);
            newQuad.tr.geometryVertex = Vertex3DMake(self.contentSize.width/1024, self.contentSize.height/2/1024, 0.f);
        }
        else if (alignment == SPRITE_ALIGN_RIGHT) {
            newQuad.bl.geometryVertex = Vertex3DMake(-self.contentSize.width/1024, -self.contentSize.height/2/1024, 0.f);
            newQuad.br.geometryVertex = Vertex3DMake(0.f, -self.contentSize.height/2/1024, 0.f);
            newQuad.tl.geometryVertex = Vertex3DMake(-self.contentSize.width/1024, self.contentSize.height/2/1024, 0.f);
            newQuad.tr.geometryVertex = Vertex3DMake(0.f, self.contentSize.height/2/1024, 0.f);
        }
        else {
            newQuad.bl.geometryVertex = Vertex3DMake(-self.contentSize.width/2/1024, -self.contentSize.height/2/1024, 0.f);
            newQuad.br.geometryVertex = Vertex3DMake(self.contentSize.width/2/1024, -self.contentSize.height/2/1024, 0.f);
            newQuad.tl.geometryVertex = Vertex3DMake(-self.contentSize.width/2/1024, self.contentSize.height/2/1024, 0.f);
            newQuad.tr.geometryVertex = Vertex3DMake(self.contentSize.width/2/1024, self.contentSize.height/2/1024, 0.f);
        }
        
        Color newColor = ColorMake(1.f, 1.f, 1.f, 1.f);
        newQuad.bl.colorVertex = newColor;
        newQuad.br.colorVertex = newColor;
        newQuad.tl.colorVertex = newColor;
        newQuad.tr.colorVertex = newColor;
        
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
    
    glEnable(GL_DEPTH_TEST);
    
    RectQuad newQuad = _quad;
    newQuad.bl.colorVertex = self.color;
    newQuad.br.colorVertex = self.color;
    newQuad.tl.colorVertex = self.color;
    newQuad.tr.colorVertex = self.color;
    _quad = newQuad;
    
    long offset = (long)&_quad;
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(RectVertex), (void *) (offset + offsetof(RectVertex, geometryVertex)));
    glEnableVertexAttribArray(positionAttribute);
    
    glVertexAttribPointer(colorAttribute, 4, GL_FLOAT, GL_FALSE, sizeof(RectVertex), (void *) (offset + offsetof(RectVertex, colorVertex)));
    glEnableVertexAttribArray(colorAttribute);
    
    static const Vertex3D rotationVector = {0.f, 1.f, 0.f};
    Matrix3DSetRotationByDegrees(rotationMatrix, self.angle, rotationVector);
    Matrix3DSetTranslation(translationMatrix, self.position.x, self.position.y, self.position.z);
    Matrix3DMultiply(translationMatrix, rotationMatrix, modelViewMatrix);
    Matrix3DSetPerspectiveProjectionWithFieldOfView(projectionMatrix, 45.f, 0.1f, 100.f, 1024.f/768.f);
    Matrix3DMultiply(projectionMatrix, modelViewMatrix, matrix);
    glUniformMatrix4fv(matrixUniform, 1, FALSE, matrix);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)dealloc
{
    [GL3DProgram release];
    self.program = nil;
    [super dealloc];
}

@end
