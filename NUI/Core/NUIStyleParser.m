//
//  NUIStyleParser.m
//  NUIDemo
//
//  Created by Tom Benner on 12/4/12.
//  Copyright (c) 2012 Tom Benner. All rights reserved.
//

#import "NUIStyleParser.h"

#import <Parcoa/Parcoa.h>

static ParcoaParser *_styleParser;

@implementation NUIStyleParser

#pragma mark - Style Parser Definition

+ (ParcoaParser *)buildStyleParser {
    ParcoaParser *comma      = [[Parcoa unichar:','] skipSurroundingSpaces];
    ParcoaParser *colon      = [[Parcoa unichar:':'] skipSurroundingSpaces];
    ParcoaParser *semiColon  = [[Parcoa unichar:';'] skipSurroundingSpaces];
    ParcoaParser *openBrace  = [[Parcoa unichar:'{'] skipSurroundingSpaces];
    ParcoaParser *closeBrace = [[Parcoa unichar:'}'] skipSurroundingSpaces];
    
    ParcoaParser *dash     = [Parcoa unichar:'-'];
    ParcoaParser *alpha    = [Parcoa letter];
    ParcoaParser *alphaNum = [Parcoa alphaNum];
    
    // Token must start with a space but then can be followed by a dash or any
    // alphanumeric character. 
    ParcoaParser *token           = [[alpha then:[[alphaNum or: dash] concatMany]] concat];
    
    ParcoaParser *value           = [Parcoa takeUntil:[Parcoa isUnichar:';']];
    ParcoaParser *declaration     = [[token keepLeft:colon] then:[value keepLeft:semiColon]];
    ParcoaParser *declarations    = [[declaration many] dictionary];
    ParcoaParser *classExpression = [token sepBy1:comma];
    ParcoaParser *ruleSet         = [[classExpression then: [declarations between:openBrace and:closeBrace]]
                                     dictionaryWithKeys:@[@"classes", @"declarations"]];
    
    ParcoaParser *topLevelDeclaration  = [[Parcoa unichar:'@'] keepRight: declaration];
    ParcoaParser *topLevelDeclarations = [[topLevelDeclaration many] dictionary];
    
    ParcoaParser *nss = [[topLevelDeclarations then: [ruleSet many]]
                         dictionaryWithKeys:@[@"topLevelDeclarations", @"ruleSets"]];
    return nss;
}

+ (ParcoaParser *)styleParser {
    if (!_styleParser) {
        _styleParser = [NUIStyleParser buildStyleParser];
    }
    return _styleParser;
}

- (NSDictionary *)parse:(NSString *)input {
    ParcoaResult *result = [[NUIStyleParser styleParser] parse:input];
    if (result.isOK) {
        return result.value;
    } else {
        NSLog(@"Parsing failed: %@", [result traceback:input]);
        return nil;
    }
}

- (NSMutableDictionary*)getStylesFromFile:(NSString*)fileName
{
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"nss"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return [self getStylesFromString:content];
}

- (NSMutableDictionary *)getStylesFromString:(NSString *)content {
    NSDictionary *result = [self parse:content];
    if (result) {
        return [self consolidateRuleSets:result[@"ruleSets"] withTopLevelDeclarations:result[@"topLevelDeclarations"]];
    } else {
        return [NSMutableDictionary dictionary];
    }
}

#pragma mark - Consolidation

- (NSMutableDictionary*)consolidateRuleSets:(NSMutableArray*)ruleSets withTopLevelDeclarations:(NSMutableDictionary*)topLevelDeclarations
{
    NSMutableDictionary *consolidatedRuleSets = [[NSMutableDictionary alloc] init];
    for (NSMutableDictionary *ruleSet in ruleSets) {
        NSArray *classes = [ruleSet objectForKey:@"classes"];
        for (NSString *class in classes) {
            if ([consolidatedRuleSets objectForKey:class] == nil) {
                [consolidatedRuleSets setValue:[[NSMutableDictionary alloc] init] forKey:class];
            }
            [self mergeRuleSetIntoConsolidatedRuleSet:ruleSet consolidatedRuleSet:[consolidatedRuleSets objectForKey:class] topLevelDeclarations:topLevelDeclarations];
        }
    }
    return consolidatedRuleSets;
}

- (NSMutableDictionary*)mergeRuleSetIntoConsolidatedRuleSet:(NSMutableDictionary*)ruleSet consolidatedRuleSet:(NSMutableDictionary*)consolidatedRuleSet topLevelDeclarations:(NSMutableDictionary*)topLevelDeclarations
{
    NSMutableDictionary *declarations = [ruleSet objectForKey:@"declarations"];
    for (NSString *property in declarations) {
        NSString *value = [declarations objectForKey:property];
        if ([value hasPrefix:@"@"]) {
            value = [topLevelDeclarations objectForKey:[value substringFromIndex:1]];
        }
        [consolidatedRuleSet setValue:value forKey:property];
    }
    return consolidatedRuleSet;
}

@end
