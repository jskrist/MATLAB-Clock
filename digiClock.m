classdef digiClock < handle
    %% DIGICLOCK is a container for six sevenSegmentDisplay objects, and
    % two clockColon objects which simulates a 24 hour digital clock.
    %
    % Syntax:
    %
    % clock = DIGICLOCK;
    %
    %
    % Description:
    %
    % clock = DIGICLOCK sets the time displayed to the time it was
    % created.  in order to update the time the clock.runClock() function
    % needs to be called.
    % 
    % Tip:
    %
    %   The time can be updated in a loop or with a timer which changes the
    %   clock.flagChange variable
    %
    % Example:
    %
    %   clk = DIGICLOCK;
    %
    %   set(gcf, 'closerequestfcn','stop(t);delete(t);delete(gcf)');
    %
    %   t = timer('period',0.5);
    %   set(t,'ExecutionMode','fixedrate','StartDelay',0);
    %   set(t,'timerfcn','clk.flagChange = ~clk.flagChange;');
    %   start(t);
    %
    %
    % see also: CLOCKSEGMENT, HORSEGMENT, VERTSEGMENT, SEVENSEGMENTDISPLAY,
    %           CLOCKCOLON

    %% Properties of a seven segment display
    %These properties are protected, and cannot be accessed outside of this
    %class
    properties (Access = protected)
        rows          %number of rows in the digiClock's matrix
        cols          %number of columns in the digiClock's matrix
        clockMatrix   %a matrix to be filled, then shown with IMSHOW
        hDigitalClock %a handle to the figure of the digiClock
        black         %a value of 255, used to normalize clockMatrix
    end
    %These properties are public, and can be accessed outside the class.
    %They are also observable, which means they can be watched by a
    %   listener function.
    properties (Access = public, SetObservable = true)
        numbers    %vector containing sevenSegmentDisplay objects
        colons     %vector containing clockColon objects
        flagChange %boolean which is used to indicate a change to the
                   %    digiClock has been requested
    end
    %% Custom events to be listened for by the class
    events
        parentClosed
    end
    %% Member functions for the class
    methods
        function obj = digiClock(varargin)
        %Default constructor for the class

            %handle is null until an image is created with IMSHOW
            obj.hDigitalClock = [];
            %Initialize Display Segment Locations
            obj.numbers    = sevenSegmentDisplay(1,  1);%hours
            obj.numbers(2) = sevenSegmentDisplay(24, 1);%hours
            obj.colons     = clockColon(48, 1);
            obj.numbers(3) = sevenSegmentDisplay(57, 1);%minutes
            obj.numbers(4) = sevenSegmentDisplay(81, 1);%minutes
            obj.colons(2)  = clockColon(105,1);
            obj.numbers(5) = sevenSegmentDisplay(114,1);%seconds
            obj.numbers(6) = sevenSegmentDisplay(138,1);%seconds
            %set the row and column size for the digiClock's matrix
            setDims(obj);
            %set black to 255
            obj.black = 255;
            %initializes and fills the digiClock's matrix with color
            reInit(obj);
            %begins listening for an event to which it will react
            addlistener(obj,'parentClosed', @parentClosedFcn);
            %show the digiClock
            imshow(obj);
            %set inital time as now
            runClock(obj);
        end
        function mat = getMat(obj)
        %get the digiClocks's Matrix
            mat = obj.clockMatrix;
        end
        function setDims(obj)
        %set the number of rows and columns
            obj.rows = 39;
            obj.cols = 161;
        end
        function parentClosedFcn(obj, ~,~,~)
        %when the parent object is closed set the handle to null
            obj.hDigitalClock = [];
        end
        function notifyCloseParent(obj,~,~)
        %function necessary for custom event?
            notify(obj, 'parentClosed');
            closereq;
        end
        function disp(obj)
        %overload the DISP function to display what we want for this object
            tmpStr = ['The current time is: ',      ...
                      datestr(now,13),              ...
                      '\nThe flagChange is %i\n'];
            fprintf(1, tmpStr, obj.flagChange);
        end
        function display(obj) %gets rid of a = at top...
        %overload DISPLAY function
            disp(obj)
        end
        function set.flagChange(obj, ~)
        %overloaded set function for flagChange property which is used to
        %   update the time displayed on the clock object
            runClock(obj);
        end
        function imshow(obj)
        %overload IMSHOW function to show the digiClock's matrix
            %if the image has not been created yet set the handle
            if isempty(obj.hDigitalClock)
                obj.hDigitalClock = imshow(obj.clockMatrix ./ obj.black,...
                                           'border',                    ...
                                           'tight');
                set(gca,'DeleteFcn',              ...
                        @obj.notifyCloseParent,   ...
                        'ActivePositionProperty', ...
                        'position');
                set(gcf,'closeRequestFcn',@obj.notifyCloseParent); 
                set(gcf,'NumberTitle',  'off',  ...
                        'DockControls', 'on',   ...
                        'Resize',       'on',  ...
                        'menubar',      'none');
            else %isHandle because it exists...
                if ishandle(obj.hDigitalClock)
                    set(obj.hDigitalClock, 'CData', obj.clockMatrix...
                                                ./obj.black);
                else
                    %Do nothing (it was ploted but has since disappeared)
                    obj.hDigitalClock = [];
                end
            end
        end
        function reInit(obj)
        %refills the matrix then shows the updated image
            populateDisplay(obj);

            if ~isempty(obj.hDigitalClock)
                imshow(obj);
            end
        end
        function populateDisplay(obj)
        %fills the digiClock with it's numbers and colons

            %initialize segment to a black rectangle
            obj.clockMatrix = zeros (obj.rows,obj.cols,3);
            %fills digiClock with the sevenSegmentDisplays and clockColons
            for i = 1:size(obj.numbers,2)
                obj.clockMatrix(obj.numbers(i).topLeftY:...
                                    (obj.numbers(i).topLeftY ...
                                   + obj.numbers(i).getRows() - 1),...
                                     obj.numbers(i).topLeftX:...
                                    (obj.numbers(i).topLeftX ...
                                   + obj.numbers(i).getCols() - 1),...
                                     :)...
                                   = ...
               (obj.clockMatrix(obj.numbers(i).topLeftY:...
                                    (obj.numbers(i).topLeftY ...
                                   + obj.numbers(i).getRows() - 1),...
                                     obj.numbers(i).topLeftX:...
                                    (obj.numbers(i).topLeftX ...
                                   + obj.numbers(i).getCols() - 1),...
                                     :)...
                                   + obj.numbers(i).getMat());
            end
            for i = 1:size(obj.colons,2)
                obj.clockMatrix(obj.colons(i).topLeftY:...
                                    (obj.colons(i).topLeftY ...
                                   + obj.colons(i).getRows() - 1),...
                                     obj.colons(i).topLeftX:...
                                    (obj.colons(i).topLeftX ...
                                   + obj.colons(i).getCols() - 1),...
                                     :)...
                                   = ...
               (obj.clockMatrix(obj.colons(i).topLeftY:...
                                    (obj.colons(i).topLeftY ...
                                   + obj.colons(i).getRows() - 1),...
                                     obj.colons(i).topLeftX:...
                                    (obj.colons(i).topLeftX ...
                                   + obj.colons(i).getCols() - 1),...
                                     :)...
                                   + obj.colons(i).getMat());
            end
        end
        function testClock(obj)
        %test the functionality of the sevenSegmentDisplays and clockColons
            for i = 1:size(obj.numbers,2)
                for j = 0:9;
                    obj.numbers(i).number = j;
                    reInit(obj);
                    pause(0.1);
                end
            end
            for i = 1:size(obj.colons,2)
                obj.colons(i).status = ~obj.colons(i).status;
                reInit(obj);
                pause(0.1);
                obj.colons(i).status = ~obj.colons(i).status;
                reInit(obj);
                pause(0.1);
            end
        end
        function runClock(obj)
        %updates the time displayed to the current time
           time = datestr(now,13);
           set(gcf,'Name', time)
           time = time(time ~= ':');
           for i = 1:size(obj.numbers,2)
               obj.numbers(i).number = str2double(time(i));
           end
           reInit(obj);
        end
    end
end


