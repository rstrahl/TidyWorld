//
//  TMInAppPurchaseHelper.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-04-09.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define TM_PRODUCTS_LOADED_NOTIFICATION         @"TMProductsLoaded"
#define TM_PRODUCT_PURCHASED_NOTIFICATION       @"TMProductPurchased"
#define TM_PRODUCT_PURCHASE_FAILED_NOTIFICATION @"TMProductPurchaseFailed"

@interface TMInAppPurchaseHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSSet               *_productIdentifiers;
    NSMutableSet        *_purchasedProducts;
    SKProductsRequest   *_productsRequest;
    NSArray             *_products;
}

@property (nonatomic, strong) NSSet             *productIdentifiers;
@property (nonatomic, strong) NSMutableSet      *purchasedProducts;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, strong) NSArray           *products;

/** Initializes the purchase helper with a set of product identifiers
 *  @param productIdentifiers an NSSet of productIdentifiers from iTunesConnect
 */
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

/** Singleton accessor
 */
+ (TMInAppPurchaseHelper *)sharedHelper;

/** Starts a request for products from iTunesConnect
 */
- (void)requestProducts;

/** Submits a buy request for a product
 *  @param productIdentifier the product identifier intended to be purchased
 */
- (void)buyProductIdentifier:(NSString *)productIdentifier;
@end
