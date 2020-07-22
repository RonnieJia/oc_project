//  群组数据库model

#import "RJFMDBModel.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "RJFMDBDatabase.h"
#import <objc/runtime.h>

@implementation RJFMDBModel
+ (BOOL)createTableWithTableName:(NSString *)tableName {
    FMDatabase *db = [FMDatabase databaseWithPath:[RJFMDBDatabase dbPath]];
    
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    }
    
    NSString *columAndType = [self.class getColumeAndTypeString];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,columAndType];
    if (![db executeUpdate:sql]) {
        NSLog(@"创建表失败");
        return NO;
    }
    
    NSMutableArray *columns = [NSMutableArray array];
    // schem:纲要(既然是纲要就不会涉及具体的数据，只会涉及字段名，字段类型)
    // 需要传入的参数:表名,返回值:查询表后的结果集
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        // 取出结果集中的name对应的值，即字段的名称(取出所有的字段名)
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    // 拿到所有的属性(包括自己添加的主键字段)的字典
    NSDictionary *dict = [self.class getAllProperties];
    // 拿到所有的属性名
    NSArray *propertyNames = [dict objectForKey:@"name"];
    // 过滤数组的作用:检查模型中所有需要存储的属性在数据库中是否都有对应的字段，如果没有立即新增一个字段
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
    // 过滤数组
    NSArray *resultArray = [propertyNames filteredArrayUsingPredicate:filterPredicate];
    
    for (NSString *column in resultArray) {
        NSUInteger index = [propertyNames indexOfObject:column];
        NSString *propertyType = [[dict objectForKey:@"type"] objectAtIndex:index];
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column, propertyType];
        
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",tableName, fieldSql];
        if (![db executeUpdate:sql]) {
            return NO;
        }
    }
    [db close];
    return YES;
}
/** 将属性名和属性类型拼接成sqlite语句 */
+ (NSString *)getColumeAndTypeString {
    NSMutableString *parames = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    
    NSMutableArray *propertyNames = [dict objectForKey:@"name"];
    NSMutableArray *propertyTypes = [dict objectForKey:@"type"];
    
    for (int i = 0; i<propertyNames.count; i++) {
        [parames appendFormat:@"%@ %@",propertyNames[i], propertyTypes[i]];
        if (i + 1 != propertyNames.count) {
            [parames appendString:@","];
        }
    }
    return parames;
}

/** 获取模型中的所有属性，并且添加一个主键字段pk，存入字典 */
+ (NSDictionary *)getAllProperties {
    NSDictionary *dict = [self.class getPropertys];
    
    NSMutableArray *propertyNames = [NSMutableArray array];
    NSMutableArray *propertyTypes = [NSMutableArray array];
    
    [propertyNames addObject:primaryId];
    [propertyTypes addObject:[NSString stringWithFormat:@"%@ %@",SQLINTEGER, PrimaryKey]];
    [propertyNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [propertyTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:propertyNames,@"name",propertyTypes,@"type", nil];
}

/**
 *  获取该类的所有属性以及属性对应的类型，并且存入字典中
 */
+ (NSDictionary *)getPropertys {
    // 存放模型中的所有属性名、属性类型（sqlite数据类型）
    NSMutableArray *propertyNames = [NSMutableArray array];
    NSMutableArray *propertyTypes = [NSMutableArray array];
    
    NSArray *theTransients = [self.class transients];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i<outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        // 子类模型中一些不需要创建数据库字段的property，直接跳过去
        if ([theTransients containsObject:propertyName]) {
            continue;
        }
        [propertyNames addObject:propertyName];
        
        NSString *propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
         
         
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         */
        if ([propertyType hasPrefix:@"T@"]) { // 字符串
            [propertyTypes addObject:SQLTEXT];
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]) {
            [propertyTypes addObject:SQLINTEGER];
        } else {
            [propertyTypes addObject:SQLREAL];
        }
    }
    free(properties);
    return [NSDictionary dictionaryWithObjectsAndKeys:propertyNames,@"name",propertyTypes,@"type", nil];
}
#pragma mark - must be override method
/** 如果子类中有一些property不需要创建数据库字段，那么这个方法必须在子类中重写
 */
+ (NSArray *)transients {
    return [NSArray array];
}

/** @return 数据库中指定表的所有字段名 */
+ (NSArray *)getColumnsFromTable:(NSString *)tableName {
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    NSMutableArray *columns = [NSMutableArray array];
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:@"name"];
            [columns addObject:column];
        }
    }];
    return [columns copy];
}

//#pragma mark - 初始化，创建数据库，新增字段
//+ (void)initialize {
//    if (self != [RJFMDBModel self]) {
//        [self createTableWithTableName:@""];
//    }
//}

#pragma mark - 创建对象是给成员变量赋值 
- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *dict = [self.class getAllProperties];
        _columeNames = [NSMutableArray arrayWithArray:[dict objectForKey:@"name"]];
        _columeTypes = [NSMutableArray arrayWithArray:[dict objectForKey:@"type"]];
    }
    return self;
}

#pragma mark 保存数据。通过运行时拿到所有的属性->通过KVC拿到所有的属性地址存储的值，用一个数组保存->可用先前拿到的属性名与值得数组，依照sql语法拼接插入语句->执行插入操作
//关键：想要插入数据到创建好的数据库，需要字段名和值；字段名就是多有的属性名，值就是属性地址存储的值。
- (BOOL)saveTable:(NSString *)tableName {
    if (![self.class isExistInTable:tableName]){
        [self.class createTableWithTableName:tableName];
    }
    
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray array];
    for (int i = 0; i<self.columeNames.count; i++) {
        NSString *properName = [self.columeNames objectAtIndex:i];
        // 如果是主键不做处理
        if ([properName isEqualToString:primaryId]) {
            continue;
        }
        [keyString appendFormat:@"%@,",properName];
        [valueString appendString:@"?,"];
        // 通过KVC将属性的值取出
        id value = [self valueForKey:properName];
        if (!value) {  value = @""; } // 属性值可能为空
        [insertValues addObject:value];
    }
    
    // 删除最后的‘,’
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length-1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length-1, 1)];
    
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    __block BOOL res = NO;
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);",tableName,keyString,valueString];
        // 这个方法会自动到一个数组中取值
        res = [db executeUpdate:sql withArgumentsInArray:insertValues];
        
        self.pk = res ? [NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
        NSLog(@"插入%d",res);
    }];
    return res;
}

#pragma mark - 应用事务来保存数据
+ (BOOL)saveWithTable:(NSString *)tableName objects:(NSArray *)array  {
    if (!array || array.count == 0) {
        return NO;
    }
    if (![self.class isExistInTable:tableName]){
        [self.class createTableWithTableName:tableName];
    }
    
    // 判断是不是RJFMDBModel 的之类
    for (RJFMDBModel *model in array) {
        if (![model isKindOfClass:[RJFMDBModel class]]) {
            return NO;
        }
    }
    __block BOOL res = YES;
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    // 如果需要支持事务
    [rjDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (RJFMDBModel *model in array) {
            NSMutableString *keyString = [NSMutableString string];
            NSMutableString *valueString = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray  array];
            for (int i = 0; i<model.columeNames.count; i++) {
                NSString *propertyName = [model.columeNames objectAtIndex:i];
                if ([propertyName isEqualToString:primaryId]) continue;
                
                [keyString appendFormat:@"%@,",propertyName];
                [valueString appendString:@"?,"];
                id value = [model valueForKey:propertyName];
                if (!value) value = @"";
                [insertValues addObject:value];
            }
            
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length-1, 1)];
            [valueString deleteCharactersInRange:NSMakeRange(valueString.length-1, 1)];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);",tableName,keyString,valueString];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            model.pk = flag?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
            NSLog(@"插入%d",res);
            if (!flag) {
                res = NO;
                // 一旦出错回滚
                *rollback = YES;
                return ;
            }
        }
    }];
    return res;
}

#pragma mark - 删除数据。删数据需要资源：表名、条件语句 
+ (BOOL)deleteObjectsWithTable:(NSString *)tableName byCriteria:(NSString *)criteria {
//    if (![self.class isExistInTable:tableName]) return NO;
    
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    __block BOOL res = NO;
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@ ",tableName, criteria];
        res = [db executeUpdate:sql];
        NSLog(@"插入%d",res);
    }];
    return res;
}

/** 清空表 */
+ (BOOL)clearTable:(NSString *)tableName {
    if (![self.class isExistInTable:tableName]) return NO;
    
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    __block BOOL res = NO;
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        res = [db executeUpdate:sql];
        NSLog(@"清空%d",res);
    }];
    return res;
}

+ (BOOL)deleteTable:(NSString *)tableName {
    if ([self isExistInTable:tableName]) {
        RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
        __block BOOL res = NO;
        [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@",tableName];
            res = [db executeUpdate:sql];
            NSLog(@"清空%d",res);
        }];
        return res;
    }
    return YES;
}

#pragma mark - 更新数据 
- (BOOL)updataWithTable:(NSString *)tableName {
    if (![self.class isExistInTable:tableName]) return NO;
    
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    __block BOOL res = NO;
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        id primaryValue = [self valueForKey:primaryId];
        if (!primaryValue || primaryValue <= 0) return ;
        NSMutableString *keyString = [NSMutableString string];
        NSMutableArray *updataValues = [NSMutableArray array];
        for (int i = 0; i<self.columeNames.count; i++) {
            NSString *propertyName = [self.columeNames objectAtIndex:i];
            if ([propertyName isEqualToString:primaryId]) continue;
            [keyString appendFormat:@" %@=?,",propertyName];
            id value = [self valueForKey:propertyName];
            if (!value) value = @"";
            [updataValues addObject:value];
        }
        
        [keyString deleteCharactersInRange:NSMakeRange(keyString.length-1, 1)];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;",tableName,keyString,primaryId];
        [updataValues addObject:primaryValue];
        res = [db executeUpdate:sql withArgumentsInArray:updataValues];
        NSLog(@"更新%d",res);
    }];
    return res;
}

- (BOOL)updataWithTable:(NSString *)tableName  byPropertyName:(NSString *)propertyName{
    if (![self.class isExistInTable:tableName]) {
        [self.class createTableWithTableName:tableName];
    }
    
    id propertyValue = [self valueForKey:propertyName];
    if (!propertyValue) {
        return NO;
    }
    
    NSArray *findArray = [self.class findWithTable:tableName byCriteria:[NSString stringWithFormat:@" WHERE %@ = %@",propertyName, propertyValue]];
    
    if (!(findArray && findArray.count > 0)) {
        return [self saveTable:tableName];
    } else {
        RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
        __block BOOL res = NO;
        [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updataValues = [NSMutableArray array];
            for (int i = 0; i<self.columeNames.count; i++) {
                NSString *proName = [self.columeNames objectAtIndex:i];
                if ([proName isEqualToString:propertyName] || [proName isEqualToString:primaryId]) continue;
                [keyString appendFormat:@" %@=?,",proName];
                id value = [self valueForKey:proName];
                if (!value) value = @"";
                [updataValues addObject:value];
            }
            
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length-1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;",tableName,keyString,propertyName];
            [updataValues addObject:propertyValue];
            res = [db executeUpdate:sql withArgumentsInArray:updataValues];
            NSLog(@"更新%d",res);
        }];
        return res;
    }
}

+ (BOOL)updateWithTable:(NSString *)tableName objects:(NSArray *)array {
    if (![self isExistInTable:tableName]) return NO;
    
    for (RJFMDBModel *model in array) {
        if (![model isKindOfClass:[RJFMDBModel class]])  return NO;
    }
    
    __block BOOL res = YES;
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    [rjDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (RJFMDBModel *model in array) {
            //拿到表名，模型类不同，表名也不同NSStringFromClass(model.class)
            id primaryValue = [model valueForKey:primaryId];
            if (!primaryValue || primaryValue <= 0) {
                res = NO;
                *rollback = YES;
                return;
            }
            
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updateValues = [NSMutableArray  array];
            for (int i = 0; i < model.columeNames.count; i++) {
                NSString *proname = [model.columeNames objectAtIndex:i];
                if ([proname isEqualToString:primaryId]) {
                    continue;
                }
                [keyString appendFormat:@" %@=?,", proname];
                id value = [model valueForKey:proname];
                if (!value) {
                    value = @"";
                }
                [updateValues addObject:value];
            }
            
            //删除最后那个逗号
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, primaryId];
            [updateValues addObject:primaryValue];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updateValues];
            NSLog(@"更新%d",res);
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

#pragma mark - 查找数据
+ (NSArray *)findMaxPKWithTableName:(NSString *)tableName {
    if (![self isExistInTable:tableName])  return 0;
    
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    NSMutableArray *users = [NSMutableArray array];
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ order by pk desc limit 1",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            RJFMDBModel *model = [[self.class alloc] init];
            for (int i = 0; i<model.columeNames.count; i++) {
                NSString *columnName = model.columeNames[i];
                NSString *columnType = model.columeTypes[i];
                if ([columnType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columnName] forKey:columnName];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columnName]] forKey:columnName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    return users;

}

/** 查找某条数据 */
+ (instancetype)findFirstWithTable:(NSString *)tableName byCriteria:(NSString *)criteria {
    NSArray *results = [self.class findWithTable:tableName byCriteria:criteria];
    if (!results || results.count == 0) {
        return nil;
    }
    return [results firstObject];
}

/** 查询最后一条数据 */
+ (instancetype)findLastWithTableName:(NSString *)tableName {
    NSArray *results = [self.class findAllWithTableName:tableName];
    if (results.count < 1) {
        return nil;
    }
    return [results lastObject];
}

/** 通过条件查找数据 */
+ (NSArray *)findWithTable:(NSString *)tableName byCriteria:(NSString *)criteria {
    if (![self isExistInTable:tableName])  return nil;
    
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    NSMutableArray *users = [NSMutableArray array];
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT *FROM %@ %@",tableName,criteria];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            RJFMDBModel *model = [[self.class alloc] init];
            for (int i = 0; i<model.columeNames.count; i++) {
                NSString *columnName = model.columeNames[i];
                NSString *columnType = model.columeTypes[i];
                if ([columnType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columnName] forKey:columnName];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columnName]] forKey:columnName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    return users;
}
+ (NSArray *)findLastAllWithTableName:(NSString *)tableName count:(NSInteger)count {
    NSArray *array = [self findAllWithTableName:tableName];
    NSMutableArray *returnArray = [NSMutableArray array];
    [returnArray addObjectsFromArray:(array.count < count)?array:[array subarrayWithRange:NSMakeRange(array.count-count, count)]];
    return returnArray;
}

/** 查找表下的所有数据 */
+ (NSArray *)findAllWithTableName:(NSString *)tableName {
    if (![self isExistInTable:tableName]) return nil;
    
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    NSMutableArray *users = [NSMutableArray array];
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            RJFMDBModel *model = [[self.class alloc] init];
            for (int i = 0; i<model.columeNames.count; i++) {
                NSString *columnName = model.columeNames[i];
                NSString *columnType = model.columeTypes[i];
                if ([columnType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columnName] forKey:columnName];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columnName]] forKey:columnName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
        
    }];
    return users;
}

/** 数据库中是否存在表 */
+ (BOOL)isExistInTable:(NSString *)tableName {
    __block BOOL res = NO;
    RJFMDBDatabase *rjDB = [RJFMDBDatabase sharedInstanced];
    [rjDB.dbQueue inDatabase:^(FMDatabase *db) {
        res = [db tableExists:tableName];
    }];
    return res;
}

@end
