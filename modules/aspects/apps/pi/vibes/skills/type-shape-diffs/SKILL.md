---
name: type-shape-diffs
description: Use when a data structure changes shape — an API request/response payload, a DB schema or migration, a config file format, a serialized struct, or a protobuf/JSON contract — and old data or old clients still exist
---

# Type Shape Diffs

A migration's line diff shows the schema file. What matters is the *shape* of the data and what happens to the rows and clients that still use the old one.

## The Output

One unified skeleton with per-field markers, then a compatibility line.

```
Session {
    id          str
-   ttl         int                 removed
+   expires_at  datetime            added, NOT NULL, no default
~   user        str  →  UserRef     was the id, now the embedded object
?   scopes      list[str]?          was required, now nullable
    created_at  datetime
}

  +  added        -  removed        ~  type/meaning changed      ?  nullability changed

compat │ old writers  → break: expires_at has no default, insert fails
       │ old readers  → break: user is no longer a string
       │ existing rows → need backfill: expires_at = created_at + ttl
       │ migration     → NOT reversible (ttl is dropped)

anchors │ defined models/session.py:22 · serialized api/schemas.py:60 · migration 0impl14_expires.py
```

## Rules

- **Both directions of compatibility, always.** Old readers against new data, *and* old writers against the new shape. Skipping one is where deploy-order bugs come from.
- **Existing data gets its own line.** What happens to rows already written — backfill, default, or left null? "The code handles it" is not an answer for data at rest.
- **Say whether it's reversible.** If the migration drops information, say so explicitly; that's a decision the user may want to revisit.
- **`~` needs the meaning, not just the type.** `str → UserRef` is useless without "was the id, now the embedded object".
- **Show only the changed fields plus enough unchanged neighbors to orient.** A 40-field model with 3 changes should print ~8 lines.

## When Not To Use

Purely internal structs with a single writer and reader in the same commit, where no serialized data or other client exists.

Related: **blast-radius-maps** (who consumes this shape), **behavior-table-diffs** (what each input class now does).
