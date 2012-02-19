classdef sevSegDisp < handle
    %% SEVENSEGMENTDISPLAY a container for seven segment objects, three
    %horizonatal segments and four verticle segments.

    %% Properties of a seven segment display
    %These properties are protected, and cannot be accessed outside of this
    %class
    properties (Access = protected)
        rows
        cols
        sevSegDispMatrix
        hSevSegDisp
        blk
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
        %Default constructor
        function obj = sevSegDisp(varargin)

            obj.hSevSegDisp = [];

            %Initialize Display Segment Locations
            obj.horSegments     = horSegment(5,2);
            obj.vertSegments    = vertSegment(2,5);
            obj.vertSegments(2) = vertSegment(18,5);
            obj.horSegments(2)  = horSegment(5,18);
            obj.vertSegments(3) = vertSegment(2,21);
            obj.vertSegments(4) = vertSegment(18,21);
            obj.horSegments(3)  = horSegment(5,34);

            setDims(obj);
            obj.sevSegDispMatrix = ones(obj.rows, obj.cols, 3);
            obj.blk              = ones(obj.rows, obj.cols, 3) * 255;

            switch nargin
                case 0
                    obj.number   = 0;
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 1
                    obj.number   = varargin{1};
                    obj.topLeftX = 0;
                    obj.topLeftY = 0;
                case 2
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.number   = 0;
                case 3
                    obj.topLeftX = varargin{1};
                    obj.topLeftY = varargin{2};
                    obj.number   = varargin{3};
                otherwise
                    error('Between 0 and 3 inputs allowed');
            end

            populateDisplay(obj);

            reInit(obj);
            addlistener(obj,'parentClosed', @parentClosedFcn);
            addlistener(obj,'number', 'PostSet', @obj.postSetNumberFcn);
        end

        function setDims(obj)
            obj.rows = 39;
            obj.cols = 23;
        end

        function mat = getMat(obj)
            mat = obj.sevSegDispMatrix;
        end

        function parentClosedFcn(obj, ~,~,~)
            obj.hSevSegDisp = [];
        end

        function notifyCloseParent(obj,source,eventData)
            notify(obj, 'parentClosed')
            closereq
        end

        function postSetNumberFcn(obj,meta,eventData)
            reInit(obj);
        end

        function disp(obj)
            tmpStr = 'The number is: %i,\nThe display is located at: (%i, %i)\n';
            fprintf(1, tmpStr, obj.number, obj.topLeftX, obj.topLeftY);
        end

        function display(obj) %gets rid of a = at top...
            disp(obj)
        end

        function set.number(obj, value)
            if (value < 0 || value > 9)
                warning('only integers from 0 - 9 allowed, not changed');
            else
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
                        obj.horSegments (1).status = true;
                        obj.horSegments (2).status = false;
                        obj.horSegments (3).status = true;
                        obj.vertSegments(1).status = true;
                        obj.vertSegments(2).status = true;
                        obj.vertSegments(3).status = true;
                        obj.vertSegments(4).status = true;
                        warning('Something went wrong in setting the number\n');
                end
                obj.number = value;
            end

            reInit(obj);
        end

        function imshow(obj)
            if isempty(obj.hSevSegDisp) %Original line creation
                obj.hSevSegDisp = imshow(obj.sevSegDispMatrix ./ obj.blk);
                set(gcf,'closeRequestFcn',@obj.notifyCloseParent); 
                set(gca,'DeleteFcn'      ,@obj.notifyCloseParent);
            else %isHandle because it exists...
                if ishandle(obj.hSevSegDisp)
                    set(obj.hSevSegDisp, 'CData', obj.sevSegDispMatrix...
                                                ./obj.blk);
                else
                    %Do nothing (it was ploted but has since disappeared
                    obj.hSevSegDisp = [];
                end
            end
        end

        function reInit(obj)
            populateDisplay(obj);

            if ~isempty(obj.hSevSegDisp)
                imshow(obj);
            end
        end
        
        function populateDisplay(obj)
            %initialize segment to a black rectangle
            obj.sevSegDispMatrix = zeros (obj.rows,obj.cols,3);
            
            for i = 1:size(obj.vertSegments,2)
                obj.sevSegDispMatrix(obj.vertSegments(i).topLeftY:...
                                    (obj.vertSegments(i).topLeftY ...
                                   + obj.vertSegments(i).getRows() - 1),...
                                     obj.vertSegments(i).topLeftX:...
                                    (obj.vertSegments(i).topLeftX ...
                                   + obj.vertSegments(i).getCols() - 1),...
                                     :)...
                                   = ...
               (obj.sevSegDispMatrix(obj.vertSegments(i).topLeftY:...
                                    (obj.vertSegments(i).topLeftY ...
                                   + obj.vertSegments(i).getRows() - 1),...
                                     obj.vertSegments(i).topLeftX:...
                                    (obj.vertSegments(i).topLeftX ...
                                   + obj.vertSegments(i).getCols() - 1),...
                                     :)...
                                   + obj.vertSegments(i).getMat());
            end
            for i = 1:size(obj.horSegments,2)
                obj.sevSegDispMatrix(obj.horSegments(i).topLeftY:...
                                    (obj.horSegments(i).topLeftY ...
                                   + obj.horSegments(i).getRows() - 1),...
                                     obj.horSegments(i).topLeftX:...
                                    (obj.horSegments(i).topLeftX ...
                                   + obj.horSegments(i).getCols() - 1),...
                                     :)...
                                   = ...
               (obj.sevSegDispMatrix(obj.horSegments(i).topLeftY:...
                                    (obj.horSegments(i).topLeftY ...
                                   + obj.horSegments(i).getRows() - 1),...
                                     obj.horSegments(i).topLeftX:...
                                    (obj.horSegments(i).topLeftX ...
                                   + obj.horSegments(i).getCols() - 1),...
                                     :)...
                                   + obj.horSegments(i).getMat());
            end
        end
    end
end

