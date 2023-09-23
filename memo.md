# テンプレコマンド集

## DB

### SQL系
```sql
# index作成
CREATE INDEX idx ON `table1` (`column1`, `column2`);
CREATE INDEX  ON `` (``);
CREATE INDEX  ON `` (``,``);

# 行数チェック
select table_name, table_rows from information_schema.TABLES where table_schema = '$DB_NANE';
```

### Golang
```go
sqlxでの`IN`の使い方
args := []...
// IN以外に検索条件がある場合はここで結合する
query, args, err := sqlx.In(
		"SELECT * FROM table WHERE column IN (?);",
		args)
if err != nil {
    return nil, err
}

query = db.Rebind(query)
rows := []Row{}
if err := db.SelectContext(
    ctx,
    &row,
    query,
    args...,
); err != nil {
    return nil, fmt.Errorf("", err)
}
```
