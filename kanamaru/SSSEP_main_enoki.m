clear all 
close all
clc

subname = input('Type subject name > ', 's');
condition = input('Type condition > ', 's');
    
rectime = 20;
LFHF(subname , condition, rectime);