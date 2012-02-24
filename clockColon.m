classdef clockColon < handle
    %% CLOCKCOLON a visual representation of a colon.
    %
    %
    % Syntax:
    %
    % colon = CLOCKCOLON;
    % colon = CLOCKCOLON(BOOL);
    % colon = CLOCKCOLON(X, Y);
    % colon = CLOCKCOLON(X, Y, BOOL);
    %
    %
    % Description:
    %
    % colon = CLOCKCOLON sets the status of the colon to true and
    % defaults the x and y locations of the top left corner of the
    % clockColon's matrix to (0, 0).
    %
    % colon = CLOCKCOLON(bool) sets the status of the colon to BOOL and
    % defaults the x and y locations of the top left corner of the
    % clockColon's matrix to (0, 0).
    %
    % colon = CLOCKCOLON(X, Y) sets the status of the colon to true and
    % sets the x and y locations of the top left corner of the
    % clockColon's matrix to (X, Y).
    %
    % colon = CLOCKCOLON(X, Y, bool) sets the status of the colon to BOOL
    % and sets the x and y locations of the top left corner of the
    % clockColon's matrix to (X, Y).
    %
    %
    % see also: CLOCKSEGMENT, HORSEGMENT, VERTSEGMENT, SEVENSEGMENTDISPLAY,
    %           DIGICLOCK

    %% Properties of a CLOCKCOLON
    %These properties are protected, and cannot be accessed outside of this
    %class
    properties (Access = protected)
        rows        %number of rows in the clockColon's matrix
        cols        %number of columns in the clockColon's matrix
        colonMatrix %a matrix to be filled, then shown with IMSHOW
        hClockColon %a handle to the figure of the clockColon
        black       %a value of 255 which is used to normalize colonMatrix
    end
    %These properties are public, and can be accessed outside the class.
    %They are also observable, which means they can be watched by a
    %   listener function.
    properties (Access = public, SetObservable = true)
        topLeftX    %the X location of the top left corner
                    %   of the colonMatrix
        topLeftY    %the Y location of the top left corner
                    %   of the colonMatrix
        dots        %vector containing horSegment objects
        status      %the status of the clockColon, true or false, which
                    %    defines whether the clockColon is on or off
    end
    %% Custom events to be listened for by the class
    events
        parentClosed
    end
    %% Member functions for the class
    methods
        function obj = clockColon(varargin)
        %Default constructor for the class

            %handle is null until an image is created with IMSHOW
            obj.hClockColon = [];
            %initialize colon segment Locations
            obj.dots    = horSegment(2, 10, 5, 6);
            obj.dots(2) = horSegment(2, 24, 5, 6);
            %set the row and column size for the clockColon's matrix
            setDims(obj);
            %set black to 255
            obj.black = 255;
            %switch statement to parse inputs
            switch nargin
                case 0    %if nothing is passed then set values to default
                    obj.status   = true;
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 1    %for one input expect a boolean
                    obj.status   = varargin{1};
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 2    %for two inputs expect x and y values
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.status   = true;
                case 3    %for three inputs expect x, y, and then a boolean
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.status   = varargin{3};
                otherwise %otherwise put out an error
                    error('Between 0 and 3 inputs allowed');
            end
            %initializes and fills the clockColon's matrix with color
            reInit(obj);
            %begins listening for an event to which it will react
            addlistener(obj,'parentClosed', @parentClosedFcn);
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
        %get the clockColon's Matrix
            mat = obj.colonMatrix;
        end
        function setDims(obj)
        %set the number of rows and columns
            obj.rows = 39;
            obj.cols = 8;
        end
        function parentClosedFcn(obj, ~,~,~)
        %when the parent object is closed set the handle to null
            obj.hClockColon = [];
        end
        function notifyCloseParent(obj,~,~)
        %function necessary for custom event?
            notify(obj, 'parentClosed')
            closereq
        end
        function disp(obj)
        %overload the DISP function to display what we want for this object
            tmpStr1 = 'The status is: %i,\n';
            tmpStr2 = 'The display is located at: (%i, %i)\n';
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
                warning('MATLAB:paramAmbiguous',...
                        'only booleans allowed, not changed');
            else
                switch value
                    case false
                        obj.dots(1).status = false; %#ok<*MCSUP>
                        obj.dots(2).status = false;
                    case true
                        obj.dots(1).status = true;
                        obj.dots(2).status = true;
                    otherwise
                        obj.dots(1).status = true;
                        obj.dots(2).status = true;
                        warning('MATLAB:paramAmbiguous',...
                                'Something went wrong setting a number\n');
                end
                obj.status = value;
            end
            %reinitialize
            reInit(obj);
        end
        function imshow(obj)
        %overload IMSHOW function to show the clockColon's matrix

            %if the image has not been created yet set the handle
            if isempty(obj.hClockColon)
                obj.hClockColon = imshow(obj.colonMatrix ./ obj.black);
                set(gcf,'closeRequestFcn',@obj.notifyCloseParent); 
                set(gca,'DeleteFcn'      ,@obj.notifyCloseParent);
            else %isHandle because it exists...
                if ishandle(obj.hClockColon)
                    %update the images data
                    set(obj.hClockColon, 'CData', obj.colonMatrix...
                                                ./obj.black);
                else
                    %Do nothing (it was ploted but has since disappeared)
                    obj.hClockColon = [];
                end
            end
        end
        function reInit(obj)
        %refills the matrix then shows the updated image
            populateDisplay(obj);

            if ~isempty(obj.hClockColon)
                imshow(obj);
            end
        end
        function populateDisplay(obj)
        %fills the clockColon with it's two horSegments

            %initialize segment to a black rectangle
            obj.colonMatrix = zeros (obj.rows,obj.cols,3);
            %fills clockColon with the segments
            for i = 1:size(obj.dots,2)
                obj.colonMatrix(obj.dots(i).topLeftY:...
                               (obj.dots(i).topLeftY ...
                              + obj.dots(i).getRows() - 1),...
                                obj.dots(i).topLeftX:...
                               (obj.dots(i).topLeftX ...
                              + obj.dots(i).getCols() - 1),...
                                :)...
                              = ...
               (obj.colonMatrix(obj.dots(i).topLeftY:...
                               (obj.dots(i).topLeftY ...
                              + obj.dots(i).getRows() - 1),...
                                obj.dots(i).topLeftX:...
                               (obj.dots(i).topLeftX ...
                              + obj.dots(i).getCols() - 1),...
                                :)...
                              + obj.dots(i).getMat());
            end
        end
    end
end

