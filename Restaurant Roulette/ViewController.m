//
//  ViewController.m
//  Restaurant Roulette
//
//  Created by Larry Williamson on 4/23/17.
//  Copyright © 2017 Larry Williamson Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
NSString *lat = @"";
NSString *lng = @"";
NSString *radius = @"4828";
NSString *API_KEY = @"AIzaSyCWZc1sX57uQI7f3Ce2TIwbt4k-KNmm8eE";

- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];  //requesting location updates
    UIImage *buttonImage = [[UIImage imageNamed:@"orangeButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    // Set the background for any states you plan to use
    [_neverButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    buttonImage = [[UIImage imageNamed:@"greenButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [_directionsButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                   resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [_respinButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)neverButton:(id)sender {
}

- (IBAction)respinButton:(id)sender {
    [self getRestaurants];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *crnLoc = [locations lastObject];
    lat = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude];
    lng = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude];
    [locationManager stopUpdatingLocation];
    locationManager = nil;
    [self getRestaurants];
}

-(void) getRestaurants{
    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/radarsearch/json?location=%@,%@&radius=%@&type=restaurant&key=%@", lat, lng, radius, API_KEY]];

    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://maps.googleapis.com/maps/api/place/radarsearch/json"];
    NSString *location = [NSString stringWithFormat:@"%@,%@", lat, lng];
    NSDictionary *queryDictionary = @{ @"location": location, @"radius": radius, @"type": @"restaurant", @"key": API_KEY  };
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in queryDictionary) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryDictionary[key]]];
    }
    components.queryItems = queryItems;
    NSURL *url = components.URL;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response,  NSError *connectionError)
                                  {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if(data.length > 0 && connectionError == nil){
                                              NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                              
                                              NSArray *results = [result objectForKey:@"results"];
                                              int index = arc4random() % [results count];
                                              //                                          NSDictionary *placeData = [results objectAtIndex:index];
                                              NSString *placeId = (NSString*)[[results objectAtIndex:index] objectForKey: @"place_id"];
                                              [self getRestaurantDetails:placeId];
                                          }
                                      });

                                  }];
    [task resume];
}

-(void) getRestaurantDetails: (NSString*)id{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&opennow&key=%@", id, API_KEY]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response,  NSError *connectionError)
                                  {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                      if(data.length > 0 && connectionError == nil){
                                          
                                          NSDictionary *result = [[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] objectForKey:@"result"];
                                          
                                          NSArray *imgArray = result[@"photos"];
                                          
                                          
                                          if(imgArray != nil || [imgArray count] != 0){
                                              
                                              NSString *photoReference = [NSString stringWithFormat:@"%@", [imgArray[0] objectForKey: @"photo_reference"]];
                                              NSString *imgUrl = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%d&maxHeight=%d&photoreference=%@&key=%@",(int)[UIScreen mainScreen].bounds.size.width, (int)[UIScreen mainScreen].bounds.size.height/3, photoReference, API_KEY];
                                              _restaurantImg.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                                          }
                                          
                                          _restaurantName.text = (NSString*)[result objectForKey: @"name"];

                                          _ratingLabel.text = [NSString stringWithFormat:@"%@", [result objectForKey: @"rating"] ?: @"N/A"];
                                          
                                          NSNumber *price_level = [result objectForKey: @"price_level"] ?: 0;
                                          int priceInt = [price_level intValue];
                                          NSString *price;
                                          if(priceInt > 0){
                                            price = [@"" stringByPaddingToLength:priceInt withString: @"$" startingAtIndex:0];
                                          } else {
                                            price = @"N/A";
                                          }
                                          _priceLabel.text = [NSString stringWithFormat:@"%@", price];
                                      }
                                      });
                                  }];
    [task resume];
}

@end
