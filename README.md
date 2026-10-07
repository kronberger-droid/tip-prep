# tip-prep

Writing and figures for automatic, reproducible preparation of SPM tips
(IAP, TU Wien). The automation itself lives in
[rusty-tip](https://github.com/kronberger-droid/rusty-tip).

| Folder | What it is |
|---|---|
| `report/` | Project work write-up |
| `poster/` | Conference poster |
| `figures/` | Per-run plots of tip-prep runs: frequency shift and pulse sequence |

Each folder is its own Typst project. Build from inside it, so that
root-relative paths like `/data/...` resolve against that folder:

```sh
cd figures && typst watch main.typ
```

The folders were separate repositories until they were merged here with
their history (`git log -- poster/` and so on still shows it).
