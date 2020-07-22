//  群组数据库model

#import <Foundation/Foundation.h>

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
#define PrimaryKey  @"primary key"

#define primaryId   @"pk"

@interface RJFMDBModel : NSObject
/** 主键 */
@property (nonatomic, assign) int pk;
/** 列名 */
@property (retain, readonly, nonatomic) NSMutableArray         *columeNames;
/** 列类型 */
@property (retain, readonly, nonatomic) NSMutableArray         *columeTypes;

/** 创建表
 *  @return 是否创建成功 */
+ (BOOL)createTableWithTableName:(NSString *)tableName;
/** @return 模型中所有的属性，并且添加主键pk。存入一个字典 */
+ (NSDictionary *)getAllProperties;
/** @return 模型中所有的属性以及属性类型。存入一个字典 */
+ (NSDictionary *)getPropertys;
/** @return 数据库中，表的所有字段名称 */
+ (NSArray *)getColumnsFromTable:(NSString *)tableName;
/** 数据库中是否存在表 */
+ (BOOL)isExistInTable:(NSString *)tableName;

/** 保存当前对象 */
- (BOOL)saveTable:(NSString *)tableName;
/** 应用事务批量保存用户对象 */
+ (BOOL)saveWithTable:(NSString *)tableName objects:(NSArray *)array;

/** 通过条件删除数据 */
+ (BOOL)deleteObjectsWithTable:(NSString *)tableName byCriteria:(NSString *)criteria;
/** 清空表 */
+ (BOOL)clearTable:(NSString *)tableName;
+ (BOOL)deleteTable:(NSString *)tableName;


/** 条件更新数据(这里的条件暂时以主键为条件，因为创建模型对象时，会给主键主动赋一个值) */
- (BOOL)updataWithTable:(NSString *)tableName;
/** 根据某个字段更新数据（一定要注意，该字段的值在表中是唯一的） */
- (BOOL)updataWithTable:(NSString *)tableName  byPropertyName:(NSString *)propertyName;
/** 批量更新用户对象*/
/*批量更新数据的关键是什么？关键就是数组中的模型对象怎么与数据库的数据对应起来？靠主键*/
+ (BOOL)updateWithTable:(NSString *)tableName objects:(NSArray *)array;

/** 查找某条数据 */
+ (instancetype)findFirstWithTable:(NSString *)tableName byCriteria:(NSString *)criteria;
/** 查询最后一条数据 */
+ (instancetype)findLastWithTableName:(NSString *)tableName;
/** 查询count条数据 */
+ (NSArray *)findLastAllWithTableName:(NSString *)tableName count:(NSInteger)count;
/** 查询所有数据 */
+ (NSArray *)findAllWithTableName:(NSString *)tableName;/** 查询所有数据 */
/** 通过条件查找数据 */
+ (NSArray *)findWithTable:(NSString *)tableName byCriteria:(NSString *)criteria;

// 获取某个字段值最大的元素
+ (NSArray *)findMaxPKWithTableName:(NSString *)tableName;
@end
