#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NKMarkupParser : NSObject

/** @name Create an NSAttributedString */

/**
* Takes an `NSString` and returns an appropriately attributed 
* `NSAttributedString`.
*
* @param markup An `NSString` containing text marked up with `Markup`
* @param font The base font to use, from which bold and italic variants will be
* derived
* @param color The text colour to use for the resulting attributed string
*/
+ (NSAttributedString *)attributedStringFromMarkup:(NSString *)markup
                                            font:(UIFont *)font
                                           color:(UIColor *)color;

+ (NSAttributedString *)attributedStringFromMarkup:(NSString *)markdown
                                            font:(UIFont *)font
                                           color:(UIColor *)color
                                  paragraphStyle:(NSParagraphStyle *)paragraphStyle;

+ (NSAttributedString *)attributedStringFromMarkup:(NSString *)markdown
                                            font:(UIFont *)font
                                        boldFont:(UIFont *)boldFont
                                      italicFont:(UIFont *)italicFont
                                           color:(UIColor *)color
                                  paragraphStyle:(NSParagraphStyle *)paragraphStyle;

@property (nonatomic, copy) NSString *markup;
@property (nonatomic, retain) UIFont *baseFont;
@property (nonatomic, retain) UIFont *boldFont;
@property (nonatomic, retain) UIFont *italicFont;
@property (nonatomic, retain) UIColor *baseColor;
@property (nonatomic, retain) NSParagraphStyle *paragraphStyle;
- (void)parse;
- (void)strip;
- (NSAttributedString *)attributedString;

@end
