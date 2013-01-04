//
//  NUITests.m
//  NUITests
//
//  Created by James Brotchie on 4/01/13.
//
//

#import "NUITests.h"
#import "NUIStyleParser.h"

@implementation NUITests

- (void)testBasicParsing
{
    NSString *nss = \
       @"@primaryFontName: AppleGothic;\n"
        "@secondaryFontName: HelveticaNeue-Light;\n"
        "@secondaryFontNameBold: HelveticaNeue;\n"
        "@secondaryFontNameStrong: HelveticaNeue-Medium;\n"
        "@inputFontName: HelveticaNeue;\n"
        "@primaryFontColor: #555555;\n"
        "@secondaryFontColor: #888888;\n"
        "@primaryBackgroundColor: #E6E6E6;\n"
        "@primaryBackgroundTintColor: #ECECEC;\n"
        "@primaryBackgroundColorTop: #F3F3F3;\n"
        "@primaryBackgroundColorBottom: #E6E6E6;\n"
        "@primaryBackgroundColorBottomStrong: #DDDDDD;\n"
        "@secondaryBackgroundColorTop: #FCFCFC;\n"
        "@secondaryBackgroundColorBottom: #F9F9F9;\n"
        "@primaryBorderColor: #A2A2A2;\n"
        "@primaryBorderWidth: 1;\n"
        "\n"
        "Button {\n"
        "    background-color-top: #FFFFFF;\n"
        "    background-color-bottom: @primaryBackgroundColorBottom;\n"
        "    border-color: @primaryBorderColor;\n"
        "    border-width: @primaryBorderWidth;\n"
        "    font-color: @primaryFontColor;\n"
        "    font-color-highlighted: @secondaryFontColor;\n"
        "    font-name: @secondaryFontName;\n"
        "    font-size: 18;\n"
        "    height: 37;\n"
        "    corner-radius: 7;\n"
        "}\n";
    NUIStyleParser *parser = [[NUIStyleParser alloc] init];
    NSDictionary *styles = [parser getStylesFromString:nss];
    
    NSDictionary *declarations = styles[@"Button"];
    STAssertNotNil(declarations, @"Expect Button class to be defined.");
    
    NSDictionary *expected = @{
        @"background-color-top" : @"#FFFFFF",
        @"background-color-bottom" : @"#E6E6E6",
        @"border-color" : @"#A2A2A2",
        @"border-width" : @"1",
        @"font-color" : @"#555555",
        @"font-color-highlighted" : @"#888888",
        @"font-name" : @"HelveticaNeue-Light",
        @"font-size" : @"18",
        @"height" : @"37",
        @"corner-radius" : @"7"
    };
    
    [expected enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSString *parseValue = declarations[key];
        STAssertNotNil(parseValue, @"%@ should be parsed as a declaration.", key);
        STAssertEqualObjects(value, parseValue, @"Value for %@ declaration was '%@' should be '%@'.", key, value, parseValue);
    }];
}

- (void)testConsolidation
{
    NSString *nss = \
       @"Button { height: 32; }\n"
        "Button { height: 64; }";
    
    NUIStyleParser *parser = [[NUIStyleParser alloc] init];
    NSDictionary *styles = [parser getStylesFromString:nss];
    STAssertNotNil(styles[@"Button"], @"Expect Button class to be defined.");
    STAssertEqualObjects(styles[@"Button"][@"height"], @"64", @"Button height should be 64.");
}

@end
