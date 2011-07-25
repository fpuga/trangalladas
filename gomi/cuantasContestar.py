#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# cuantasContestar.py v.10
#
# Copyright (C) 2009 Francisco Puga Alonso
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# AUTHORS:
# Francisco Puga Alonso <fran.puga@gmail.com> <http://conocimientoabierto.es>
#
# KEYWORDS: python, test, examen
#
# DEPENDENCIES: None
#
def description():
    """
    Prints the number of mistakes that you can make in a test
    """

# CHANGELOG:
#  06/11/2009. Creation
#
# TODO | KNOWN ISSUES
# allow write results to a file


import sys, getopt


def usage(msg):
    print description.__doc__
    print '\nUsage: python %s [-m minimun_puntuation] -t total [-c] [-l mistakes] ' % (sys.argv[0])
    print '-m minimun_puntuation: The minimun puntuation that you must reach to pass the test. By default 50% of total'
    print '-t total: total number of questions of the test'
    print '-c: use csv format for the output'
    print '-l mistakes: Number of points substracted for each mistake. Default 1\n'
    sys.exit(msg)


def main(argv):

    cutPuntuation = total = 0
    substractMistakes = 1
    csv = False


    try:
       opts, args = getopt.getopt(argv, "h,c,m:t:l:")
    except getopt.GetoptError:
        usage("\nError: Probably you tipe some argumet that is not in the list of expected arguments")

    for opt, arg in opts:
        if opt in ('-h'):
            usage(None)
        elif opt == '-m':
            cutPuntuation = int(arg)
        elif opt == '-t':
            total = int(arg)
            if cutPuntuation == 0:
                cutPuntuation = total / 2
        elif opt == '-l':
            substractMistakes = float(arg)
        elif opt == '-c':
            csv = True
        else:
            usage('\nError:' + opt + 'is not a valid argument')

    if total == 0:
        usage("Total number of question must be specified")

    if (csv):
        print ("# Contestadas;#Fallos Permitidos")


    for i in range (cutPuntuation, total+1):
        for j in range (0,cutPuntuation):
            if i-j-j*substractMistakes < cutPuntuation:

                if (csv):
                    print str(i) + ';' + str(j-1)
                else:
                    print str(i) + " contestadas, máximo " + str(j-1) + " fallos"
                break





if __name__ == "__main__":
    main(sys.argv[1:])
