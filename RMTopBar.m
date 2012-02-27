/*
 * This file is part of the RMTopBarController project.
 *
 * (c) Robert Mogos
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */


#import "RMTopBar.h"

@interface RMTopBar (PrivateMethods)
- (void) setupItems;
- (void)setSelectedItemAtIndex:(NSUInteger)index 
              programmatically:(BOOL) program;
@end

@implementation RMTopBar
@synthesize delegate = delegate_;
@synthesize selectedItemIndex = selectedItemIndex_;

+ (id) topBarWithXIB:(NSString *)xibName{
  
  
  NSArray * views = [[NSBundle mainBundle] loadNibNamed:xibName 
                                                  owner:self 
                                                options:nil];
  RMTopBar *bar = nil;
  
  for (id view in views) {
    if ([view isKindOfClass:[RMTopBar class]]) {
      bar = [view retain];
      [bar setupItems];
    }
  }
  return bar;
}

+ (id) defaultTopBar{
  return [RMTopBar topBarWithXIB:@"RMTopBarView"];
}

#pragma mark Items setup
- (void) setupItems{
  selectedItemIndex_ = -1;
}

#pragma mark Items selection

- (void)setSelectedItemAtIndex:(NSUInteger)index programmatically:(BOOL) program{
  if (selectedItemIndex_ == index) {
    if (program) return;
    
    if ([delegate_ respondsToSelector:@selector(rmTopBar:didSelectItemAtIndex:)]) {
      [delegate_ rmTopBar:self didSelectItemAtIndex:index];
    }
  }
  
  UIButton *btn = nil;
  
  if (selectedItemIndex_ >= 0) {
    btn = [barItems_ objectAtIndex:selectedItemIndex_];
    [btn setSelected:NO];  
  }
  
  selectedItemIndex_ = index;
  btn = [barItems_ objectAtIndex:selectedItemIndex_];
  [btn setSelected:YES];
  
  if (program) return;
  
  if ([delegate_ respondsToSelector:@selector(rmTopBar:didSelectItemAtIndex:)]) {
    [delegate_ rmTopBar:self didSelectItemAtIndex:index];
  }
}

- (void)setSelectedItemIndex:(NSInteger) index{
  [self setSelectedItemAtIndex:index programmatically:YES];
}

- (IBAction)didSelectItem:(id)sender {
  if ([delegate_ respondsToSelector:@selector(rmTopBar:shouldSelectItemAtIndex:)]) {
    BOOL select = [delegate_ rmTopBar:self shouldSelectItemAtIndex:[barItems_ indexOfObject:sender]];
    if (!select) {
      return;
    }
  }
  
  [self setSelectedItemAtIndex:[barItems_ indexOfObject:sender] programmatically:NO];
}

- (void) setTitle:(NSString *)text forItemAtIndex:(NSUInteger) index{
  UIButton *btn = [barItems_ objectAtIndex:index];
  [btn setTitle:text forState:UIControlStateNormal];
  [btn setTitle:text forState:UIControlStateHighlighted];
  [btn setTitle:text forState:UIControlStateSelected];
}


- (void)dealloc {
  [barItems_ release];
  [super dealloc];
}
@end
