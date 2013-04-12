//
//  TMInAppPurchaseHelper.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-04-09.
//
//

#import "TMInAppPurchaseHelper.h"

static TMInAppPurchaseHelper *_sharedHelper = nil;

@implementation TMInAppPurchaseHelper

@synthesize productIdentifiers = _productIdentifiers,
            purchasedProducts = _purchasedProducts,
            productsRequest = _productsRequest,
            products = _products;

- (id)init {
    
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 @"com.atidymind.atidyworld.removeads",
                                 nil];
    
    return [self initWithProductIdentifiers:productIdentifiers];
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        _productIdentifiers = [productIdentifiers retain];
        
        // Check for previous purchases
        NSMutableSet * purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [purchasedProducts addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            NSLog(@"Not purchased: %@", productIdentifier);
        }
        self.purchasedProducts = purchasedProducts;
        
    }
    return self;
}

#pragma mark - Singleton
+ (TMInAppPurchaseHelper *)sharedHelper
{
    static dispatch_once_t safer;
    dispatch_once(&safer, ^{
        _sharedHelper = [[TMInAppPurchaseHelper alloc] init];
        // private initialization goes here.
    });
    return _sharedHelper;
}

- (void)requestProducts
{
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark - SKProductsRequestDelegate Implementation
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Received %d products...", response.products.count);
    self.products = response.products;
    self.productsRequest = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TM_PRODUCTS_LOADED_NOTIFICATION object:_products];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"ERROR retrieving products: %@", [error description]);
}

#pragma mark - SKPaymentTransactionObserver Implementation
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    // Optional: Record the transaction on the server side...
}

- (void)provideContent:(NSString *)productIdentifier
{
    NSLog(@"Toggling flag for: %@", productIdentifier);
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_purchasedProducts addObject:productIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TM_PRODUCT_PURCHASED_NOTIFICATION
                                                        object:productIdentifier];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    [self recordTransaction:transaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TM_PRODUCT_PURCHASE_FAILED_NOTIFICATION
                                                        object:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)buyProductIdentifier:(NSString *)productIdentifier
{
    NSLog(@"Buying %@...", productIdentifier);
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

@end
