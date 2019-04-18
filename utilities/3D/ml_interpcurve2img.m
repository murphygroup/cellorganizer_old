function sliceimg = ml_interpcurve2img( imgsize, x, y )

    sliceimg = zeros(imgsize);
    % interpolate using 100 points for each line segment
    for t = 1:length(x)-1
        rpts = round(linspace(y(t),y(t+1),100));
        cpts = round(linspace(x(t),x(t+1),100));
        try
            index = sub2ind(imgsize,rpts,cpts);
            sliceimg(index) = 255;
        catch
            warning(['CellOrganizer: Out of range subscript ' num2str(t) ' when adding pixel to image'])
        end
    end

end

