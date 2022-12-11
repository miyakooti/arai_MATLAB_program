clear all 
close all
clc

subname = input('Type subject name > ', 's');
condition = input('Type condition > ', 's');

rectime = 4.4;
PolymateMini_SSSEP_8ch_exam(subname , condition, rectime);