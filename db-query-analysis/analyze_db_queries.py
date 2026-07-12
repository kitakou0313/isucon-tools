#!/usr/bin/env python3
"""Analyze DB table CRUD usage from webapp/nodejs SQL queries.

Extracts SQL query strings passed to `dbConn.query(...)` / `dbConn.execute(...)`
calls in the TypeScript source (via tree-sitter), parses each query with
sqlglot (MySQL dialect), and reports how many Create/Read/Update/Delete
queries touch each table.
"""

import argparse
import sys
from collections import defaultdict
from pathlib import Path
from typing import DefaultDict, Dict, List, Optional, Sequence, Tuple, Type

import sqlglot
from sqlglot import exp
import tree_sitter as ts
import tree_sitter_typescript as tsts

TableStats = Dict[str, int]

QUERY_METHOD_NAMES = {"query", "execute"}
RECEIVER_HINT = "dbConn"

VERB_BY_EXPRESSION: Dict[Type[exp.Expression], str] = {
    exp.Insert: "create",
    exp.Select: "read",
    exp.Update: "update",
    exp.Delete: "delete",
}

JS_ESCAPES: Dict[str, str] = {
    "n": "\n",
    "t": "\t",
    "r": "\r",
    "b": "\b",
    "f": "\f",
    "v": "\v",
    "0": "\0",
    "'": "'",
    '"': '"',
    "`": "`",
    "\\": "\\",
}


def unescape_js(raw_escape: str) -> str:
    # raw_escape includes the leading backslash, e.g. "\\n" or "\\$"
    ch = raw_escape[1:]
    return JS_ESCAPES.get(ch, ch)


def extract_string_value(node: ts.Node, src: bytes) -> str:
    parts: List[str] = []
    for child in node.children:
        if child.type in ("string_fragment", "template_chars"):
            parts.append(src[child.start_byte : child.end_byte].decode())
        elif child.type == "escape_sequence":
            raw = src[child.start_byte : child.end_byte].decode()
            parts.append(unescape_js(raw))
    return "".join(parts)


def find_query_calls(
    node: ts.Node, src: bytes, results: List[Tuple[Optional[str], bool]]
) -> None:
    if node.type == "call_expression":
        fn_node = node.child_by_field_name("function")
        args_node = node.child_by_field_name("arguments")
        if fn_node is not None and args_node is not None:
            fn_text = src[fn_node.start_byte : fn_node.end_byte].decode()
            method_name = fn_text.rsplit(".", 1)[-1]
            if method_name in QUERY_METHOD_NAMES and RECEIVER_HINT in fn_text:
                named_args = args_node.named_children
                if named_args and named_args[0].type in ("string", "template_string"):
                    sql = extract_string_value(named_args[0], src)
                    results.append((sql, True))
                else:
                    results.append((None, False))
    for child in node.children:
        find_query_calls(child, src, results)


def collect_queries(src_dir: Path) -> Tuple[List[str], int]:
    ts_language = ts.Language(tsts.language_typescript())
    parser = ts.Parser(ts_language)

    queries: List[str] = []
    unparseable_extraction = 0

    for path in sorted(src_dir.rglob("*.ts")):
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
    default_src_dir = repo_root / "webapp" / "nodejs" / "src"

    parser = argparse.ArgumentParser(
        description=(
            "Analyze DB table CRUD usage from webapp/nodejs SQL queries "
            "(dbConn.query/execute calls parsed via tree-sitter + sqlglot)."
        )
    )
    parser.add_argument(
        "src_dir",
        nargs="?",
        type=Path,
        default=default_src_dir,
        help=f"TypeScript source directory to scan (default: {default_src_dir})",
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
