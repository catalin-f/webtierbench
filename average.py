#!/usr/bin/env python

import glob
import csv
import pandas as pn
import os


def avg_compute(filename):
    file = filename
    try:
        f = pn.read_csv(filename)
        f.drop("      Date & Time", 1, inplace=True)
        f.drop("  Trans", 1, inplace=True)
        f.drop("  Elap Time", 1, inplace=True)
        f.drop("  Data Trans", 1, inplace=True)
        f.drop("  Resp Time", 1, inplace=True)
        f.drop("  Throughput", 1, inplace=True)
        f.drop("  Concurrent", 1, inplace=True)
        f.drop("    OKAY", 1, inplace=True)
        f.drop("   Failed", 1, inplace=True)
        f.to_csv("interm.csv")
    except "FileNotFoundError":
        print "The results file dosen't exist."
        exit(0)

    flag = 1

    with open(filename, 'a') as f_output:
        csv_output = csv.writer(f_output)
        for filename in glob.glob('interm.csv'):
            with open(filename) as f_input:
                csv_input = csv.reader(f_input)
                header = next(csv_input)
                averages = []
                for col in zip(*csv_input):
                    if flag == 1:
                        del col
                        flag=0
                        continue
                    avg = list(col)
                    avg  = map(float, avg)
                    avg = list(set(avg))
                    avg.remove(min(avg))
                    avg.remove(max(avg))
                    tuple(avg)
                    averages.append(sum(float(x)for x in  avg) / len(avg))
                    del avg[:]
            csv_output.writerow(["Average values:"] + [""] + [""] + [""] + [""] + averages)
    path = os.path.realpath(".")
    remove_file = str(path + '/interm.csv')
    os.remove(remove_file)
    from _base import consoleLogger
    consoleLogger("Results are stored in siege.log/result.html in user home.")
    g = pn.read_csv(file)
    g.to_html("~/Result.html")
# we can pass the input file as a parameter

