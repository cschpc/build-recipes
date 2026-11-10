import numpy as np
import matplotlib.pyplot as plt
import sys

def load_data(fname):
    data = np.loadtxt(fname, delimiter=',', dtype=np.dtype('u1'))
    return (data[::2]).reshape((int(data.shape[0] / 2), int(data.shape[1] / 3), 3))#,
           # (data[1::2]).reshape((int(data.shape[0] / 2), int(data.shape[1] / 3), 3)))

class Box():
    def __init__(self, left_bottom_back, right_top_front) -> None:
        self.lbb = left_bottom_back
        self.rtf = right_top_front
        self.hits = 0
        self.misses = 0

    def put(self, point: np.ndarray):
        if (self.lbb <= point).all() and (point < self.rtf).all():
            self.hits += 1
        else:
            self.misses += 1

    def total(self):
        return self.hits + self.misses

    def clear(self):
        self.hits = 0
        self.misses = 0

def make_boxes(ox, oy, oz, nx, ny, nz, bx, by, bz):
    boxes = {}
    for x in range(int(nx / bx)):
        for y in range(int(ny / by)):
            for z in range(int(nz / bz)):
                boxes[(x, y, z)] = Box(
                    np.array([ox + x * bx, oy + y * by, oz + z * bz]),
                    np.array([ox + (x + 1) * bx, oy + (y + 1) * by, oz + (z + 1) * bz]))
    return boxes

def fill_boxes_with(x1, x2, boxes, ppc, ox, oy, oz, ny, nz, bx, by, bz):
    particles_per_pencil = ppc * bz
    num_pencils = bx * by

    strides = []
    for _ in range(bx):
        for _ in range(by):
            strides.append((nz - bz) * ppc)
        strides[-1] += (ny - by) * nz * ppc

    for box in boxes.values():
        lbb = box.lbb
        offset = ((lbb[0] - ox) * ny * nz + (lbb[1] - oy) * nz + lbb[2] - oz) * ppc
        index = offset
        for i in range(num_pencils):
            for j in range(particles_per_pencil):
                point = x1[index + j]

                box.put(point)
                box.put(point + np.array([1, 0, 0]))
                box.put(point + np.array([0, 1, 0]))
                box.put(point + np.array([0, 0, 1]))
                box.put(point + np.array([0, 1, 1]))
                box.put(point + np.array([1, 0, 1]))
                box.put(point + np.array([1, 1, 0]))

                point = x2[index + j]

                box.put(point)
                box.put(point + np.array([1, 0, 0]))
                box.put(point + np.array([0, 1, 0]))
                box.put(point + np.array([0, 0, 1]))
                box.put(point + np.array([0, 1, 1]))
                box.put(point + np.array([1, 0, 1]))
                box.put(point + np.array([1, 1, 0]))

            index += particles_per_pencil + strides[i]

    return boxes

def plot(x1, x2):
    ppc = 4
    halo = 3
    #nx, ny, nz = (4, 4, 4)
    #bx, by, bz = (2, 2, nz)
    nx, ny, nz = (32, 32, 32)
    bx, by, bz = (1, 32, 32)
    ox, oy, oz = (halo, halo, halo)

    boxes = make_boxes(ox, oy, oz, nx, ny, nz, bx, by, bz)

    x = np.arange(0, x1.shape[0])
    y = np.zeros((len(boxes.values()), len(x)))

    for i in range(len(x)):
        boxes = fill_boxes_with(x1[i], x2[i], boxes, ppc, ox, oy, oz, ny, nz, bx, by, bz)
        for j, box in enumerate(boxes.values()):
            y[j][i] = box.hits / box.total()
            box.clear()

    for yy in y:
        plt.plot(x, yy)

    plt.show()

def save_data(x1, x2):
    id = np.arange(0, x1.shape[1]).reshape((x1.shape[1], 1))
    for i in range(x1.shape[0]):
        fname = "points.csv." + str(i)
        np.savetxt(fname, np.vstack((np.hstack((x1[i] + np.random.random(x1[i].shape) * 0.2, id)), np.hstack((x2[i] + np.random.random(x1[i].shape) * 0.2, id)))), delimiter=',', header="x,y,z,id")#, fmt='%u')

def save_avgs(x1, x2):
    m = 32
    n = int(x1.shape[1] / m)
    id = np.arange(0, n).reshape((n, 1))
    for i in range(x1.shape[0]):
        a = np.average(x1[i].reshape((n, m, 3)), axis=1)
        b = np.average(x2[i].reshape((n, m, 3)), axis=1)
        fname = "avg_points.csv." + str(i)
        np.savetxt(fname, np.vstack((np.hstack((a, id)), np.hstack((b, id)))), delimiter=',', header="x,y,z,id")#, fmt='%u')

def register_histograms(x):
    m = 64
    n = int(x.shape[1] / m)
    counts = np.zeros((x.shape[0], x.shape[1]))
    fig, axs = plt.subplots(nrows=int(x.shape[0] / 2), ncols=2)
    for i, x in enumerate(x):
        l = 0
        nbins = 0
        x = x.reshape((n, m, x.shape[1]))
        for x in x:
            _, c = np.unique(x, axis=0, return_counts=True)
            counts[i, l:l+len(c)] = c
            nbins = np.max((nbins, len(c)))
            l += len(c)
        axs[int(i / 2), int(i % 2)].hist(counts[i, :l], bins=100)
    plt.show()

def one_use_only_box(x):
    nthreads = 256
    ppc = 4
    box_size = np.array([2, 2, 64])
    particles_per_box = ppc * box_size[2]
    num_boxes = int(x.shape[1] / particles_per_box)
    counts = np.zeros((x.shape[0], num_boxes))

    for particles in x:
        particles = particles.reshape((num_boxes, particles_per_box, particles.shape[1]))
        misses = 0
        for box_particles in particles:
            box_lbb = np.array([
                np.min(box_particles[:, 0]),
                np.min(box_particles[:, 1]),
                np.min(box_particles[:, 2])])
            box_rtf = box_lbb + box_size

            particles_within = (box_lbb <= box_particles).all(axis=1) * (box_particles < box_rtf).all(axis=1)
            print(len(particles_within))

'''
TODO:
    ppc = 4 alkaa jo skaalautumaan aika huonosti.
    Olisi siis hyvä, jos jo sillä voitaisiin käyttää optimoitua versiota.

    Ajatuksena käyttää kertakäyttöistä laatikkoa jokaiselle blockille.
    Laatikko on kooltaan (2, 2, z), missä z määräytyy mm.
    simulaation koon ja ppc:n mukaan.

    z:n pitäisi olla jaollinen simulaation z-koolla.
    sekä threadit, että laatikon kokon voidaan valita vapaasti,
    eli pitää miettiä paperilla funktiota, jolla nämä valitaan.

    Yritetään pitää laatikon tiheys järkevänä:
    Jos ppc on hyvin pieni, laatikon täytyy olla kohtalaisen suuri.
    Tällöin kannattaa olla vähän säikeitä per kimppu:
    jos halutaan kertaluokkaa yksi hiukkanen per säde,
    pienentämällä säikeiden määrää voidaan pienentää tarvittavien
    hiukkasten määrää rittävän työn takaamiseksi, joten voidaan pienentää
    laatikon kokoa ja silti napata riittävästi hiukkasia.

    Eli, algoritmia, jonka perusteella valitaan säikeien määrä.
    Laatikolle voidaan päättää maksimikoko.

    LDS on 64kB, eli 64000 tavua. Jos tarkkuus on 32 bittiä per numero,
    mahtuu meillä 16000 numeroa. Toisaalta halutaan, että laatikko ei ole
    huikeasti suurempi kuin säikeiden määrä.

    CU:lla on neljä SIMDiä, ja jokaiselle mahtuu kahdeksan aaltoa, eli yhteensä
    32 aaltoa per CU. 64 säikeen aaltoja mahtuu 16 1024 kokoiseen kimppuun,
    eli 1024 kimppuja tarvitaan kaksi, jotta CU on täynnä.

    1024    2
    512     4
    256     8
    128     16

    Aaltoja 32.

    Kysymys: kannattaako jokaisella aallolla olla oma laatikko, vai pitäisikö tehdä
    yhteistyötä kimpun sisällä? Varmaan kimpun sisällä, koska aaltojen väliset laatikot
    ovat todennäköisesti ainakin jonkin verran päällekkäin.

    Eli, laatikko per kimppu. Miten se vaikuttaa LDS:n koon kanssa laatikon kokoon?

    Tehdään sama arvio kuin yllä, mutta jaetaan LDS per kimppu.

    Jos ajatellaan laatikon olevan aina (4, 4, z) kokoinen, voidaan laskea maksimi z:
    LDS-tavut / (4 tavua per numero * 4 * 4) = z

    kimpun koko     kimppuja per CU     LDS-tavua per kimppu    laatikon maksimi z
    1024             2                  32000                   floor(32000 / 64) = 500
     512             4                  16000                   floor(16000 / 64) = 250
     256             8                   8000                   floor( 8000 / 64) = 125
     128            16                   4000                   floor( 4000 / 64) =  62

    kimpun koko     laatikon maksimi z          solua per laatikko
    1024            floor(32000 / 64) = 500     4 * 4 * 500 = 8000
     512            floor(16000 / 64) = 250     4 * 4 * 250 = 4000
     256            floor( 8000 / 64) = 125     4 * 4 * 125 = 2000
     128            floor( 4000 / 64) =  62     4 * 4 *  62 = 992

    kimpun koko     solua per laatikko  hiukkasta per laatikko (ppc = 2)    hiukkasta per säie
    1024            4 * 4 * 500 = 8000  16000                               15,625
     512            4 * 4 * 250 = 4000  8000                                15,625
     256            4 * 4 * 125 = 2000  4000                                15,625
     128            4 * 4 *  62 = 992   1984                                15,5

     Jos halutaan pitää hiukkasten määrä per laatikko hitusen pienenmpänä,
     noin yksi per säie, pienennetään laatikkoa ~15 kertaa (16 kertaa?).
     Valitaan jokin kiva kakkosen potenssi zetalle.

    säikeitä kimpussa   laatikon koko   solua laatikossa  hiukkasta solussa     hiukkasta säikeellä
     128                (4, 4,  8)       128                 1                    1
     256                (4, 4, 16)       256                 1                    1
     512                (4, 4, 32)       512                 1                    1
    1024                (4, 4, 64)      1024                 1                    1

     256                (4, 4,  8)       128                 2                    1
     512                (4, 4, 16)       256                 2                    1
    1024                (4, 4, 32)       512                 2                    1

     512                (4, 4,  8)       128                 4                    1
    1024                (4, 4, 16)       256                 4                    1

    1024                (4, 4,  8)       128                 8                    1
    1024                (4, 4,  8)       128                16                    2
    1024                (4, 4,  8)       128                32                    4
    1024                (4, 4,  8)       128                64                    8
    1024                (4, 4,  8)       128               128                   16
    1024                (4, 4,  8)       128               256                   32
    1024                (4, 4,  8)       128               512                   64
    1024                (4, 4,  8)       128              1024                  128
    1024                (4, 4,  8)       128              2048                  256

    Koska simulaation koko vaikuttaa myös laatikon maksimikokoon, voidaan
    laatikon kokoa valita simulaation koon mukaan, ja sen mukaan valita säikeiden määrä:
    Jos simulaation koko z suunnassa >= 32
        säikeitä 1024
    Muuten, Jos z >= 16
        säikeitä 512
    Muuten, Jos z >= 8
        säikeitä 256
    Muuten, Jos z >= 4
        säikeitä 128
    

'''

def main():
    if len(sys.argv) < 3:
        print("Give two filename with indices as input")
        exit(1)

    #species0_x1, species1_x1 = load_data(sys.argv[1])
    #species0_x2, species1_x2 = load_data(sys.argv[2])
    species0_x1 = load_data(sys.argv[1])
    species0_x2 = load_data(sys.argv[2])
    #save_data(species0_x1, species0_x2)

    #plot(species0_x1, species0_x2)
    #plot(species1_x1, species1_x2)
    one_use_only_box(species0_x1)

if __name__ == "__main__":
    main()
