#import <UIKit/UIKit.h>

@class Sprite2D;
@class Sprite3D;

@interface GLViewController : UIViewController 
{
}
@property (nonatomic, retain) Sprite2D *bgSprite;
@property (nonatomic, retain) Sprite3D *leftPage;
@property (nonatomic, retain) Sprite3D *rightPage;
- (void)draw;
- (void)setup;
@end
