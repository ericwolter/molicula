//
//  PurchaseViewController.m
//  molicula
//
//  Created by Eric Wolter on 2/25/15.
//  Copyright (c) 2015 Eric Wolter. All rights reserved.
//

#import "PurchaseViewController.h"
#import "Constants.h"
#import <RMAppReceipt.h>
#import <RMStoreKeychainPersistence.h>
#import "RSSecrets.h"

@implementation PurchaseViewController

+(BOOL)isEarlyAdopter
{
  BOOL result = [[RSSecrets stringForKey:@"com.ericwolter.molicula.earlyadopter"] isEqualToString:@"YES"] ||
                [[RMAppReceipt bundleReceipt].originalAppVersion hasPrefix:@"1"];
  MLog(@"%d", result);
  return result;
}

+(BOOL)isPurchased
{
  RMStoreKeychainPersistence *persistence = [RMStore defaultStore].transactionPersistor;
  BOOL result = [persistence isPurchasedProductOfIdentifier:@"com.ericwolter.molicula.solutionlibrary"];
  MLog(@"%d", result);
  return result;
}

-(IBAction)upgrade:(id)sender {
  // upgrade
  
//  if ([PurchaseViewController isEarlyAdopter]) {
//    [RSSecrets setString:@"YES" forKey:@"com.ericwolter.molicula.earlyadopter"];
//    [self unlock];
//    return;
//  }
  
  MLog(@"Purchasing...");
  [self.upgradeButton setTitle:@"Purchasing..." forState:UIControlStateNormal];
  self.upgradeButton.enabled = NO;
  self.alreadyPurchasedButton.enabled = NO;
  [[RMStore defaultStore] addPayment:@"com.ericwolter.molicula.solutionlibrary" success:^(SKPaymentTransaction *transaction) {
    NSLog(@"Purchased!");
    [self unlock];

    [self.upgradeButton setTitle:@"Upgrade" forState:UIControlStateNormal];
    self.upgradeButton.enabled = YES;
    self.alreadyPurchasedButton.enabled = YES;
  } failure:^(SKPaymentTransaction *transaction, NSError *error) {
    NSLog(@"Something went wrong");
    [self.upgradeButton setTitle:@"Upgrade" forState:UIControlStateNormal];
    self.upgradeButton.enabled = YES;
    self.alreadyPurchasedButton.enabled = YES;
  }];
  
  // if v1
  //    unlock purchase
  //    exit
  // if refresh needed
  //    refresh receipt
  //    if v1
  //        unlock purchase
  //        exit
  //    if failed
  //        show error
  //        exit
  // if item already purchased
  //    unlock purchase
  //    exit
  // execute purchase
  // unlock purchase
  // exit
}

-(IBAction)alreadyPurchased:(id)sender {
  // already purchased
  // check app store receipt bundleVersion
  // if v1
  //    unlock purchase
  //    exit
  // if refresh needed
  //    refresh receipt
  //    if v1
  //        unlock purchase
  //        exit
  //    if failed
  //        show error
  //        exit
  // if item already purchased
  //    unlock purchase
  //    exit
  MLog(@"restore");
  [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
    if([PurchaseViewController isPurchased]) {
      [self unlock];
    }
    
    [self.upgradeButton setTitle:@"Upgrade" forState:UIControlStateNormal];
    self.upgradeButton.enabled = YES;
    self.alreadyPurchasedButton.enabled = YES;
  } failure:^(NSError *error) {
    [self.upgradeButton setTitle:@"Upgrade" forState:UIControlStateNormal];
    self.upgradeButton.enabled = YES;
    self.alreadyPurchasedButton.enabled = YES;
  }];
}

-(void)unlock
{
  [self.delegate unlock];
  
  [self willMoveToParentViewController:nil];
  [self.view removeFromSuperview];
  [self removeFromParentViewController];
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  NSSet *products = [NSSet setWithArray:@[@"com.ericwolter.molicula.solutionlibrary"]];
  [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
    SKProduct *libraryProduct = [products objectAtIndex:0];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:libraryProduct.priceLocale];
    
    self.priceLabel.text = [numberFormatter stringFromNumber:libraryProduct.price];
    
    [self.upgradeButton setTitle:@"Upgrade" forState:UIControlStateNormal];
    self.upgradeButton.enabled = YES;
    self.alreadyPurchasedButton.enabled = YES;
    
  } failure:^(NSError *error) {
    [self.upgradeButton setTitle:@"No internet" forState:UIControlStateNormal];
    //MLog(@"Something went wrong");
  }];
}

@end
