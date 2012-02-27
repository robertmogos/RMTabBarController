/*
 * This file is part of the RMTopBarController project.
 *
 * (c) Robert Mogos
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */


#import <UIKit/UIKit.h>

@protocol RMTopBarDelegate;

@interface RMTopBar : UIView{
  @protected
  IBOutletCollection(UIButton) NSArray *barItems_;
  id <RMTopBarDelegate> delegate_;
  NSInteger selectedItemIndex_;
}

@property(nonatomic, assign) id <RMTopBarDelegate> delegate;
@property(nonatomic, assign) NSInteger selectedItemIndex;

/* 
 init a defaultTopBar using a RMTopBar.xib
*/

+ (id) defaultTopBar;

/* 
 init a topBar using a custom xib
*/
+ (id) topBarWithXIB:(NSString *)xibName;

- (IBAction)didSelectItem:(id)sender;
- (void) setTitle:(NSString *)text forItemAtIndex:(NSUInteger) index;

@end

@protocol RMTopBarDelegate <NSObject>

@optional
- (void) rmTopBar:(RMTopBar *)topBar didSelectItemAtIndex:(NSUInteger) index;
- (BOOL) rmTopBar:(RMTopBar *)topBar shouldSelectItemAtIndex:(NSUInteger) index;
@end
