/*
 * This file is part of the RMTopBarController project.
 *
 * (c) Robert Mogos
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */


#import <UIKit/UIKit.h>
#import "RMTopBar.h"

@protocol RMTopBarDelegate;
@protocol RMTopBarControllerDelegate;
@class RMTopBar;

typedef enum{
  RMTopBarPositionTop,
  RMTopBarPositionBottom
}RMTopBarPosition;

@interface RMTopBarController : UIViewController<RMTopBarDelegate>{

@protected
  RMTopBar *topBar_;
  UIView *containerView_;
  NSArray *viewControllers_;
  
  __weak UIViewController *currentController_; //this has a __weak__ reference! do not release it
  NSInteger selectedIndex_;
  id <RMTopBarControllerDelegate> delegate_;
  RMTopBarPosition topBarPosition;
}

- (id)initWithControllers:(NSArray *)controllers;
- (void)selectControllerAtIndex:(NSUInteger)index programmatically:(BOOL) program;

@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, assign) id <RMTopBarControllerDelegate> delegate;
@property(nonatomic, copy) NSString * topBarXIB;
@property(nonatomic, readonly) RMTopBar *topBar;
@property(nonatomic, assign) RMTopBarPosition topBarPosition;
@end

@protocol RMTopBarControllerDelegate <NSObject>
@optional
- (void) rmTopBarController:(RMTopBarController *)topBarController 
        didSelectController:(UIViewController *)controller 
                    atIndex:(NSUInteger) index;

- (BOOL) rmTopBarController:(RMTopBarController *)topBarController
 shouldSelectViewController:(NSUInteger) index;

@end

@interface UIViewController (RMTopBarControllerItem)

@property(nonatomic,readonly,retain) RMTopBarController *topBarController; // If the view controller has a top bar controller as its ancestor, return it. Returns nil otherwise.

@property(nonatomic,readonly,retain) RMTopBarController *bottomBarController; // If the view controller has a bottom bar controller as its ancestor, return it. Returns nil otherwise.


@end
