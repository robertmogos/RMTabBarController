/*
 * This file is part of the RMTopBarController project.
 *
 * (c) Robert Mogos
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

#import "RMTopBarController.h"


@interface RMTopBarController (PrivateMethods)
- (void)setupTopBar;
- (void)setupContainerView;
- (void)positionTopBar;

@end

@interface UIViewController (RMTopBarControllerItemPrivate)
- (RMTopBarController *) topBarControllerWithPostion:(RMTopBarPosition)postion;
@end

@implementation UIViewController (RMTopBarControllerItem)

- (RMTopBarController *) topBarController{
  return [self topBarControllerWithPostion:RMTopBarPositionTop];
}

- (RMTopBarController *) bottomBarController{
  return [self topBarControllerWithPostion:RMTopBarPositionBottom];
}


- (RMTopBarController *) topBarControllerWithPostion:(RMTopBarPosition)postion{
  
  UIViewController * ancestor = self.parentViewController;
  while (ancestor) {
    if ([ancestor isKindOfClass:[RMTopBarController class]] && 
        postion == [(RMTopBarController *)ancestor topBarPosition]) 
      
      return (RMTopBarController *)ancestor;
    
    ancestor = ancestor.parentViewController;
  }
  
  return nil;
}

@end

@implementation RMTopBarController
@synthesize selectedIndex = selectedIndex_;
@synthesize delegate = delegate_;
@synthesize topBarXIB;
@synthesize topBar = topBar_;
@synthesize topBarPosition;

- (id)initWithControllers:(NSArray *)controllers{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    viewControllers_ = [controllers retain];
    selectedIndex_ = -1;
    self.topBarXIB = @"RMTopBarView";
    topBarPosition = RMTopBarPositionTop;
  }
  return self;
}

- (void)loadView{
  [super loadView];
  
  self.view.autoresizesSubviews = YES;
  self.view.autoresizingMask=UIViewAutoresizingFlexibleHeight;
  
  if (nil != self.parentViewController) {
    
    
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
      CGRect frame;
      if (![[(UINavigationController *)self.parentViewController navigationBar] isHidden]) {
        
        float height = self.parentViewController.view.frame.size.height;
        UINavigationBar *navBar = [(UINavigationController *)self.parentViewController navigationBar];
        
        height -= navBar.frame.size.height;
        height -= 20.0;
        frame = 
        (CGRect){self.parentViewController.view.frame.origin,
          {self.parentViewController.view.frame.size.width, height}};
      }
      else frame = self.parentViewController.view.frame;
      [self.view setFrame:frame];
    }
    
    
  }
  
  [self.view setBackgroundColor:[UIColor whiteColor]];
  
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
  [super viewDidLoad];
  
  [self setupTopBar];
  [self positionTopBar];
  
  /*
   it is important to call - (void)setupContainerView after - (void)setupTopBar
   in order to calculate the actual size of the container
   */
  [self setupContainerView];

  [self selectControllerAtIndex:0 programmatically:YES];
  
    
}

#pragma mark compontents init
- (void)setupTopBar{
  if (!topBar_) {
    topBar_ = [[RMTopBar topBarWithXIB:self.topBarXIB] retain];
    [topBar_ setDelegate:self];
    [topBar_ setSelectedItemIndex:selectedIndex_];
  }
  [topBar_ removeFromSuperview];
  [self.view addSubview:topBar_];
}

- (void)positionTopBar{
  CGPoint position;
  
  if (RMTopBarPositionTop == topBarPosition) {
    position = CGPointMake(0.0, 0.0);
  }else{
    position = CGPointMake(0.0, self.view.frame.size.height - topBar_.frame.size.height);
  }
  
  [topBar_ setFrame:(CGRect){position, topBar_.frame.size}];
}

- (void)setupContainerView{
  CGRect containerFrame;
  
  if (RMTopBarPositionTop == topBarPosition) {
    containerFrame = CGRectMake(0.0, 
                                topBar_.frame.size.height,
                                self.view.frame.size.width,
                                self.view.frame.size.height - topBar_.frame.size.height + 20                                     
                                );
    
  }else{
    containerFrame = CGRectMake(0.0, 
                                0.0,
                                self.view.frame.size.width,
                                self.view.frame.size.height - topBar_.frame.size.height                                     
                                );
  }
  
  if (!containerView_) {
    containerView_ = [[UIView alloc] initWithFrame:containerFrame];
  }else{
    [containerView_ removeFromSuperview];
  }
  
  [containerView_ setBackgroundColor:[UIColor clearColor]];
  
  [self.view addSubview:containerView_];
}

#pragma mark Item Selection
- (void)setSelectedIndex:(NSInteger)selectedIndex{
  [self selectControllerAtIndex:selectedIndex programmatically:YES];
}

- (void)selectControllerAtIndex:(NSUInteger)index programmatically:(BOOL) program{
  
  if (index == selectedIndex_ && RMTopBarPositionBottom == topBarPosition && !program) {
    if ([currentController_ respondsToSelector:@selector(popToRootViewControllerAnimated:)]) {
      
      [currentController_ performSelector:@selector(popToRootViewControllerAnimated:) 
                               withObject:[NSNumber numberWithBool:YES]];
      
    }else
      [currentController_.navigationController popToRootViewControllerAnimated:YES];
  }
  else{
    UIView *oldView = currentController_.view;
    selectedIndex_ = index;
    
    
    currentController_ = [viewControllers_ objectAtIndex:index];
    
    @try {
      [currentController_ setValue:self forKey:@"_parentViewController"];  
    }
    @catch (NSException *exception) {
      DLog(@"Error : The _parentViewController couldn't be set! You may have a problem");
    }
    @finally {
      
    }
    
    UIView *newView = currentController_.view;
    
    //animate or not
    [oldView removeFromSuperview];
    
    [currentController_ viewWillAppear:NO];
    [containerView_ addSubview:newView];
    
    //executed after the view is displayed
    [currentController_ performSelector:@selector(viewDidAppear:) 
                             withObject:nil 
                             afterDelay:0.0];
    
    [self.view bringSubviewToFront:topBar_];
  }
  
  if (program) {
    [topBar_ setSelectedItemIndex:index];
    return;
  }
  
  if ([delegate_ respondsToSelector:@selector(rmTopBarController:didSelectController:atIndex:)]) {
    [delegate_ rmTopBarController:self 
              didSelectController:currentController_ 
                          atIndex:selectedIndex_];
  }
}

#pragma mark RMTopBarDelegate
- (void)rmTopBar:(RMTopBar *)topBar didSelectItemAtIndex:(NSUInteger)index{
  [self selectControllerAtIndex:index programmatically:NO];
}

- (BOOL) rmTopBar:(RMTopBar *)topBar shouldSelectItemAtIndex:(NSUInteger) index{
  if ([delegate_ respondsToSelector:@selector(rmTopBarController:shouldSelectViewController:)]) {
    BOOL display = [delegate_ rmTopBarController:self shouldSelectViewController:index];
    return display;
  }
  return YES;
}

#pragma mark UIViewController forward methods 

- (void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  [currentController_ viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  [currentController_ viewDidAppear:animated];
}

- (void)viewDidUnload{
  [topBar_ release]; topBar_ = nil;
  [containerView_ release]; containerView_ = nil;
  
  [super viewDidUnload];
}

- (void)dealloc{
  [topBarXIB release];
  [viewControllers_ release];
  [containerView_ release];
  [topBar_ release];
  [super dealloc];
}
@end
