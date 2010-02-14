#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# translatePO.py
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
# Francisco Puga Alonso <fpuga@cartolab.es> <http://conocimientoabierto.es>
#
# KEYWORDS: python, i18n, odt, odf, po, translate, opentran
#
# DEPENDENCIES: beautifulsoup <http://www.crummy.com/software/BeautifulSoup/>, polib <http://bitbucket.org/izi/polib/>
#

def description():
    """
    This script takes a .po file as parameter and the translate it from galician to spanish or spanish to galician using the opentrad-apertium web
    provided by Vigo University
    """

# CHANGELOG:
#  19/10/2009. Creation
#  27/10/2009. Solved encoding issues
#
# TODO:
# + allow write results to a file
# + allow multiple consults in one invocation of the script
# + add more translation motors and translate directions
# + handled the UnicodeEncondeError to make a partial translation
# + How to avoid the translation of the url placed in the text and other special characters
# + Script fails when there are < in the text. Maybe we can write to the web services asking for parse that kind of symbols
# + Give the user the option of pass to opentran "mark not recognaise strings" and then parse the text removing the * and making ourshelves this strings as fuzzy


# MANUAL
# Actualemente se marcan como fuzzy aquellas cadenas que non han sido traducidas automáticamente por algún motivo (generalmente algún problema de enconding, por ejemplo al usar comillas tipográficas). Esto permite localizar rapidamente las cadenas que sabemos a ciencia cierta que están mal. Téngase en cuenta de todas formas que una traducción automática dista mucho de ser perfecta, y en general todas las cadenas requerirían de una revisión.



import sys, getopt, codecs

import urllib, urllib2
from BeautifulSoup import BeautifulSoup

import polib



def usage(msg):
    print description.__doc__
    print '\nUsage: python %s -i input-file [-d direction] [-m]' % (sys.argv[0])
    print '-i input-file: The po that is going to be translated'
    print '-d direction: Translation directory. Default gl-es. Allowed gl-es, es-gl'
    print '-m: Mark the strings where exists a word that opentrand dont understand as fuzzy\n'
    sys.exit(msg)


def getIt(c, p, query):

    # service just admits parameters of the url coded in latin1
    for i in query:
        query[i]=unicode(query[i], 'utf8').encode('iso8859-1')

    page = urllib2.urlopen(url,urllib.urlencode(query))
    soup = BeautifulStoneSoup(page)


def main(argv):

    marcar = False

    url = 'http://sli.uvigo.es/tradutor/tradtext.php'
    query = {'direccion':'gl-es', 'marcar':'', 'cuadrotexto':''}

    try:
        opts, args = getopt.getopt(argv, "hmi:d:", ["help", "--mark", "--input-file=", "--direction="])
    except getopt.GetoptError:
        usage("\nError: Probably you tipe some argumet that is not in the list of expected arguments")
x
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage(None)
        elif opt in ('-m', '--mark'):
            marcar = True
        elif opt in ('-i', '--input-file'):
            try:
                po = polib.pofile(arg)
            except IOError:
                print "\n\tA problem was encountered opening de file, probably it doesn't exist\n"
                sys.exit()
        elif opt in ('-d', '--direction'):
            # TODO: + allow more directions.
            #       + not hard coded the directions here
            if arg in ('gl-es','es-gl'):
                query['direccion':arg]
            else:
                usage('Translate direction incorrect')

        else:
            usage('\nError: ' + opt + 'is not a valid argument')


    for entry in po:
        print entry.msgid

        try:
            query['cuadrotexto'] = entry.msgid.encode('iso8859-1')
        except UnicodeEncodeError:
            print "Encoding error in msgid. You should check this string."
        else:
            page = urllib2.urlopen(url,urllib.urlencode(query))
            contenedor = BeautifulSoup(page).find('div', id="contenedor").string
            entry.msgstr = contenedor
            print contenedor

        i += 1
        if i == 5:
            sys.exit()

    po.save()




if __name__ == "__main__":
    # Python use ascii and encoding by default if we pipe the out, this solved it.
    #sys.stdout = codecs.getwriter('utf8')(sys.stdout)
    main(sys.argv[1:])
