classdef digitalClock < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    %% Properties of a seven segment display
    %These properties are protected, and cannot be accessed outside of this
    %class
    properties (Access = protected)
        rows
        cols
        clockMatrix
        hDigitalClock
        blk
    end
    %These properties are public, and can be accessed outside the class.
    %They are also observable, which means they can be watched by a
    %   listener function.
    properties (Access = public, SetObservable = true)
        numbers
        colons
        flagChange
    end
    %% Custom events to be listened for by the class
    events
        parentClosed
    end
    %% Member functions for the class
    methods
        %Default constructor
        function obj = digitalClock(varargin)

            obj.hDigitalClock = [];

            %Initialize Display Segment Locations
            obj.numbers    = sevenSegmentDisplay(  1, 1);%hours
            obj.numbers(2) = sevenSegmentDisplay( 24, 1);%hours
            obj.colons     = clockColon         ( 48, 1);
            obj.numbers(3) = sevenSegmentDisplay( 57, 1);%minutes
            obj.numbers(4) = sevenSegmentDisplay( 81, 1);%minutes
            obj.colons (2)  = clockColon         (105, 1);
            obj.numbers(5) = sevenSegmentDisplay(114, 1);%seconds
            obj.numbers(6) = sevenSegmentDisplay(138, 1);%seconds

            setDims(obj);
            obj.clockMatrix = ones(obj.rows, obj.cols, 3);
            obj.blk         = ones(obj.rows, obj.cols, 3) * 255;

            switch nargin
                case 0
                    obj.flagChange = false;
                otherwise
                    error('Between 0 and 3 inputs allowed');
            end

            populateDisplay(obj);

            reInit(obj);
%             addlistener(obj,'time', 'PostSet', @obj.postSetNumberFcn);
            addlistener(obj,'parentClosed', @parentClosedFcn);
        end

        function setDims(obj)
            obj.rows = 39;
            obj.cols = 161;
        end

        function mat = getMat(obj)
            mat = obj.clockMatrix;
        end

        function parentClosedFcn(obj, ~,~,~)
            obj.hDigitalClock = [];
        end

        function notifyCloseParent(obj,source,eventData)
            notify(obj, 'parentClosed');
            closereq;
        end

%         function postSetNumberFcn(obj,meta,eventData)
%             reInit(obj);
%         end

        function disp(obj)
%             tmpStr = 'The time is: %i\nThe display is located at: (%i, %i)\n';
%             fprintf(1, tmpStr, obj.number, obj.topLeftX, obj.topLeftY);
        end

        function display(obj) %gets rid of a = at top...
            disp(obj)
        end

%         function set.flagChange(obj, value)
%             reInit(obj);
%         end

        function imshow(obj)
            if isempty(obj.hDigitalClock) %Original line creation
                obj.hDigitalClock = imshow(obj.clockMatrix ./ obj.blk);
                set(gcf,'closeRequestFcn',@obj.notifyCloseParent); 
                set(gca,'DeleteFcn'      ,@obj.notifyCloseParent);

            else %isHandle because it exists...
                if ishandle(obj.hDigitalClock)
                    set(obj.hDigitalClock, 'CData', obj.clockMatrix...
                                                ./obj.blk);
                else
                    %Do nothing (it was ploted but has since disappeared
                    obj.hDigitalClock = [];
                end
            end
        end

        function reInit(obj)
            populateDisplay(obj);

            if ~isempty(obj.hDigitalClock)
                imshow(obj);
            end
        end
        
        function populateDisplay(obj)
            %initialize segment to a black rectangle
            obj.clockMatrix = zeros (obj.rows,obj.cols,3);
            
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
        
        function	testNumbers(obj)
            for i = 1:size(obj.numbers,2)
                for j = 0:9;
                    obj.numbers(i).number = j;
                    obj.flagChange = ~obj.flagChange;
                    pause(1);
                end
            end
        end
        function runClock(obj)
%             while(true)
                time = datestr(now,13);
                time = time(time ~= ':');
                for i = 1:size(obj.numbers,2)
                    obj.numbers(i).number = str2num(time(i));
%                     obj.flagChange = ~obj.flagChange;
%                     pause(0.1);
                end
%             end
        end
    end
end


