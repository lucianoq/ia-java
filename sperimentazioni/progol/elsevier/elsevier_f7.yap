#!/usr/local/bin/yap -L --
#
# .
:- consult('../progol.pl').
:- read_all('elsevier_f7').
:- induce.
:- write_rules('elsevier_f7.rul').

