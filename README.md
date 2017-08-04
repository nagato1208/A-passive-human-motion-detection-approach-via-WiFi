# my-csi-tools

log_to_file1.0.c
Changed the original log_to_file.c to only write one package for a file(by automatically reset the file pointer to the start of the file), also modified the buffer, to prevent the emergence of reading empty data package.

real-time monitor1.0.m
A very simple realization of real-time monitoring of the CSI signals. By loop of reading an updating data file(contains one data package only so it won't cost more time as PING process goes by), and at any time there are only 10 curves for each receiver antenna.
When the CSI system or wifi condition is changed by people working by, the changes of CSI dB-level curves can easily be observed.



