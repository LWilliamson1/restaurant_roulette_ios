//
//  ViewController.h
//  Restaurant Roulette
//
//  Created by Larry Williamson on 4/23/17.
//  Copyright © 2017 Larry Williamson Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;

}
@property (strong, nonatomic) IBOutlet UIButton *directionsButton;
@property (strong, nonatomic) IBOutlet UIButton *neverButton;

@property (strong, nonatomic) IBOutlet UIButton *respinButton;
@property (strong, nonatomic) IBOutlet UILabel *restaurantName;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UIImageView *restaurantImg;

- (IBAction)neverButton:(id)sender;
- (IBAction)respinButton:(id)sender;

@end

