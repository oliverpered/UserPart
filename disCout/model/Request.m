//
//  Request.m
//  disCout
//
//  Created by Theodor Hedin on 9/25/16.
//  Copyright © 2016 THedin. All rights reserved.
//
#import "AppDelegate.h"
#import "Request.h"
FIRDatabaseReference *ref;
@implementation Request

//Firebase
+ (FIRDatabaseReference*)dataref{
    return [[FIRDatabase database] reference];
}
+ (FIRStorageReference*)storageref{
    return [[FIRStorage storage] referenceForURL:@"gs://discout-a93e0.appspot.com"];
}
+ (FIRUser*)currentUser{
    return [FIRAuth auth].currentUser;
}
+ (NSString*)currentUserUid{
    return [FIRAuth auth].currentUser.uid;
}
+ (void)saveUserEmail:email{
    FIRDatabaseReference* ref = [[[[[[FIRDatabase database] reference] child:@"users"] child:[self currentUserUid]]child:@"general info" ] child:@"email"] ;
    [ref setValue:(NSString*)email];
    //[[[[[self dataref] child:@"users"] child:[self currentUserUid] ] child:@"email"] setValue:(NSString*)email];
}
+ (void)saveUserName:name{
    [[[[[[[FIRDatabase database] reference] child:@"users"] child:[self currentUserUid]]child:@"general info" ] child:@"name"] setValue:(NSString*)name];
}
//+ (void)getUserName{
//    [[[[[self dataref] child:@"users"] child:[self currentUserUid] ] child:@"name"] ];
//}
+ (NSError*)saveCardInfo:number cvid:cvid date:date membership:membership{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [[[[[[self dataref] child:@"users"] child:[self currentUserUid] ]child:@"general info" ] child:@"card cvid"] setValue:cvid withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        app.Acterror = error;
    }];
    [[[[[[self dataref] child:@"users"] child:[self currentUserUid] ]child:@"general info" ] child:@"card number"] setValue:number withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        app.Acterror = error;
    }];
    [[[[[[self dataref] child:@"users"] child:[self currentUserUid] ]child:@"general info" ] child:@"card date"] setValue:date withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        app.Acterror = error;
    }];
    [[[[[[self dataref] child:@"users"] child:[self currentUserUid] ]child:@"general info" ] child:@"membership"] setValue:membership withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        app.Acterror = error;
    }];
    [[[[[[self dataref] child:@"users"] child:[self currentUserUid] ]child:@"general info" ] child:@"iscancelled"] setValue:@"true" withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
    return app.Acterror;
}
+ (void)cancelMembership{
    [[[[[[self dataref] child:@"users"] child:[self currentUserUid] ]child:@"general info" ] child:@"iscancelled"] setValue:@"false" withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
}
+ (void)saveRestaurantData:dicRestaurantData{
    
    FIRDatabaseReference *allRestaurants = [[self dataref] child:@"restaurants"];
    NSString *restaurantID = [(NSDictionary*)dicRestaurantData objectForKey:@"name"];
    NSDictionary *registerData = [NSDictionary dictionaryWithObjectsAndKeys:restaurantID,dicRestaurantData, nil];
    [allRestaurants setValue:registerData];
}
+ (void)saveUserPhoto:image{
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage reference];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    FIRStorageReference *photoImagesRef = [storageRef child:[NSString stringWithFormat:@"users photo/%@/photo.jpg", [Request currentUserUid]] ];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    //image compress until size < 1 MB
    int count = 0;
    while ([imageData length] > 1000000) {
        imageData = UIImageJPEGRepresentation(image, powf(0.9, count));
        count++;
        NSLog(@"just shrunk it once.");
    }
    
    // Upload the file to the path "images/userID.PNG"
    [photoImagesRef putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            app.user.photoURL = metadata.downloadURL;
            FIRDatabaseReference* savedResData = [[[[[[FIRDatabase database] reference]child:@"users"] child:[Request currentUserUid]]child:@"general info"]child:@"photoURL"];
            [savedResData setValue:[app.user.photoURL absoluteString]];
            
        }
    }];
    

    
}

//Yelp
+ (void)retrieveAllRestaurantsData{
    AppDelegate *app = [[UIApplication sharedApplication]delegate];
    app.arrRegisteredDictinaryRestaurantData = [[NSMutableArray alloc]init];
    FIRDatabaseReference* ref = [[Request dataref]child:@"restaurants"];
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary*dic = snapshot.value;
        NSArray *keys;
        if (![dic isKindOfClass:[NSNull class]]) {
            keys = dic.allKeys;
        }
        
        for (int count = 0;keys.count>count;count++) {
            NSDictionary *restaurantData = [dic objectForKey:[keys objectAtIndex:count]];
            [app.arrRegisteredDictinaryRestaurantData addObject:restaurantData];
        }
    }];
}

@end

