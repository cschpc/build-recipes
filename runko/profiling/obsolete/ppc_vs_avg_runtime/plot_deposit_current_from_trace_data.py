import json
import matplotlib.pyplot as plt
from matplotlib import color_sequences, ticker
from cycler import cycler
import numpy as np
import sys

args = sys.argv
if len(args) < 4:
    print(f"Give at least four arguments: python {args[0]} base_name1 base_name2 count[s]")
    print(
        ', where base_names are the base names of the trace files, e.g. "~/Documents/user/runko/profiling/ppc_"'
    )
    print(
        'and count[s] is one or more numbers matching the endings of the filenames, e.g. "2 4 8 16 32"'
    )
    exit(1)

fname_base1 = args[1]
fname_base2 = args[2]
ppcs = args[3:]

both_timings = []
for fname_base in [fname_base1, fname_base2]:
    timings = {}
    for ppc in ppcs:
        fname = fname_base + str(ppc) + ".json"
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
                    per_name_timings[pid] = {}
                per_pid_timings = per_name_timings[pid]

                if ppc not in per_pid_timings:
                    per_pid_timings[ppc] = []
                per_ppc_timings = per_pid_timings[ppc]

                per_ppc_timings.append(event["dur"])
    both_timings.append(timings)

names_of_interest = [
    "prtcl_deposit_current",
]

f = plt.figure(figsize=(32, 18), dpi=120)
plt.rcParams["axes.prop_cycle"] = cycler(color=color_sequences["tab20"])
ax = f.add_subplot(111)
ax.set_xscale("log", base=2)
ax.set_yscale("log", base=2)
plt.subplots_adjust(
    left=0.095, right=0.9985, top=0.995, bottom=0.135, wspace=0.2, hspace=0.2
)
ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
ax.set_ylim(2**9, 2**21)

for timings in both_timings:
    for name, per_pid_timings in timings.items():
        if name not in names_of_interest:
            continue
        fn_avgs = {}
        for per_ppc_timings in per_pid_timings.values():
            for ppc, timings in per_ppc_timings.items():
                if ppc not in fn_avgs:
                    fn_avgs[ppc] = []
                fn_avgs[ppc].append(timings[1:])

        x = np.array([int(i) for i in fn_avgs.keys()])
        y = np.array([np.average(durations) for durations in fn_avgs.values()])
        if not name.startswith("comm_"):
            std = np.array([np.std(durations) for durations in fn_avgs.values()])
        else:
            std = np.zeros_like(y)
        ax.errorbar(x, y, yerr=std, linestyle="-", marker="o", lw=3.0, ms=16.0, label=name)

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

ax.set_xlabel("ppc", fontsize=64)
ax.set_ylabel("avg time [ms]", fontsize=64, rotation=90, labelpad=10)

leg = ax.legend(handlelength=10, loc="upper left")

for txt in leg.get_texts():
    txt.set_fontsize(32)

ax.grid(True)
#plt.show()
plt.savefig("ppc_vs_runtime_of_deposit.png")
