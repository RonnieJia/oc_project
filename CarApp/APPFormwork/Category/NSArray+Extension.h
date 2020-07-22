

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Extension)

/**
 获取类的所有属性
 */
+ (instancetype)getProperties:(Class)cls;
/**
 获取类的所有属性及其类型 @{name:type}
 */
+ (NSDictionary *)getPropertyDictionary:(Class)cls;


/*
 *将一个字符串数组按照拼音首字母规则进行重组排序, 返回重组后的数组.
 *格式和规则为:
 
 [
 @{
 @"firstLetter": @"A",
 @"content": @[@"啊", @"阿狸"]
 }
 ,
 @{
 @"firstLetter": @"B",
 @"content": @[@"部落", @"帮派"]
 }
 ,
 ...
 ]
 
 *只会出现有对应元素的字母字典, 例如: 如果没有对应 @"C"的字符串出现, 则数组内也不会出现 @"C"的字典.
 *数组内字典的顺序按照26个字母的顺序排序
 *@"#"对应的字典永远出现在数组最后一位
 */
- (NSArray *)arrayWithPinYinFirstLetterFormat;
@end

NS_ASSUME_NONNULL_END
