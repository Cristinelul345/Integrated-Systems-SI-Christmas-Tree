#!/usr/bin/env python3

import sys
import time
import requests


DEFAULT_HOST = "tema2.local:80"

# syntax: (speed, [colors_array...])
COLOR_SEQUENCES = [
    (1, [1, 2, 4, 5, 6]),
    (1, [7, 5, 4, 3, 5]),
    (2, [1, 5, 2, 3, 6]),
    (1, [6, 7, 3, 2, 5]),
    (1, [1, 2, 6, 2, 4]),
]


def color_sequence(nleds, seq, step):
    sequence = COLOR_SEQUENCES[seq][1]
    # compute the color sequence
    colors = []
    sidx = step // COLOR_SEQUENCES[seq][0]
    for _ in range(nleds):
        colors.append(sequence[sidx % len(sequence)])
        sidx += 1
    return colors


def main(host):
    url = "http://" + host
    headers = {'Accept': 'application/json'}
    r = requests.get(url + '/api/groups', headers=headers)
    n_groups = r.json()["NG"]
    g_nleds = {}
    for gid in range(1, n_groups + 1):
        # f-strings from Python >= 3.6 !
        r = requests.get(f'{url}/api/group/{gid}/state', headers=headers)
        g_nleds[str(gid)] = r.json()["NL"]
    
    step = 0
    try:
        while True:
            for gid, nleds in g_nleds.items():
                seq = (int(gid)) % len(COLOR_SEQUENCES)
                colors = color_sequence(nleds, seq, step)
                r = requests.post(f'{url}/api/group/{gid}/static',
                                  json={"LC": colors})
                r.raise_for_status()

            time.sleep(1)
            step += 1

    except KeyboardInterrupt:
        print('Interrupted!')
        sys.exit(0)

if __name__ == "__main__":
    host = DEFAULT_HOST
    if len(sys.argv) > 1:
        host = sys.argv[1]
    main(host)

