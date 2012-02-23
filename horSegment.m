classdef horSegment < clockSegment
    %% HORSEGMENT A horizontal segment of a seven segment display
    %
    % USES:
    %
    % seg = HORSEGMENT;
    % seg = HORSEGMENT(BOOL);
    % seg = HORSEGMENT(X, Y);
    % seg = HORSEGMENT(X, Y, BOOL);
    % seg = HORSEGMENT(X, Y, ROWS COLUMNS);
    %
    % seg = HORSEGMENT sets the status of the semgent to true and
    % defaults the x and y location of the top left corner of the
    % horSegment's matrix to (0, 0).
    %
    % seg = HORSEGMENT(BOOL) sets the status of the semgent to BOOL and
    % defaults the x and y location of the top left corner of the
    % horSegment's matrix to (0, 0).
    %
    % seg = HORSEGMENT(X, Y) sets the status of the semgent to true and
    % sets the x and y location of the top left corner of the
    % horSegment's matrix to (X, Y).
    %
    % seg = HORSEGMENT(X, Y, BOOL) sets the status of the semgent to BOOL
    % and sets the x and y location of the top left corner of the
    % horSegment's matrix to (X, Y).
    %
    % seg = HORSEGMENT(X, Y, ROWS, COLUMNS) sets the status of the semgent
    % to true, sets the x and y location of the top left corner of the
    % horSegment's matrix to (X, Y), and sets the size of the HORSEGMENT
    % to a ROWS X COLUMNS Matrix.
    %
    %
    % see also: CLOCKSEGMENT, VERTSEGMENT, SEVENSEGMENTDISP, DIGITALCLOCK,
    %           DIGICLOCK

    %% Member functions for the class
    methods
        function obj = horSegment(varargin)
        %Default constructor for the class
            %switch statement to parse inputs
            switch nargin
                case 0  %if nothing is passed then set values to default
                    obj.status   = true;
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 1  %for one input expect a boolean
                    obj.status   = varargin{1};
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 2  %for two inputs expect x and y values
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.status   = true;
                case 3  %for three inputs expect x, y, and then a boolean
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.status   = varargin{3};
                case 4  %for four inputs expect x, y, and then a boolean
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.rows     = varargin{3};
                    obj.cols     = varargin{4};
                    obj.status   = true;
                otherwise   %otherwise put out an error
                    error('Between 0 and 3 inputs allowed');
            end
            %handle is null until an image is created with IMSHOW
            obj.hSegment = [];
            %variables to store green and grey rgb values
            obj.green = 179;
            obj.grey  = 32;
            %set black to 255
            obj.black = 255;
            %rgb values 0 - 255
            obj.r     = 0;
            obj.g     = obj.green;
            obj.b     = 0;
            %set the row and column size for the segment's matrix
            setDims(obj)
            %initializes and fills the segment's matrix with color
            reInit(obj);
            %begins listening for different events to which it will react
            addlistener(obj,'parentClosed', @parentClosedFcn);
            addlistener(obj,'status', 'PostSet', @obj.postSetStatusFcn);
        end
        function setDims(obj)
        %set the number of rows and columns
            if(isempty(obj.rows))
                obj.rows =  5;
                obj.cols = 15;
            end
        end
        function fillSegment(obj)
        %fills the horSegment's matrix in a desired pattern
            %initialize horSegment to a green rectangle
            obj.segMatrix(:,:,1) = ones (obj.rows, obj.cols) .* obj.r;
            obj.segMatrix(:,:,2) = ones (obj.rows, obj.cols) .* obj.g;
            obj.segMatrix(:,:,3) = ones (obj.rows, obj.cols) .* obj.b;
            %set first and last row to begin taper
            obj.segMatrix(1:2,                   1,        :) = 0;
            obj.segMatrix((obj.rows-1):obj.rows, 1,        :) = 0;
            obj.segMatrix(1:2,                   obj.cols, :) = 0;
            obj.segMatrix((obj.rows-1):obj.rows, obj.cols, :) = 0;
            %set second and penultimate row to finish taper
            obj.segMatrix(1,        2,              :) = 0;
            obj.segMatrix(obj.rows, 2,              :) = 0;
            obj.segMatrix(1,        (obj.cols - 1), :) = 0;
            obj.segMatrix(obj.rows, (obj.cols - 1), :) = 0;
        end
    end
end
