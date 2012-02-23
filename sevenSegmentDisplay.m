classdef sevenSegmentDisplay < handle
    %% SEVENSEGMENTDISPLAY is a container for seven segment objects, three
    % horizontal segments and four vertical segments.
    %
    % USES:
    %
    % seg = SEVENSEGMENTDISPLAY;
    % seg = SEVENSEGMENTDISPLAY(NUM);
    % seg = SEVENSEGMENTDISPLAY(X, Y);
    % seg = SEVENSEGMENTDISPLAY(X, Y, NUM);
    %
    % seg = SEVENSEGMENTDISPLAY defaults the number displayed to 0 and
    % the x and y locations of the top left corner of the
    % sevenSegmentDisplay's matrix to (0, 0).
    %
    % seg = SEVENSEGMENTDISPLAY(NUM) sets the number displayed to NUM and
    % defaults the x and y locations of the top left corner of the
    % sevenSegmentDisplay's matrix to (0, 0).
    %
    % seg = SEVENSEGMENTDISPLAY(X, Y) defaults the number displayed to 0
    % and sets the x and y locations of the top left corner of the
    % sevenSegmentDisplay's matrix to (X, Y).
    %
    % seg = SEVENSEGMENTDISPLAY(X, Y, NUM) sets the number displayed to NUM
    % and sets the x and y locations of the top left corner of the
    % sevenSegmentDisplay's matrix to (X, Y).
    %
    %
    % see also: CLOCKSEGMENT, VERTSEGMENT, SEVSEGDISP, DIGITALCLOCK,
    %           DIGICLOCK

    %% Properties of a seven segment display
    %These properties are protected, and cannot be accessed outside of this
    %class
    properties (Access = protected)
        rows
        cols
        sevSegDispMatrix
        hSevSegDisp
        black
    end
    %These properties are public, and can be accessed outside the class.
    %They are also observable, which means they can be watched by a
    %   listener function.
    properties (Access = public, SetObservable = true)
        topLeftX
        topLeftY
        horSegments
        vertSegments
        number
    end
    %% Custom events to be listened for by the class
    events
        parentClosed
    end
    %% Member functions for the class
    methods
        function obj = sevenSegmentDisplay(varargin)
        %Default constructor for the class
            %switch statement to parse inputs
            switch nargin
                case 0 %if nothing is passed then set values to default
                    obj.number   = 0;
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 1 %for one input expect a number
                    obj.number   = varargin{1};
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 2 %for two inputs expect x and y values
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.number   = 0;
                case 3 %for three inputs expect x, y, and then a number
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.number   = varargin{3};
                otherwise %otherwise put out an error
                    error('Between 0 and 3 inputs allowed');
            end
            %handle is null until an image is created with IMSHOW
            obj.hSevSegDisp = [];
            %Initialize Display Segment Locations
            %
            %   borderHeight  =  2;
            %   gap           =  1;
            %   horSegHeight  =  5;
            %   horSegLength  = 15;
            %   vertSegHeight = 15;
            %   vertSegLength =  5;
            %
            obj.horSegments     = horSegment ( 5,  2);
            obj.horSegments (2) = horSegment ( 5, 18);
            obj.horSegments (3) = horSegment ( 5, 34);
            obj.vertSegments    = vertSegment( 2,  5);
            obj.vertSegments(2) = vertSegment(18,  5);
            obj.vertSegments(3) = vertSegment( 2, 21);
            obj.vertSegments(4) = vertSegment(18, 21);
            %set the row and column size for the sevenSegmentDisplay's
            %   matrix
            setDims(obj);
            %set black to 255
            obj.black = 255;
            %initializes and fills the sevenSegmentDisplays's matrix with
            %   color
            reInit(obj);
            %begins listening for different events to which it will react
            addlistener(obj,'parentClosed', @parentClosedFcn);
            addlistener(obj,'number', 'PostSet', @obj.postSetNumberFcn);
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
            mat = obj.sevSegDispMatrix;
        end
        function setDims(obj)
        %set the number of rows and columns
            if(isempty(obj.rows))
                obj.rows = 39;
                obj.cols = 23;
            end
        end
        function parentClosedFcn(obj, ~,~,~)
        %when the parent object is closed set the handle to null
            obj.hSevSegDisp = [];
        end
        function notifyCloseParent(obj,source,eventData)
        %function necessary for custom event?
            notify(obj, 'parentClosed')
            closereq
        end
        function postSetNumberFcn(obj,meta,eventData)
        %after obj.number is changed update the sevenSegmentDisplay's image
            reInit(obj);
        end
        function disp(obj)
        %overload the DISP function to display what we want for this object
            tmpStr1 = 'The number is: %i,\n';
            tmpStr2 = 'The display is located at: (%i, %i)\n';
            fprintf(1,                 ...
                    [tmpStr1 tmpStr2], ...
                    obj.number,        ...
                    obj.topLeftX,      ...
                    obj.topLeftY);
        end
        function display(obj) %gets rid of a = at top...
        %overload DISPLAY function
            disp(obj)
        end
        function set.number(obj, value)
        %overloaded set function for status property
            %Check if value is between 0 and 9
            if (value < 0 || value > 9)
                warning('only integers from 0 - 9 allowed, not changed');
            else
                %Set the segments' statuses to show nummber given
                switch value
                    case 0
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = false;
                        obj.horSegments (3).status = true;
                        obj.vertSegments(1).status = true;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = true;
                        obj.vertSegments(4).status = true;
                    case 1
                        obj.horSegments (1).status = false;
                        obj.horSegments (2).status = false;
                        obj.horSegments (3).status = false;
                        obj.vertSegments(1).status = false;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = false;
                        obj.vertSegments(4).status = true;
                    case 2
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = true;
                        obj.horSegments (3).status = true;
                        obj.vertSegments(1).status = false;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = true;
                        obj.vertSegments(4).status = false;
                    case 3
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = true;
                        obj.horSegments (3).status = true;
                        obj.vertSegments(1).status = false;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = false;
                        obj.vertSegments(4).status = true;
                    case 4
                        obj.horSegments (1).status = false;
                        obj.horSegments (2).status = true;
                        obj.horSegments (3).status = false;
                        obj.vertSegments(1).status = true;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = false;
                        obj.vertSegments(4).status = true;
                    case 5
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = true;
                        obj.horSegments (3).status = true;
                        obj.vertSegments(1).status = true;
                        obj.vertSegments(2).status = false;
                        obj.vertSegments(3).status = false;
                        obj.vertSegments(4).status = true;
                    case 6
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = true;
                        obj.horSegments (3).status = true;
                        obj.vertSegments(1).status = true;
                        obj.vertSegments(2).status = false;
                        obj.vertSegments(3).status = true;
                        obj.vertSegments(4).status = true;
                    case 7
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = false;
                        obj.horSegments (3).status = false;
                        obj.vertSegments(1).status = false;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = false;
                        obj.vertSegments(4).status = true;
                    case 8
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = true;
                        obj.horSegments (3).status = true;
                        obj.vertSegments(1).status = true;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = true;
                        obj.vertSegments(4).status = true;
                    case 9
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = true;
                        obj.horSegments (3).status = false;
                        obj.vertSegments(1).status = true;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = false;
                        obj.vertSegments(4).status = true;
                    otherwise
                        obj.horSegments (1).status = false;
                        obj.horSegments (2).status = false;
                        obj.horSegments (3).status = false;
                        obj.vertSegments(1).status = false;
                        obj.vertSegments(2).status = false;
                        obj.vertSegments(3).status = false;
                        obj.vertSegments(4).status = false;
                        warning('Something went wrong in setting the number\n');
                end
                obj.number = value;
            end
            %reinitialize
            reInit(obj);
        end
        function imshow(obj)
        %overload IMSHOW function to show the sevenSegmentDisplay's matrix
            %if the image has not been created yet set the handle
            if isempty(obj.hSevSegDisp)
                obj.hSevSegDisp = imshow(obj.sevSegDispMatrix./obj.black);
                set(gcf,'closeRequestFcn',@obj.notifyCloseParent); 
                set(gca,'DeleteFcn'      ,@obj.notifyCloseParent);
            else %isHandle because it exists...
                if ishandle(obj.hSevSegDisp)
                    %update the images data
                    set(obj.hSevSegDisp, 'CData', obj.sevSegDispMatrix...
                                                ./obj.black);
                else
                    %Do nothing (it was ploted but has since disappeared
                    obj.hSevSegDisp = [];
                end
            end
        end
        function reInit(obj)
        %refills the matrix then shows the updated image
            populateDisplay(obj);
            %if the handle is not empty refresh the image
            if ~isempty(obj.hSevSegDisp)
                imshow(obj);
            end
        end
        function populateDisplay(obj)
            %initialize segment to a black rectangle
            obj.sevSegDispMatrix = zeros (obj.rows,obj.cols,3);
            %fills sevenSegmentDisplay with the segments
            for i = 1:size(obj.vertSegments,2)
                obj.sevSegDispMatrix(obj.vertSegments(i).topLeftY:      ...
                                    (obj.vertSegments(i).topLeftY       ...
                                   + obj.vertSegments(i).getRows() - 1),...
                                     obj.vertSegments(i).topLeftX:      ...
                                    (obj.vertSegments(i).topLeftX       ...
                                   + obj.vertSegments(i).getCols() - 1),...
                                     :)                                 ...
                                   =                                    ...
               (obj.sevSegDispMatrix(obj.vertSegments(i).topLeftY:      ...
                                    (obj.vertSegments(i).topLeftY       ...
                                   + obj.vertSegments(i).getRows() - 1),...
                                     obj.vertSegments(i).topLeftX:      ...
                                    (obj.vertSegments(i).topLeftX       ...
                                   + obj.vertSegments(i).getCols() - 1),...
                                     :)                                 ...
                                   + obj.vertSegments(i).getMat());
            end
            for i = 1:size(obj.horSegments,2)
                obj.sevSegDispMatrix(obj.horSegments(i).topLeftY:       ...
                                    (obj.horSegments(i).topLeftY        ...
                                   + obj.horSegments(i).getRows() - 1), ...
                                     obj.horSegments(i).topLeftX:       ...
                                    (obj.horSegments(i).topLeftX        ...
                                   + obj.horSegments(i).getCols() - 1), ...
                                     :)                                 ...
                                   =                                    ...
               (obj.sevSegDispMatrix(obj.horSegments(i).topLeftY:       ...
                                    (obj.horSegments(i).topLeftY        ...
                                   + obj.horSegments(i).getRows() - 1), ...
                                     obj.horSegments(i).topLeftX:       ...
                                    (obj.horSegments(i).topLeftX        ...
                                   + obj.horSegments(i).getCols() - 1), ...
                                     :)                                 ...
                                   + obj.horSegments(i).getMat());
            end
        end
    end
end
