import numpy as np
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import sys
import copy

def load_data(fname):
    data = np.loadtxt(fname, delimiter=',', dtype=np.dtype('f4'))
    return data.reshape((int(data.shape[0]), int(data.shape[1] / 3), 3))

def plot_box_sizes(i1_per_ppc, i2_per_ppc, simulation_box_size):
    values = np.zeros(int(i1_per_ppc[0].shape[1] / 16))
    Ns = [16, 32, 64, 128, 256, 512]
    xlims = [[0, 1024], [1024, 5000]]
    xticks = [[0, 256, 512, 768], [1024, 2048, 3072, 4096]]

    ylims = [0, 6]
    yticks = [0, 3]
    ytick_labels = [str(n) for n in yticks]

    colors = list(plt.get_cmap("tab10").colors)  # list of RGBA tuples

    for i1_per_timestep, i2_per_timestep in zip(i1_per_ppc, i2_per_ppc):
        fig = plt.figure(figsize=(32, 18), dpi=120)
        ppc = int(i1_per_timestep.shape[1] / simulation_box_size)
        fig.suptitle(f"PPC = {ppc}", fontsize=64)
        gs = fig.add_gridspec(i1_per_timestep.shape[0], 2, hspace=0, wspace=0)
        axes = gs.subplots(sharex='col', sharey='row')
        fig.text(0.5, 0.02, r"Box size $(x \times y \times z)$", ha='center', fontsize=64)
        fig.text(0.003, 0.5, r"count $10^y$", va='center', rotation='vertical', fontsize=64)

        plt.subplots_adjust(
            left=0.05, right=0.9985, top=0.935, bottom=0.135, wspace=0.2, hspace=0.2
        )

        print(f"Plotting ppc = {ppc}")

        for row, (i1, i2) in enumerate(zip(i1_per_timestep, i2_per_timestep)):
            for i, n in enumerate(Ns):
                x1 = i1.reshape((int(i1.shape[0] / n), n, 3))
                x2 = i2.reshape((int(i2.shape[0] / n), n, 3))
                num_values = x1.shape[0]
                for k in range(num_values):
                    x = np.vstack((x1[k], x2[k]))
                    values[k] = np.prod(np.max(x, axis=0) + np.ones(3) - np.min(x, axis=0))

                max_val = np.max(values[:num_values])
                cut = 1024
                szsmall = 32
                szbig = 128
                nsmall = int(cut / szsmall)
                nbig = int(np.ceil((max_val - cut) / szbig)) if max_val > cut else 1

                bins = ([idx * szsmall for idx in range(nsmall)]
                        + [cut + idx * szbig for idx in range(nbig)])
                counts, bins = np.histogram(values[:num_values], bins=bins)
                counts = np.array(counts, dtype=np.float64)
                counts[np.argwhere(counts == 0)] += 1e-1
                counts = np.log10(counts)
                inds = [0, nsmall, nsmall + nbig]

                for col in [0, 1]:
                    ax = axes[row, col]
                    begin = inds[col]
                    end = inds[col + 1]

                    label = "N = " + str(n)
                    lw = 5.0
                    ax.stairs(counts[begin:end],
                              bins[begin:end+1],
                              lw=0.0,
                              fill=True,
                              alpha=0.25,
                              color=colors[i],
                              )
                    ax.stairs(counts[begin:end],
                              bins[begin:end+1],
                              lw=lw,
                              label=label,
                              color=colors[i],
                              )

                    ax.label_outer()
                    if col == 1:
                        ax.set_title("lap = " + str(row), fontsize=32, x=0.001, y=0.65)

                    if row == 0 and col == 1:
                        leg = ax.legend(handlelength=10, ncol=3)
                        for txt in leg.get_texts():
                            txt.set_fontsize(32)

                    ax.tick_params(
                        axis="both",
                        which="minor",
                        bottom=False,
                        top=False,
                        left=False,
                        right=False,
                    )

                    if row == i1_per_timestep.shape[0] - 1:
                        ax.tick_params(
                            axis="x",
                            labelsize=64,
                            which="major",
                            length=20,
                            width=5,
                            grid_linewidth=2.0,
                        )
                    else:
                        ax.tick_params(
                            axis="x",
                            which="major",
                            bottom=False,
                            top=False,
                        )


                    if (col & 1) == 0:
                        ax.tick_params(
                            axis="y",
                            labelsize=44,
                            which="major",
                            length=20,
                            width=5,
                            grid_linewidth=2.0,
                        )
                    else:
                        ax.tick_params(
                            axis="y",
                            which="major",
                            left=False,
                            right=False,
                        )

                    ax.set_xlim(xlims[col])
                    ax.set_xticks(xticks[col])

                    ax.set_ylim(ylims)
                    ax.set_yticks(yticks, labels=ytick_labels, va='center')

                    ax.spines["left"].set_linewidth(3)
                    ax.spines["right"].set_linewidth(3)
                    ax.spines["bottom"].set_linewidth(3)
                    ax.spines["top"].set_linewidth(3)

        plt.show()
        #plt.savefig(f"box_size_ppc_{ppc}.png")

def plot_density_per_chunk(i1_per_ppc, i2_per_ppc, simulation_box_size):
    Ns = np.array([16, 32, 64, 128, 256, 512, 1024, 2048, 4096])
    values = np.zeros(len(Ns))
    colors = list(plt.get_cmap("tab10").colors)  # list of RGBA tuples

    for i1_per_timestep, i2_per_timestep in zip(i1_per_ppc, i2_per_ppc):
        accepted = np.zeros(len(Ns))
        avg_values = np.zeros(len(Ns))
        fig = plt.figure(figsize=(32, 18), dpi=120)
        ppc = int(i1_per_timestep.shape[1] / simulation_box_size)
        fig.suptitle(f"PPC = {ppc}", fontsize=64)
        ax1 = fig.add_subplot(111)
        ax1.set_xlabel("chunk size", fontsize=64)
        ax1.set_ylabel("avg particles per box", fontsize=64, rotation=90, labelpad=10)

        ax2 = ax1.twinx()
        ax2.set_ylabel("ratio of accepted boxes", fontsize=64, rotation=90, labelpad=10)

        plt.subplots_adjust(
            left=0.105, right=0.91, top=0.935, bottom=0.135, wspace=0.2, hspace=0.2
        )

        print(f"Plotting ppc = {ppc}")

        handles = []
        labels = []

        for lap, (i1, i2) in enumerate(zip(i1_per_timestep, i2_per_timestep)):
            for i, n in enumerate(Ns):
                x1 = i1.reshape((int(i1.shape[0] / n), n, 3))
                x2 = i2.reshape((int(i2.shape[0] / n), n, 3))
                x = np.concatenate((x1, x2), axis=1)
                mins = np.min(x, axis=1)
                maxs = np.max(x, axis=1)
                extent = maxs - mins + np.ones(3)
                indices = np.argwhere((extent < 16).all(axis=1))
                volume = np.prod(extent, axis=1)[indices]
                max_volume = np.prod([8, 8, 8])
                volume = volume[np.argwhere(volume < max_volume)]
                values[i] = np.average(n / volume) if volume.shape[0] > 0 else 0
                avg_values[i] += values[i]
                accepted[i] += volume.shape[0] / x1.shape[0]

            #label = "Lap = " + str(lap)
            #lw = 3.0
            #ms = 16.0
            #linestyle = '-'
            #marker = "o"
            #color = colors[lap]

            #handle = Line2D(
            #    [0],
            #    [0],
            #    linestyle=linestyle,
            #    marker=marker,
            #    color=color,
            #    lw=lw,
            #    ms=ms,
            #)
            #handles.append(handle)
            #labels.append(label)

            #ax1.semilogx(Ns,
            #        values,
            #        linestyle=linestyle,
            #        marker=marker,
            #        lw=lw,
            #        ms=ms,
            #        color=color,
            #        )

        label = "lap avg"
        lw = 3.0
        ms = 16.0
        linestyle = '-'
        marker = "o"
        color = "black"

        handle = Line2D(
            [0],
            [0],
            linestyle=linestyle,
            marker=marker,
            color=color,
            lw=lw,
            ms=ms,
        )
        handles.append(handle)
        labels.append(label)

        ax1.semilogx(Ns,
                avg_values / i1_per_timestep.shape[0],
                linestyle=linestyle,
                marker=marker,
                lw=lw,
                ms=ms,
                color=color,
                )

        label = "ratio of accepted boxes"
        lw = 3.0
        ms = 16.0
        linestyle = '-'
        marker = "s"
        color = "black"
        handle = Line2D(
            [0],
            [0],
            linestyle=linestyle,
            marker=marker,
            color=color,
            lw=lw,
            ms=ms,
        )
        handles.append(handle)
        labels.append(label)

        ax2.semilogx(
                Ns,
                accepted / i1_per_timestep.shape[0],
                linestyle=linestyle,
                marker=marker,
                lw=lw,
                ms=ms,
                color=color,
                )

        leg = ax1.legend(
            handles=handles,
            labels=labels,
            loc="upper right",
            handlelength=10,
        )

        for txt in leg.get_texts():
            txt.set_fontsize(32)

        for axis in [ax1, ax2]:
            axis.tick_params(
                axis="both",
                which="minor",
                bottom=False,
                top=False,
                left=False,
                right=False,
            )

            axis.tick_params(
                axis="both",
                which="major",
                labelsize=64,
                length=20,
                width=5,
                grid_linewidth=2.0,
            )

            #axis.set_xlim(xlims)
            #axis.set_xticks(xticks)

            #axis.set_ylim(ylims)
            #axis.set_yticks(yticks, labels=ytick_labels, va='center')

            axis.spines["left"].set_linewidth(3)
            axis.spines["right"].set_linewidth(3)
            axis.spines["bottom"].set_linewidth(3)
            axis.spines["top"].set_linewidth(3)

        plt.show()
        #plt.savefig(f"density_ppc_{ppc}.png")

def plot_chunk_size(i1_per_ppc, i2_per_ppc, simulation_box_size):
    Ns = np.array([16, 32, 64, 128, 256, 512, 1024, 2048, 4096])

    for i1_per_timestep, i2_per_timestep in zip(i1_per_ppc, i2_per_ppc):
        values = np.zeros(len(Ns))
        fig = plt.figure(figsize=(32, 18), dpi=120)
        ppc = int(i1_per_timestep.shape[1] / simulation_box_size)
        fig.suptitle(f"PPC = {ppc}", fontsize=64)
        ax = fig.add_subplot(111)
        ax.set_xlabel("chunk size", fontsize=64)
        ax.set_ylabel("chunk points", fontsize=64, rotation=90, labelpad=10)

        plt.subplots_adjust(
            left=0.105, right=0.9985, top=0.935, bottom=0.135, wspace=0.2, hspace=0.2
        )

        print(f"Plotting ppc = {ppc}")

        for i1, i2 in zip(i1_per_timestep, i2_per_timestep):
            for i, n in enumerate(Ns):
                x1 = i1.reshape((int(i1.shape[0] / n), n, 3))
                x2 = i2.reshape((int(i2.shape[0] / n), n, 3))
                x = np.concatenate((x1, x2), axis=1)
                mins = np.min(x, axis=1)
                maxs = np.max(x, axis=1)
                extent = maxs - mins + np.ones(3)
                indices = np.argwhere((extent < 16).all(axis=1))
                volume = np.prod(extent, axis=1)[indices]
                max_volume = np.prod([8, 8, 8])
                volume = volume[np.argwhere(volume < max_volume)]

                density = (np.average(n / volume) if volume.shape[0] > 0 else 0) / i1_per_timestep.shape[0]

                ratio_of_accepted_boxes = volume.shape[0] / x1.shape[0] / i1_per_timestep.shape[0]

                values[i] += density * ratio_of_accepted_boxes
                             
        lw = 3.0
        ms = 16.0
        linestyle = '-'
        marker = "o"
        color = "black"

        ax.semilogx(Ns,
                values,
                linestyle=linestyle,
                marker=marker,
                lw=lw,
                ms=ms,
                color=color,
                )

        ax.tick_params(
            axis="both",
            which="minor",
            bottom=False,
            top=False,
            left=False,
            right=False,
        )

        ax.tick_params(
            axis="both",
            which="major",
            labelsize=64,
            length=20,
            width=5,
            grid_linewidth=2.0,
        )

        #ax.set_xlim(xlims)
        ax.set_xticks(Ns, labels=[str(n) for n in Ns])

        #ax.set_ylim(ylims)
        #ax.set_yticks(yticks, labels=ytick_labels, va='center')

        ax.spines["left"].set_linewidth(3)
        ax.spines["right"].set_linewidth(3)
        ax.spines["bottom"].set_linewidth(3)
        ax.spines["top"].set_linewidth(3)

        #plt.show()
        plt.savefig(f"density_ppc_{ppc}.png")

# TODO: debug this
def relative_counts_of_atomics(i1, i2):
    block_size = i1.shape[1]
    wavefronts_per_block = block_size / 64
    wavefronts_per_cu = 32
    blocks_per_cu = wavefronts_per_cu / wavefronts_per_block
    floats_in_lds_per_cu = 64000 / 4
    max_volume = floats_in_lds_per_cu / blocks_per_cu

    cells = np.concatenate((i1, i2), axis=1)
    lbb = np.min(cells, axis=1)
    rtf = np.max(cells, axis=1)
    extent = rtf - lbb + 2 * np.ones(3)
    volume = np.prod(extent, axis=1).reshape((extent.shape[0], 1))
    idx_max_dim = np.argmin(extent, axis=1)
    new_max = np.floor(extent[idx_max_dim] * max_volume / volume)

    max_box = copy.deepcopy(extent)
    max_box[idx_max_dim] = new_max

    extent = np.where(volume <= max_volume, extent, max_box)
    lbb = np.hstack([lbb for _ in range(block_size)]).reshape((lbb.shape[0], block_size, lbb.shape[1]))
    extent = np.hstack(
            [extent for _ in range(block_size)]).reshape((extent.shape[0], block_size, extent.shape[1]))
    rtf = lbb + extent

    test_inside = lambda inds: ((lbb <= inds) * (inds < rtf)).all(axis=2)
    counts = np.zeros(i1.shape[0])

    counts += np.sum(test_inside(i1 + np.array([0, 0, 0])), axis=1)
    counts += np.sum(test_inside(i1 + np.array([1, 0, 0])), axis=1)
    counts += np.sum(test_inside(i1 + np.array([0, 1, 0])), axis=1)
    counts += np.sum(test_inside(i1 + np.array([0, 0, 1])), axis=1)
    counts += np.sum(test_inside(i1 + np.array([0, 1, 1])), axis=1)
    counts += np.sum(test_inside(i1 + np.array([1, 0, 1])), axis=1)
    counts += np.sum(test_inside(i1 + np.array([1, 1, 0])), axis=1)

    counts += np.sum(test_inside(i2 + np.array([0, 0, 0])), axis=1)
    counts += np.sum(test_inside(i2 + np.array([1, 0, 0])), axis=1)
    counts += np.sum(test_inside(i2 + np.array([0, 1, 0])), axis=1)
    counts += np.sum(test_inside(i2 + np.array([0, 0, 1])), axis=1)
    counts += np.sum(test_inside(i2 + np.array([0, 1, 1])), axis=1)
    counts += np.sum(test_inside(i2 + np.array([1, 0, 1])), axis=1)
    counts += np.sum(test_inside(i2 + np.array([1, 1, 0])), axis=1)

    global_atomics = 14 * block_size * i1.shape[0]
    total_atomics = np.sum(14 * block_size - counts) + np.sum(np.prod(extent[:, 0, :].reshape((extent.shape[0], extent.shape[2])), axis=1))

    return total_atomics / global_atomics

# TODO: should run this for bigger simulation sizes...
# Now a very large chunk of the simulation fits into a single box
def plot_atomics(i1_per_ppc, i2_per_ppc, simulation_box_size):
    chunks = np.array([16, 32, 64, 128, 256, 512, 1024, 2048, 4096])
    values = np.zeros(int(i1_per_ppc[0].shape[1] / 16))

    for i1_per_timestep, i2_per_timestep in zip(i1_per_ppc, i2_per_ppc):
        fig = plt.figure(figsize=(32, 18), dpi=120)
        ppc = int(i1_per_timestep.shape[1] / simulation_box_size)
        fig.suptitle(f"PPC = {ppc}", fontsize=64)
        ax = fig.add_subplot(111)
        ax.set_xlabel("chunk size", fontsize=64)
        ax.set_ylabel("chunk points", fontsize=64, rotation=90, labelpad=10)

        plt.subplots_adjust(
            left=0.105, right=0.9985, top=0.935, bottom=0.135, wspace=0.2, hspace=0.2
        )

        print(f"Plotting ppc = {ppc}")

        for lap, (i1, i2) in enumerate(zip(i1_per_timestep, i2_per_timestep)):
            for i, chunk_sz in enumerate(chunks):
                i1_chunked = i1.reshape((int(i1.shape[0] / chunk_sz), chunk_sz, 3))
                i2_chunked = i2.reshape((int(i2.shape[0] / chunk_sz), chunk_sz, 3))
                values[i] = relative_counts_of_atomics(i1_chunked, i2_chunked)
            ax.semilogx(chunks, values[:len(chunks)])
        plt.show()

def main():
    if len(sys.argv) < 3:
        print("Give base name of index file "
              "and list of indices, e.g. '~/Documents/runko/indices 1 2 4 8'")
        exit(1)

    base = sys.argv[1]

    simulation_box_size = 16 * 16 * 16
    i1_per_ppc = []
    i2_per_ppc = []
    for i in reversed(sys.argv[2:]):
        fname1 = base + "1_ppc" + str(i) + ".dat"
        fname2 = base + "2_ppc" + str(i) + ".dat"
        i1_per_ppc.append(load_data(fname1))
        i2_per_ppc.append(load_data(fname2))

    plot_atomics(i1_per_ppc, i2_per_ppc, simulation_box_size)
    #plot_chunk_size(i1_per_ppc, i2_per_ppc, simulation_box_size)
    #plot_density_per_chunk(i1_per_ppc, i2_per_ppc, simulation_box_size)
    #plot_box_sizes(i1_per_ppc, i2_per_ppc, simulation_box_size)

if __name__ == "__main__":
    main()
