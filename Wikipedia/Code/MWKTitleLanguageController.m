#import "MWKTitleLanguageController.h"
@import WMF;
#import "MWKLanguageLinkFetcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWKTitleLanguageController ()

@property (copy, nonatomic, readwrite) NSURL *articleURL;
@property (strong, nonatomic, readwrite) MWKLanguageLinkController *languageController;
@property (strong, nonatomic) MWKLanguageLinkFetcher *fetcher;
@property (copy, nonatomic) NSArray *availableLanguages;
@property (readwrite, copy, nonatomic) NSArray *allLanguages;
@property (readwrite, copy, nonatomic) NSArray *preferredLanguages;
@property (readwrite, copy, nonatomic) NSArray *otherLanguages;

@end

@implementation MWKTitleLanguageController

- (instancetype)initWithArticleURL:(NSURL *)url languageController:(MWKLanguageLinkController *)controller {
    self = [super init];
    if (self) {
        self.articleURL = url;
        self.languageController = controller;
    }
    return self;
}

- (MWKLanguageLinkFetcher *)fetcher {
    if (!_fetcher) {
        _fetcher = [[MWKLanguageLinkFetcher alloc] initWithManager:[[QueuesSingleton sharedInstance] languageLinksFetcher]
                                                          delegate:nil];
    }
    return _fetcher;
}

- (void)fetchLanguagesWithSuccess:(dispatch_block_t)success
                          failure:(void (^__nullable)(NSError *__nonnull))failure {
    [[QueuesSingleton sharedInstance].languageLinksFetcher wmf_cancelAllTasksWithCompletionHandler:^{
        [self.fetcher fetchLanguageLinksForArticleURL:self.articleURL
                                              success:^(NSArray *languageLinks) {
                                                  self.availableLanguages = languageLinks;
                                                  if (success) {
                                                      success();
                                                  }
                                              }
                                              failure:failure];
    }];
}

- (void)setAvailableLanguages:(NSArray *)availableLanguages {
    _availableLanguages = availableLanguages;
    [self updateLanguageArrays];
}

- (void)updateLanguageArrays {
    self.otherLanguages = [[self.languageController.otherLanguages wmf_select:^BOOL(MWKLanguageLink *language) {
        return [self languageIsAvailable:language];
    }] wmf_map:^id(MWKLanguageLink *language) {
        return [self titleLanguageForLanguage:language];
    }];

    self.preferredLanguages = [[self.languageController.preferredLanguages wmf_select:^BOOL(MWKLanguageLink *language) {
        return [self languageIsAvailable:language];
    }] wmf_map:^id(MWKLanguageLink *language) {
        return [self titleLanguageForLanguage:language];
    }];

    self.allLanguages = [[self.languageController.allLanguages wmf_select:^BOOL(MWKLanguageLink *language) {
        return [self languageIsAvailable:language];
    }] wmf_map:^id(MWKLanguageLink *language) {
        return [self titleLanguageForLanguage:language];
    }];
}

- (nullable MWKLanguageLink *)titleLanguageForLanguage:(MWKLanguageLink *)language {
    return [self.availableLanguages wmf_match:^BOOL(MWKLanguageLink *availableLanguage) {
        return [language.languageCode isEqualToString:availableLanguage.languageCode];
    }];
}

- (BOOL)languageIsAvailable:(MWKLanguageLink *)language {
    return [self titleLanguageForLanguage:language] != nil;
}

@end

NS_ASSUME_NONNULL_END
