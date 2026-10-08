"""Plot capture medians from the verified Step 7 sweep CSV (requires matplotlib)."""

import argparse
import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FixedLocator, FuncFormatter


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv", type=Path)
    parser.add_argument("output", type=Path, help="Output filename stem for PNG and SVG")
    args = parser.parse_args()
    with args.csv.open(newline="") as source:
        rows = [r for r in csv.DictReader(source) if r["implementation"] == "reference"]
    runs = list(dict.fromkeys(r["run"] for r in rows))
    if len(runs) != 2:
        parser.error("This comparison chart requires exactly two captures")
    families = [
        ("Row-vector × matrix", lambda m, k, n: m == 1, "K", "Size S: (1, S, S)"),
        ("Matrix × column-vector", lambda m, k, n: n == 1 and m == k, "K", "Size S: (S, S, 1)"),
        ("Width sweep: M=32, K=256", lambda m, k, n: m == 32, "N", "Output columns N"),
    ]
    plt.rcParams.update({"font.size": 10, "svg.fonttype": "none"})
    figure, axes = plt.subplots(1, 3, figsize=(14, 5), sharey=True)
    for axis, (title, predicate, dimension, xlabel) in zip(axes, families):
        selected = [r for r in rows if predicate(int(r["M"]), int(r["K"]), int(r["N"]))]
        sizes = sorted({int(r[dimension]) for r in selected})
        for run, color, marker in zip(runs, ("#2266aa", "#c75620"), ("o", "s")):
            values = {int(r[dimension]): float(r["reference_over_ikj_cpu_speedup"])
                      for r in selected if r["run"] == run}
            axis.plot(range(len(sizes)), [values[size] for size in sizes],
                      color=color, marker=marker, markersize=5, linewidth=1.6,
                      label=run.split("-")[0])
        axis.axhline(1, color="#555555", linewidth=1, linestyle="--")
        axis.set_yscale("log")
        axis.set_ylim(0.08, 20)
        axis.yaxis.set_major_locator(FixedLocator([0.1, 0.2, 0.5, 1, 2, 5, 10, 20]))
        axis.yaxis.set_major_formatter(FuncFormatter(lambda value, _: f"{value:g}×"))
        axis.set_xticks(range(len(sizes)), sizes, rotation=45)
        axis.set_title(title, fontweight="bold", pad=12)
        axis.set_xlabel(xlabel + " (categorical spacing)")
        axis.grid(axis="y", which="major", color="#dedede", linewidth=0.7)
        axis.spines[["top", "right"]].set_visible(False)
    axes[0].set_ylabel("Median CPU speedup: reference / ikj")
    figure.suptitle("Step 7: loop order helps wide outputs, hurts N=1", fontsize=16, y=0.98)
    figure.legend(*axes[0].get_legend_handles_labels(), loc="lower center", ncol=2,
                  bbox_to_anchor=(0.5, 0.06), frameon=False, title="Capture UTC start")
    figure.text(0.5, 0.015, "Above 1× favors ikj. Each point is a ratio of ten-repetition medians; no confidence interval is shown.",
                ha="center", fontsize=9, color="#444444")
    figure.tight_layout(rect=(0, 0.16, 1, 0.94))
    for suffix in (".png", ".svg"):
        figure.savefig(args.output.with_suffix(suffix), dpi=160, facecolor="white")


if __name__ == "__main__":
    main()
