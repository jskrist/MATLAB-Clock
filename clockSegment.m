classdef clockSegment < handle
    %% CLOCKSEGMENT A clockSegment is the base class of a set of different
    %   objects which make up a seven segment display.
    %
    % USES:
    %
    % seg = CLOCKSEGMENT;
    % seg = CLOCKSEGMENT(bool);
    % seg = CLOCKSEGMENT(X, Y);
    % seg = CLOCKSEGMENT(X, Y, bool);
    %
    % seg = CLOCKSEGMENT sets the status of the semgent to true and
    % defaults the x and y locations of the top left corner of the
    % clockSegment's matrix to (0, 0).
    %
    % seg = CLOCKSEGMENT(bool) sets the status of the semgent to bool and
    % defaults the x and y locations of the top left corner of the
    % clockSegment's matrix to (0, 0).
    %
    % seg = CLOCKSEGMENT(X, Y) sets the status of the semgent to true and
    % sets the x and y locations of the top left corner of the
    % clockSegment's matrix to (X, Y).
    %
    % seg = CLOCKSEGMENT(X, Y, bool sets the status of the semgent to bool
    % and sets the x and y locations of the top left corner of the
    % clockSegment's matrix to (X, Y).
    %
    %
    %   see also: HORSEGMENT, VERTSEGMENT, SEVSEGDISP.
    
    
    %% Properties of a clockSegment
    %These properties are protected, and cannot be accessed outside of this
    %class
    properties (Access = protected)
        rows        %Number of rows in the segments matrix
        cols        %Number of columns in the segments matrix
        segMatrix   %A matrix which can be filled, then shown with IMSHOW
        black       %A value of 255 which is used to normalize segMatrix 
        hSegment    %A handle to the figure of the clockSegment
        r           %The red value of an rgb image/matrix
        g           %The green value of an rgb image/matrix
        b           %The blue value of an rgb image/matrix
    end
    %These properties are public, and can be accessed outside the class.
    %They are also observable, which means they can be watched by a
    %   listener function.
    properties (Access = public, SetObservable = true)
        green       %The rgb value of green to be used
        grey        %The rgb value of grey to be used
        status      %The status of the clockSegment, true or false, which defines whether the clockSegment is on or off
        topLeftX    %The X location of the top left corner of the segMatrix
        topLeftY    %The Y location of the top left corner of the segMatrix
    end
    %% Custom events to be listened for by the class
    events
        parentClosed    %When the parent object is closed trigger an event
    end
    %% Member functions for the class
    methods
        %Default constructor
        function obj = clockSegment(varargin)
        %Constructor for the class

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
            %set the row and column size for the clockSegment's matrix
            setDims(obj)
            %initializes and fills the clockSegment's matrix with color
            reInit(obj);
            %begins listening for different events to which it will react
            addlistener(obj,'parentClosed', @parentClosedFcn);
            addlistener(obj,'status', 'PostSet', @obj.postSetStatusFcn);
        end
        function rows = getRows(obj)
        %get the number of rows
            rows = obj.rows;
        end
        function cols = getCols(obj)
        %get the number of columns
            cols = obj.cols;
        end
        function mat = getMat(obj)
        %get the number of columns
            mat = obj.segMatrix;
        end
        function setDims(obj)
        %set the number of rows and columns
            obj.rows = 10;
            obj.cols = 10;
        end
        function setRGB(obj, red, green, blue)
        %set the rbg values to be used later
            obj.r = red;
            obj.g = green;
            obj.b = blue;
        end
        function parentClosedFcn(obj, ~,~,~)
        %when the parent object is closed set the handle to null
            obj.hSegment = [];
        end
        function notifyCloseParent(obj,~,~)
        %function necessary for custom event?
            notify(obj, 'parentClosed')
            closereq
        end
        function postSetStatusFcn(obj,~,~)
        %after the status is changed update the clockSegment and its image
            reInit(obj);
        end
        function disp(obj)
        %overload the DISP function to display what we want for this object
            tmpStr1 = 'The status is: %d,\n';
            tmpStr2 = 'The clockSegment is located at: (%i, %i)\n';
            fprintf(1,                  ...
                    [tmpStr1 tmpStr2],  ...
                    obj.status,         ...
                    obj.topLeftX,       ...
                    obj.topLeftY);
        end
        function display(obj) %gets rid of a = at top...
        %overload DISPLAY function
            disp(obj)
        end
        function set.status(obj, value)
        %overloaded set function for status property

            %Check if value is a boolean
            if (value ~= true && value ~= false)
                obj.status = true;
                warning('Not sure what you did, using default')
            else
                obj.status = value;
            end
            %reinitialize
            reInit(obj);
        end
        function imshow(obj)
        %overload IMSHOW function to show the clockSegment's matrix

            %if the image has not been created yet set the handle
            if isempty(obj.hSegment)
                obj.hSegment = imshow(obj.segMatrix);
                set(obj.hSegment, 'CData', obj.segMatrix./obj.black);
                set(gcf,'closeRequestFcn',@obj.notifyCloseParent); 
                set(gca,'DeleteFcn'      ,@obj.notifyCloseParent);
            else %isHandle because it exists...
                if ishandle(obj.hSegment)
                    %update the images data
                    set(obj.hSegment, 'CData', obj.segMatrix./obj.black);
                else
                    %Do nothing (it was ploted but has since disappeared)
                    obj.hSegment = [];
                end
            end
        end
        function reInit(obj)
        %checks the clockSegment's status and refils the matrix accordingly
        %   then shows the updated image
            if(obj.status)
                setRGB(obj, 0, obj.green, 0);
            else
                setRGB(obj, obj.grey, obj.grey, obj.grey);
            end
            %initialize clockSegment's matrix to all zeros and then fill it
            obj.segMatrix = zeros(obj.rows, obj.cols, 3);
            fillSegment(obj);
            %if the handle is not empty refresh the image
            if ~isempty(obj.hSegment)
                imshow(obj);
            end
        end
        function fillSegment(obj)
        %fills the clockSegment's matrix in a desired pattern

            %initialize clockSegment to a green rectangle
            obj.segMatrix(:,:,1) = ones (obj.rows,obj.cols) .* obj.r;
            obj.segMatrix(:,:,2) = ones (obj.rows,obj.cols) .* obj.g;
            obj.segMatrix(:,:,3) = ones (obj.rows,obj.cols) .* obj.b;
            %set first and last row to begin taper
            obj.segMatrix(1:2, 1, :)                         = 0;
            obj.segMatrix((obj.rows-1:obj.rows), 1, :)       = 0;
            obj.segMatrix(1:2,obj.cols, :)                   = 0;
            obj.segMatrix((obj.rows-1:obj.rows), obj.cols,:) = 0;
            %set second and penultimate row to finish taper
            obj.segMatrix(1, 2, :)                     = 0;
            obj.segMatrix(obj.rows, 2, :)              = 0;
            obj.segMatrix(1,(obj.cols - 1), :)         = 0;
            obj.segMatrix(obj.rows, (obj.cols - 1), :) = 0;
        end
    end
end