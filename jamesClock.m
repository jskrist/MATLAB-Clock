function jamesClock()

sizeMainLine = 40;
padPct       =  0.8;

drawHorBar();

% T = timer('ExecutionMode', 'fixedSpacing');


    function drawClock()
        
    end

    function drawHorBar()
        
        medLinePadding   = round(sizeMainLine * (1 - padPct)* padPct);
        smallLinePadding = round(sizeMainLine * (1 - padPct));

        if(mod(medLinePadding,2) ~= 0)
            medLinePadding = medLinePadding - 1;
        end
        if(mod(smallLinePadding,2) ~= 0)
            smallLinePadding = smallLinePadding - 1;
        end
        
        mainLine   = ones(1,sizeMainLine);
        medLine    = padarray(ones(1,(sizeMainLine-medLinePadding)),...
                              [0 (medLinePadding/2)]);
        smallLine  = padarray(ones(1,(sizeMainLine-smallLinePadding)),...
                              [0 (smallLinePadding/2)]);

        horSeg = [smallLine;
                  medLine;
                  mainLine;
                  medLine;
                  smallLine];
        
        imshow(horSeg);
        
    end

    function drawVerBar(x,y)
        
    end
    function blinkColon(blinkFlag)
        
    end

end