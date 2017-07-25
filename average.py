#!/usr/bin/env python

import glob
import csv
import pandas as pn


def avg_compute():
    try:
        f = pn.read_csv("siege.log")
        f.drop("      Date & Time", 1, inplace=True)
        f.to_csv("interm.csv")
    except "FileNotFoundError":
        print "The results file dosen't exist."
        exit(0)

    flag = 1

    with open('siege.log', 'a') as f_output:
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
            csv_output.writerow(["Average values:"]+averages)
    import os
    os.remove('interm.csv')
    #print in html format
    g = pn.read_csv("siege.log")
    g.to_html("result.html")
# we can pass the input file as a parameter
avg_compute()
