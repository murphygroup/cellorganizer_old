function shape = img2medial_axis(shape_bw)    

theta = ml_majorangle(shape_bw)*180/pi;
shape_bw = ml_rotate(shape_bw,-theta);

%extract medial axis
[imgaxis, medaxis, width] = ...
    ml_imaxis(uint8(shape_bw));

shape = ml_mxs2mxp(medaxis,width);