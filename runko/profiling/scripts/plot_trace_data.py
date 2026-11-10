import json
import matplotlib.pyplot as plt
from matplotlib import color_sequences
from cycler import cycler
import numpy as np
from pathlib import Path

base_dir = "/home/jlankine/Documents/runko/profiling"
file_name = "combined.json"
files = [
        "23603341-viztracer-tgl842",
        "23603702-viztracer-tgl84",
        ]
layout_names = [x.split("-")[-1] for x in files]
files = [Path(base_dir) / x / file_name for x in files]

per_file_durations = []
for fname in files:
    durations = {}
    with open(fname, "r") as f:
        json_data = json.load(f)
        events = json_data["traceEvents"]

        for event in events:
            if "dur" not in event:
                continue

            name = event["name"]
            name = name.split()[0]
            if name not in durations:
                durations[name] = {}
            per_name_durations = durations[name]

            pid = event["pid"]
            if pid not in per_name_durations:
                per_name_durations[pid] = []
            per_pid_durations = per_name_durations[pid]
            per_pid_durations.append(event["dur"])

    per_file_durations.append(durations)

names_of_interest = [
    "grid_push_half_b",
    "comm_external",
    "prtcl_sort",
    "prtcl_push",
    "prtcl_pack_outgoing",
    "prtcl_deposit_current",
    "comm_local",
    "grid_filter_current",
    "grid_push_e",
    "grid_add_current",
]

f = plt.figure(figsize=(32, 18), dpi=120)
plt.rcParams["axes.prop_cycle"] = cycler(color=color_sequences["tab20"])
ax = f.add_subplot(111)
ax.set_yscale("log", base=2)
plt.subplots_adjust(
    left=0.095, right=0.95, top=0.995, bottom=0.3, wspace=0.2, hspace=0.2
)
ax.set_ylim(2**1, 2**12)

for layout_name, durations in zip(layout_names, per_file_durations):
    tick_names = []
    avgs = []
    stds = []
    for name, per_pid_durations in durations.items():
        if name not in names_of_interest:
            continue
        tick_names.append(name)
        fn_durs = []
        for dur in per_pid_durations.values():
            fn_durs.append(dur[1:])

        avgs.append(np.average(fn_durs))
        if not name.startswith("comm_"):
            std = np.std(fn_durs)
        else:
            std = 0
        stds.append(std)
    x = np.arange(len(avgs))
    y = avgs
    ax.errorbar(x, y, yerr=stds, linestyle="-", marker="o", lw=3.0, ms=16.0, label=layout_name)
    ax.set_xticks(x, labels=tick_names, ha='right')

ax.tick_params(
    axis="both",
    which="major",
    labelsize=64,
    length=20,
    width=5,
    grid_linewidth=2.0,
)
ax.tick_params(
    axis="x",
    labelsize=32,
    labelrotation=35.0,
)
ax.tick_params(
    axis="both",
    which="minor",
    bottom=False,
    top=False,
    left=False,
    right=False,
)

ax.spines["left"].set_linewidth(3)
ax.spines["right"].set_linewidth(3)
ax.spines["bottom"].set_linewidth(3)
ax.spines["top"].set_linewidth(3)

ax.set_xlabel("functions", fontsize=64)
ax.set_ylabel("avg time [ms]", fontsize=64, rotation=90, labelpad=10)

leg = ax.legend(handlelength=10, loc="upper left")

for txt in leg.get_texts():
    txt.set_fontsize(32)

ax.grid(True)
plt.show()
#plt.savefig("ppc_vs_runtime_of_deposit.png")
