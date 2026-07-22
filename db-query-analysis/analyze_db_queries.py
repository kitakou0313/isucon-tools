#!/usr/bin/env python3
"""Analyze DB table CRUD usage from webapp/golang SQL queries.

Extracts SQL query strings passed to `database/sql` / `jmoiron/sqlx` query
methods (e.g. `db.Query`, `tx.ExecContext`, `db.SelectContext`, ...) in the Go
source (via tree-sitter), parses each query with sqlglot (MySQL dialect), and
reports how many Create/Read/Update/Delete queries touch each table.
"""

import argparse
import sys
from collections import defaultdict
from pathlib import Path
from typing import DefaultDict, Dict, List, Optional, Sequence, Tuple, Type

import sqlglot
from sqlglot import exp
import tree_sitter as ts
import tree_sitter_go as tsgo

TableStats = Dict[str, int]

# Method name -> index (within the call's named arguments) of the SQL query
# string. `Get`/`Select` take a destination pointer before the query, and
# `*Context` variants take a `ctx.Context` before that again.
QUERY_METHOD_ARG_INDEX: Dict[str, int] = {
    "Exec": 0, "ExecContext": 1,
    "Query": 0, "QueryContext": 1,
    "QueryRow": 0, "QueryRowContext": 1,
    "Queryx": 0, "QueryxContext": 1,
    "QueryRowx": 0, "QueryRowxContext": 1,
    "Get": 1, "GetContext": 2,
    "Select": 1, "SelectContext": 2,
    "NamedExec": 0, "NamedExecContext": 1,
    "NamedQuery": 0, "NamedQueryContext": 1,
    "MustExec": 0, "MustExecContext": 1,
    "Prepare": 0, "PrepareContext": 1,
    "PrepareNamed": 0, "PrepareNamedContext": 1,
}

VERB_BY_EXPRESSION: Dict[Type[exp.Expression], str] = {
    exp.Insert: "create",
    exp.Select: "read",
    exp.Update: "update",
    exp.Delete: "delete",
}

GO_ESCAPES: Dict[str, str] = {
    "n": "\n",
    "t": "\t",
    "r": "\r",
    "a": "\a",
    "b": "\b",
    "f": "\f",
    "v": "\v",
    "'": "'",
    '"': '"',
    "\\": "\\",
}


def unescape_go(raw_escape: str) -> str:
    # raw_escape includes the leading backslash, e.g. "\\n" or "\\\""
    ch = raw_escape[1:]
    return GO_ESCAPES.get(ch, ch)


def extract_string_value(node: ts.Node, src: bytes) -> str:
    parts: List[str] = []
    for child in node.children:
        if child.type in ("interpreted_string_literal_content", "raw_string_literal_content"):
            parts.append(src[child.start_byte : child.end_byte].decode())
        elif child.type == "escape_sequence":
            raw = src[child.start_byte : child.end_byte].decode()
            parts.append(unescape_go(raw))
    return "".join(parts)


def find_query_calls(
    node: ts.Node, src: bytes, results: List[Tuple[Optional[str], bool]]
) -> None:
    if node.type == "call_expression":
        fn_node = node.child_by_field_name("function")
        args_node = node.child_by_field_name("arguments")
        if fn_node is not None and args_node is not None and fn_node.type == "selector_expression":
            method_node = fn_node.child_by_field_name("field")
            if method_node is not None:
                method_name = src[method_node.start_byte : method_node.end_byte].decode()
                arg_index = QUERY_METHOD_ARG_INDEX.get(method_name)
                if arg_index is not None:
                    named_args = args_node.named_children
                    if len(named_args) > arg_index and named_args[arg_index].type in (
                        "interpreted_string_literal",
                        "raw_string_literal",
                    ):
                        sql = extract_string_value(named_args[arg_index], src)
                        results.append((sql, True))
                    else:
                        results.append((None, False))
    for child in node.children:
        find_query_calls(child, src, results)


def collect_queries(src_dir: Path) -> Tuple[List[str], int]:
    go_language = ts.Language(tsgo.language())
    parser = ts.Parser(go_language)

    queries: List[str] = []
    unparseable_extraction = 0

    for path in sorted(src_dir.rglob("*.go")):
        if "vendor" in path.parts or path.name.endswith("_test.go"):
            continue
        src = path.read_bytes()
        tree = parser.parse(src)
        results: List[Tuple[Optional[str], bool]] = []
        find_query_calls(tree.root_node, src, results)
        for sql, ok in results:
            if ok and sql is not None:
                queries.append(sql)
            else:
                unparseable_extraction += 1

    return queries, unparseable_extraction


def analyze(queries: List[str]) -> Tuple[DefaultDict[str, TableStats], int, int]:
    table_stats: DefaultDict[str, TableStats] = defaultdict(
        lambda: {"create": 0, "read": 0, "update": 0, "delete": 0}
    )
    unparseable_sql = 0
    tableless = 0

    for sql in queries:
        try:
            parsed = sqlglot.parse_one(
                sql, dialect="mysql", error_level=sqlglot.ErrorLevel.IGNORE
            )
        except Exception:
            unparseable_sql += 1
            continue

        verb = VERB_BY_EXPRESSION.get(type(parsed))
        if verb is None:
            unparseable_sql += 1
            continue

        tables = sorted({t.name for t in parsed.find_all(exp.Table)})
        if not tables:
            tableless += 1
            continue

        for table in tables:
            table_stats[table][verb] += 1

    return table_stats, unparseable_sql, tableless


def print_report(
    table_stats: Dict[str, TableStats],
    unparseable_extraction: int,
    unparseable_sql: int,
    tableless: int,
    total_queries: int,
) -> None:
    headers = ("table", "create", "read", "update", "delete")
    rows: List[Tuple[object, ...]] = []
    for table in sorted(table_stats):
        s = table_stats[table]
        rows.append((table, s["create"], s["read"], s["update"], s["delete"]))

    widths = [len(h) for h in headers]
    for row in rows:
        for i, value in enumerate(row):
            widths[i] = max(widths[i], len(str(value)))

    def fmt_row(row: Sequence[object]) -> str:
        return "  ".join(str(v).ljust(widths[i]) for i, v in enumerate(row))

    print(f"Detected tables: {len(rows)}")
    print()
    print(fmt_row(headers))
    print(fmt_row(["-" * w for w in widths]))
    for row in rows:
        print(fmt_row(row))

    print()
    print(f"Total queries analyzed: {total_queries}")
    if unparseable_extraction:
        print(f"  - dynamic queries (could not extract SQL string): {unparseable_extraction}")
    if unparseable_sql:
        print(f"  - unparseable SQL (sqlglot failed): {unparseable_sql}")
    if tableless:
        print(f"  - queries with no table reference: {tableless}")


def parse_args() -> argparse.Namespace:
    repo_root = Path(__file__).resolve().parent.parent
    default_src_dir = repo_root / "webapp"

    parser = argparse.ArgumentParser(
        description=(
            "Analyze DB table CRUD usage from webapp/golang SQL queries "
            "(database/sql and sqlx query methods parsed via tree-sitter + sqlglot)."
        )
    )
    parser.add_argument(
        "src_dir",
        nargs="?",
        type=Path,
        default=default_src_dir,
        help=f"Go source directory to scan recursively (default: {default_src_dir})",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    src_dir = args.src_dir.resolve()

    if not src_dir.is_dir():
        print(f"src directory not found: {src_dir}", file=sys.stderr)
        sys.exit(1)

    queries, unparseable_extraction = collect_queries(src_dir)
    table_stats, unparseable_sql, tableless = analyze(queries)
    total_queries = len(queries) + unparseable_extraction

    print_report(table_stats, unparseable_extraction, unparseable_sql, tableless, total_queries)


if __name__ == "__main__":
    main()
