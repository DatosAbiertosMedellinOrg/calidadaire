#!/bin/sh
for i in {2..7}
do
	export csv_file=../csv/201$i.csv
	export year=201$i
	gnuplot gnuplot.p
done