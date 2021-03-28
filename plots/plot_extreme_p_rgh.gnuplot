reset
set term X11
set output

set y2tics

set yrange [*:1e7]


p "postProcessing/patchExpression_extremeP/0/back" w l axis x1y1 t "p_rgh" ,\
  "postProcessing/patchExpression_maxPPosition/0/back" u 1:2 '%lf (%lf %lf %lf)'  w l axis x1y2 t "xpos"