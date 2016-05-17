//
//  FeedDetailViewController.m
//  RSSReader
//
//  Created by Алексей on 08.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import "FeedDetailViewController.h"

@interface FeedDetailViewController ()

@property (strong,nonatomic) Feed *localFeedEntity;
@property (strong,nonatomic) UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *safariButton;
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation FeedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setImageViewFromData:self.localFeedEntity.feedImageData];
    [self setAttributedText];
}

- (void) viewWillLayoutSubviews
{
    [self.feedDescriptionTextView setContentOffset:CGPointZero animated:NO];
}

-(void) receiveFeedEntity:(Feed *)incomingFeedEntity{
    self.localFeedEntity = incomingFeedEntity;
}


#pragma mark - setting up data performance

-(void) setImageViewFromData:(NSData *)imageData{
    self.feedImageView.image = [[UIImage alloc]initWithData:imageData];
}

-(void) setAttributedText{
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n\n  %@",[self newTitleWithoutTagFromString:self.localFeedEntity.feedTitle],[self newDescriptionbyStrippingHTMLFromString:self.localFeedEntity.feedDescription]]];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Georgia-Bold" size:20 ] range:NSMakeRange(0, self.localFeedEntity.feedTitle.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Georgia" size:16 ] range:NSMakeRange([self newTitleWithoutTagFromString:self.localFeedEntity.feedTitle].length+5, [self newDescriptionbyStrippingHTMLFromString:self.localFeedEntity.feedDescription].length)];
    self.feedDescriptionTextView.attributedText = attributedString;
}

-(NSString *) newDescriptionbyStrippingHTMLFromString:(NSString *)myStr
{
    NSRange r;
    while ((r = [myStr rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        myStr = [myStr stringByReplacingCharactersInRange:r withString:@""];
    myStr = [myStr stringByReplacingOccurrencesOfString:@"Читать далее…" withString:@""];
    return myStr;
}

-(NSString *) newTitleWithoutTagFromString:(NSString *)myStr
{
    NSRange range = [myStr rangeOfString:@"&nbsp;"];
    if (range.length>0){
        NSMutableString *newString = [[NSMutableString alloc]initWithFormat:@"%@",myStr];
        [newString deleteCharactersInRange:NSMakeRange(range.location,range.length)];
        myStr = (NSString *)newString;
    }
    return myStr;
}

#pragma mark - Work With WebView

- (IBAction)openSafariButton:(id)sender {
    [self webViewWithURL:self.localFeedEntity.feedLink];
}

-(void) webViewWithURL:(NSString *)url{
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.webView.scalesPageToFit = YES;
    [self.webView setDelegate:self];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.layer.cornerRadius = 05;
    self.activityIndicator.opaque = NO;
    self.activityIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.activityIndicator setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
    [self.webView addSubview: self.activityIndicator];
}

-(void) doneWithWebView:(id)sender{
    [self.webView removeFromSuperview];
    self.webView = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.webView setFrame:self.view.bounds];
    self.activityIndicator.center = self.webView.center;
}

#pragma mark - Web View Delegate

-(void) webViewDidStartLoad:(UIWebView *)webView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
    UIBarButtonItem *closeSafariButton = [[UIBarButtonItem alloc] initWithTitle:@"Close Safari" style:UIBarButtonItemStylePlain target:self action:@selector(doneWithWebView:)];
    self.navigationItem.rightBarButtonItem = closeSafariButton;
    closeSafariButton = nil;
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
}

@end
