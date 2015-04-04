//
//  PurchaseViewController.h
//  molicula
//
//  Created by Eric Wolter on 2/25/15.
//  Copyright (c) 2015 Eric Wolter. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PurchaseViewController : UIViewController

+(BOOL)isEarlyAdopter;
+(BOOL)isPurchased;

@property (nonatomic, weak) id delegate;

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIButton *upgradeButton;
@property (nonatomic, weak) IBOutlet UIButton *alreadyPurchasedButton;

-(IBAction)upgrade:(id)sender;
-(IBAction)alreadyPurchased:(id)sender;

-(void)unlock;

@end
