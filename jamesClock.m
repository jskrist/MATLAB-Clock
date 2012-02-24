%create a digiClock object
clk = digiClock;
%remove the menubar for a simplified look

%stop and delete the timer when the figure is closed
set(gcf, 'closerequestfcn','stop(t);delete(t);delete(gcf)');
%Build Timer object that will update every 0.5 seconds
t = timer('period',0.5);
set(t,'ExecutionMode','fixedrate','StartDelay',0);
%make the timer set the flagChange parameter everytime it executes
set(t,'timerfcn','clk.flagChange = ~clk.flagChange;');
%start the timer
start(t);
