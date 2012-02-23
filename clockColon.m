classdef clockColon < handle
    %COLON Summary of this class goes here
    %   Detailed explanation goes here

    %% Properties of a seven segment display
    %These properties are protected, and cannot be accessed outside of this
    %class
    properties (Access = protected)
        rows
        cols
        colonMatrix
        hClockColon
        blk
    end
    %These properties are public, and can be accessed outside the class.
    %They are also observable, which means they can be watched by a
    %   listener function.
    properties (Access = public, SetObservable = true)
        topLeftX
        topLeftY
        dots
        status
    end
    %% Custom events to be listened for by the class
    events
        parentClosed
    end

    %% Member functions for the class
    methods
        %Default constructor
        function obj = clockColon(varargin)

            obj.hClockColon = [];

            %Initialize Display Segment Locations
            obj.dots    = clockSegment(2, 10, 5, 6);
            obj.dots(2) = clockSegment(2, 24, 5, 6);

            setDims(obj);
            obj.colonMatrix = ones(obj.rows, obj.cols, 3);
            obj.blk         = ones(obj.rows, obj.cols, 3) * 255;

            switch nargin
                case 0
                    obj.status   = true;
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 1
                    obj.status   = varargin{1};
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 2
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.status   = true;
                case 3
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.status   = varargin{3};
                otherwise
                    error('Between 0 and 3 inputs allowed');
            end

            populateDisplay(obj);

            reInit(obj);
            addlistener(obj,'parentClosed', @parentClosedFcn);
            addlistener(obj,'status', 'PostSet', @obj.postSetNumberFcn);
        end

        function setDims(obj)
            obj.rows = 39;
            obj.cols = 8;
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
            mat = obj.colonMatrix;
        end

        function parentClosedFcn(obj, ~,~,~)
            obj.hClockColon = [];
        end

        function notifyCloseParent(obj,source,eventData)
            notify(obj, 'parentClosed')
            closereq
        end

        function postSetNumberFcn(obj,meta,eventData)
            reInit(obj);
        end

        function disp(obj)
            tmpStr = 'The status is: %i,\nThe display is located at: (%i, %i)\n';
            fprintf(1, tmpStr, obj.status, obj.topLeftX, obj.topLeftY);
        end

        function display(obj) %gets rid of a = at top...
            disp(obj)
        end

        function set.status(obj, value)
            if (value ~= true && value ~= false)
                warning('only booleans allowed, not changed');
            else
                switch value
                    case false
                        obj.dots(1).status = false;
                        obj.dots(2).status = false;
                    case true
                        obj.dots(1).status = true;
                        obj.dots(2).status = true;
                    otherwise
                        obj.dots(1).status = true;
                        obj.dots(2).status = true;
                        warning('Something went wrong in setting the number\n');
                end
                obj.status = value;
            end

            reInit(obj);
        end
        
        function imshow(obj)
            if isempty(obj.hClockColon) %Original line creation
                obj.hClockColon = imshow(obj.colonMatrix ./ obj.blk);
                set(gcf,'closeRequestFcn',@obj.notifyCloseParent); 
                set(gca,'DeleteFcn'      ,@obj.notifyCloseParent);
            else %isHandle because it exists...
                if ishandle(obj.hClockColon)
                    set(obj.hClockColon, 'CData', obj.colonMatrix...
                                                ./obj.blk);
                else
                    %Do nothing (it was ploted but has since disappeared
                    obj.hClockColon = [];
                end
            end
        end

        function reInit(obj)
            populateDisplay(obj);

            if ~isempty(obj.hClockColon)
                imshow(obj);
            end
        end
        
        function populateDisplay(obj)
            %initialize segment to a black rectangle
            obj.colonMatrix = zeros (obj.rows,obj.cols,3);

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

