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

var Row struct {
	ID int `db:"id"`
}

// Bulk insert
var rowsToAdd []Row // insertしたい行を含むstruct

for idx, content := range ${insertしたいデータ} {
    rowsToAdd = append(rowsToAdd, Row{
    })
}

// NamedExecにしないといけないっぽい
if _, err := db.NamedExecContext(
    ctx,
    "INSERT INTO ${table} (`columnName1`, `columnName2) VALUES (:${tag_name}, :${tag_name})",
    playlistSongRowsToAdd,
); err != nil {
    return fmt.Errorf(
        "error Batch Insert:%w", err,
    )
}
return nil

// インメモリキャッシュ
type CacheRow struct {
	sync.RWMutex
	data map[string]*Row
}

func NewCacheRow() *CacheRow {
	return &cacheRow{
		data: make(map[string]*Row),
	}
}

func (c *CacheRow) Set(k string, v *Row) {
	c.Lock()
    defer c.Unlock()
	c.data[k] = v
}

func (c *CacheRow) Get(k string) *Row {
	c.RLock()
    defer c.RUnlock()
	return c.data[k]
}


func (c *CacheRow) Remove(k string) {
	c.RLock()
	defer c.RUnlock()
	delete(c.data, k)
}

// 同一Rock内で実施しないと不整合が置き得る
func (c *CacheRow) GetAndIsIn(k string) (*CacheRow, bool) {
	c.RLock()
    defer c.RUnlock()
    data, isIn := c.data[k]
	return data, isIn
}
```
