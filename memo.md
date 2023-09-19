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
