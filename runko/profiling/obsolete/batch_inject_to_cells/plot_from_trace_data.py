import json
import matplotlib.pyplot as plt
from matplotlib import color_sequences, ticker
from cycler import cycler
import numpy as np
import sys

args = sys.argv
if len(args) < 2:
    print(f"Give two arguments: python {args[0]} filename")
    print(
        ', where filename is the name of the trace file, e.g. "~/Documents/user/runko/profiling/trace.json"'
    )
    exit(1)

fname = args[1]

timings = {}
with open(fname, "r") as f:
    json_data = json.load(f)
    events = json_data["traceEvents"]

    for event in events:
        if "dur" not in event:
            continue

        name = event["name"]
        name = name.split()[0]
        if name not in timings:
            timings[name] = {}
        per_name_timings = timings[name]

        pid = event["pid"]
        if pid not in per_name_timings:
            per_name_timings[pid] = []
        per_pid_timings = per_name_timings[pid]
        per_pid_timings.append(event["dur"])

names_of_interest = [
    "batch_inject_to_cells",
]

f = plt.figure(figsize=(32, 18), dpi=120)
plt.rcParams["axes.prop_cycle"] = cycler(color=color_sequences["tab20"])
ax = f.add_subplot(111)
#ax.set_xscale("log", base=2)
#ax.set_yscale("log", base=10)
plt.subplots_adjust(
    left=0.095, right=0.9985, top=0.995, bottom=0.135, wspace=0.2, hspace=0.2
)
#ax.xaxis.set_major_formatter(ticker.ScalarFormatter())

for name, per_pid_timings in timings.items():
    if name not in names_of_interest:
        continue
    fn_avgs = {}
    for pid, durations in per_pid_timings.items():
        ax.plot(np.array(durations) / 1000, "-o", lw=3.0, ms=16.0, label=str(pid))

ax.tick_params(
    axis="both",
    which="major",
    labelsize=64,
    length=20,
    width=5,
    grid_linewidth=2.0,
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

ax.set_xlabel("invocation", fontsize=64)
ax.set_ylabel("time [ms]", fontsize=64, rotation=90, labelpad=10)

leg = ax.legend(handlelength=10, loc="upper left")

for txt in leg.get_texts():
    txt.set_fontsize(32)

ax.grid(True)
plt.show()
