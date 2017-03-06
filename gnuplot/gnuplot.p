##
# estas variables estan en el entorno, definidas por el archivo "generador-graficas"
##
csv_file=system("echo $csv_file")
year=system("echo $year")

set terminal png size 1800, 600
set output "../graficas/" . year . ".png"
set title year . " Indices de pm2.5, pm10, ozono, nox"
set size 1,0.9
set grid y
set xlabel "Fecha"
set ylabel "Indices"
set datafile separator ","

set grid
set xdata time
set timefmt "%Y-%m-%d %H"

plot csv_file using 1:2 smooth sbezier with lines title "Pm25", \
     csv_file using 1:3 smooth sbezier with lines title "Pm10", \
     csv_file using 1:4 smooth sbezier with lines title "Ozono", \
     csv_file using 1:5 smooth sbezier with lines title "Nox"

