#!/usr/bin/gnuplot

set term eps
set output "X.eps"
set grid xtics ytics
set bar 0
set xzeroaxis lt -1
set yzeroaxis lt -1

#set xrange [0:T1]

do for [i=2:20] {
plot "output_data_point.txt" using 1:i linewidth 1  with lines  title sprintf("%g particles",i)
}


