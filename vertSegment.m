classdef vertSegment < clockSegment
    %% VERTSEGMENT A vertical segment of a seven segment display
    %
    % Syntax:
    %
    % seg = VERTSEGMENT;
    % seg = VERTSEGMENT(BOOL);
    % seg = VERTSEGMENT(X, Y);
    % seg = VERTSEGMENT(X, Y, BOOL);
    % seg = VERTSEGMENT(X, Y, ROWS COLUMNS);
    %
    %
    % Description:
    %
    % seg = VERTSEGMENT sets the status of the semgent to true and
    % defaults the x and y location of the top left corner of the
    % vertSegment's matrix to (0, 0).
    %
    % seg = VERTSEGMENT(BOOL) sets the status of the semgent to BOOL and
    % defaults the x and y location of the top left corner of the
    % vertSegment's matrix to (0, 0).
    %
    % seg = VERTSEGMENT(X, Y) sets the status of the semgent to true and
    % sets the x and y location of the top left corner of the
    % vertSegment's matrix to (X, Y).
    %
    % seg = VERTSEGMENT(X, Y, BOOL) sets the status of the semgent to BOOL
    % and sets the x and y location of the top left corner of the
    % vertSegment's matrix to (X, Y).
    %
    % seg = VERTSEGMENT(X, Y, ROWS, COLUMNS) sets the status of the semgent
    % to true, sets the x and y location of the top left corner of the
    % vertSegment's matrix to (X, Y), and sets the size of the VERTSEGMENT
    % to a ROWS X COLUMNS Matrix.
    %
    %
    % see also: CLOCKSEGMENT, HORSEGMENT, SEVENSEGMENTDISPLAY, DIGICLOCK

    %% Member functions for the class
    methods
        function obj = vertSegment(varargin)
        %Default constructor for the class

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
                obj.rows = 15;
                obj.cols =  5;
            end
        end
        function fillSegment(obj)
        %fills the vertSegment's matrix in a desired pattern
            %initialize vertSegment to a green rectangle
            obj.segMatrix(:,:,1) = ones (obj.rows, obj.cols) .* obj.r;
            obj.segMatrix(:,:,2) = ones (obj.rows, obj.cols) .* obj.g;
            obj.segMatrix(:,:,3) = ones (obj.rows, obj.cols) .* obj.b;
            %set first and last row to begin taper
            obj.segMatrix(1,        1:2,                   :) = 0;
            obj.segMatrix(1,        (obj.cols-1):obj.cols, :) = 0;
            obj.segMatrix(obj.rows, 1:2,                   :) = 0;
            obj.segMatrix(obj.rows, (obj.cols-1):obj.cols, :) = 0;
            %set second and penultimate row to finish taper
            obj.segMatrix(2,              1,        :) = 0;
            obj.segMatrix(2,              obj.cols, :) = 0;
            obj.segMatrix((obj.rows - 1), 1,        :) = 0;
            obj.segMatrix((obj.rows - 1), obj.cols, :) = 0;
        end
    end
end
