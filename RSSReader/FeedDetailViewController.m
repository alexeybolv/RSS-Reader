//
//  FeedDetailViewController.m
//  RSSReader
//
//  Created by Алексей on 08.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import "FeedDetailViewController.h"

@interface FeedDetailViewController ()
{
    UIActivityIndicatorView *activityIndicator;
}
@property (strong,nonatomic) Feed *localFeedEntity;
@property (strong,nonatomic) UIWebView *webView;

@end

@implementation FeedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.feedImageView.image = [[UIImage alloc]initWithData:self.localFeedEntity.feedImageData];
    
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n\n\n\n  %@",[self newTitleWithoutTagFromString:self.localFeedEntity.feedTitle],[self newDescriptionbyStrippingHTMLFromString:self.localFeedEntity.feedDescription]]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, self.localFeedEntity.feedTitle.length)];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange([self newTitleWithoutTagFromString:self.localFeedEntity.feedTitle].length+7, [self newDescriptionbyStrippingHTMLFromString:self.localFeedEntity.feedDescription].length)];

    self.feedDescriptionTextView.attributedText = attributedString;
}

-(void) receiveFeedEntity:(Feed *)incomingFeedEntity{
    self.localFeedEntity = incomingFeedEntity;
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
    self.webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
    self.webView.scalesPageToFit = YES;
    [self.webView setDelegate:self];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    activityIndicator.layer.cornerRadius = 05;
    activityIndicator.opaque = NO;
    activityIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    activityIndicator.center = self.view.center;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
    [self.webView addSubview: activityIndicator];
}

-(void) doneWithWebView:(id)sender{
    [self.webView removeFromSuperview];
    self.webView = nil;
    self.navigationItem.rightBarButtonItem = nil;
}


#pragma mark - Web View Delegate

-(void) webViewDidStartLoad:(UIWebView *)webView{
    [activityIndicator startAnimating];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Close Safari" style:UIBarButtonItemStylePlain target:self action:@selector(doneWithWebView:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    anotherButton = nil;
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
//    CGSize contentSize = self.webView.scrollView.contentSize;
//    CGSize viewSize = self.webView.bounds.size;
//    
//    float rw = viewSize.width / contentSize.width;
//    
//    self.webView.scrollView.minimumZoomScale = rw;
//    self.webView.scrollView.maximumZoomScale = rw;
//    self.webView.scrollView.zoomScale = rw;
    [activityIndicator stopAnimating];
}

@end
