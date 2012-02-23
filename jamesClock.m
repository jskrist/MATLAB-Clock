a = digiClock;

set(gcf,'doublebuffer','on');
set(gcf, 'closerequestfcn','stop(t);delete(t);delete(gcf)');
set(gcf, 'menubar','none', 'WindowStyle', 'docked');

%Build Timer object and turn on timer
%delay for 1/2 second so rest of setup finishes
t = timer('period',0.5);
set(t,'ExecutionMode','fixedrate','StartDelay',0);
set(t,'timerfcn','a.flagChange = ~a.flagChange;');
start(t);
