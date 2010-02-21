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
# Francisco Puga Alonso <fran.puga@gmail.com> <http://conocimientoabierto.es>
#
# KEYWORDS: python, i18n, po, translate, opentran
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
#  21/02/2010. Added a way to handle more translation services
#
# TODO:
# + allow write results to a file
# + allow multiple consults in one invocation of the script
# + How to load the engines
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



#######################
# Engine definitions  #
#######################

class AbstractEngine:
    """ Abstract class to define how must be the translation engines"""

    url = ''
    validTranslateDirs = ''
    # translateDir = ''
    query = {'direccion':'', 'marcar':'', 'cuadrotexto':''}


    def isValidTranslationDir(self, translationDir):
        return translationDir in self.validDirs


    def setQuery(self, translationDir, mark):
        error = False
        self.query['marcar'] = mark
        if self.isValidTranslationDir(translationDir):
            self.query['direccion'] = translationDir
            error = True

        return error

    def setTextToTranslate(self, text):
        error = False
        try:
            self.query['cuadrotexto'] = text.encode('iso8859-1')
        except UnicodeEncodeError:
            print "Encoding error in msgid. You should check this string."
            error = True

        return error


    def parsePage(self, page):
        pass


class UvigoEngine(AbstractEngine):

    def __init__(self):
        self.url = 'http://sli.uvigo.es/tradutor/tradtext.php'
        self.validDirs = ('gl-es', 'es-gl')

    def parsePage(self, page):
        return BeautifulSoup(page).find('div', id="contenedor").string


class ImaxinEngine(AbstractEngine):

    def __init__(self):
        self.url = 'http://www.opentrad.com/gl/opentrad/traducir'
        self.validDirs = ("es-en","en-es","es-pt","pt-es","fr-es","es-fr","es-ca","ca-es","en-ca","ca-en","es-eu","es-gl","gl-es","en-gl","gl-en","pt-gl","gl-pt","es-en_US","pt-ca","ca-pt","es-pt_BR","es-ca_valencia","es-ast","ast-es","fr-ca","ca-fr","br-fr","es-ro","ro-es","cy-en","en-eo","es-eo","ca-eo","nn-nb","nb-nn","oc-ca","ca-oc","oc-es","es-oc")

    def parsePage(self, page):
        text = page.read()
        i = text.find('<script')
        return text[:i]




def usage(msg):
    print description.__doc__
    print '\nUsage: python %s -i input-file [-d direction] [-m]' % (sys.argv[0])
    print '-i input-file: The po that is going to be translated'
    print '-d direction: Translation directory. Default gl-es. Allowed gl-es, es-gl'
    print '-m: Mark the strings where exists a word that opentrand dont understand as fuzzy'
    print '-e: Engine. Valid engines are "ImaxinEngine" and "UvigoEngine"\n'
    sys.exit(msg)



def getIt(c, p, query):

    # service just admits parameters of the url coded in latin1
    for i in query:
        query[i]=unicode(query[i], 'utf8').encode('iso8859-1')

    page = urllib2.urlopen(url,urllib.urlencode(query))
    soup = BeautifulStoneSoup(page)


def getEngine(engine):
    """
    A translation engine is define by its name, its url, its valid directions, and the way it must be parsed. To add a new engine you must add here some parameters and create a new function to parse de engine
    """
    validEngine = True
    if engine['name'] == 'uvigo':
        engine['url'] = 'http://sli.uvigo.es/tradutor/tradtext.php'
        engine['dir'] = ('gl-es', 'es-gl')
    elif engine['name'] == 'imaxin':
        engine['url']= 'http://www.opentrad.com/gl/opentrad/traducir'
        engine['dir'] = ("es-en","en-es","es-pt","pt-es","fr-es","es-fr","es-ca","ca-es","en-ca","ca-en","es-eu","es-gl","gl-es","en-gl","gl-en","pt-gl","gl-pt","es-en_US","pt-ca","ca-pt","es-pt_BR","es-ca_valencia","es-ast","ast-es","fr-ca","ca-fr","br-fr","es-ro","ro-es","cy-en","en-eo","es-eo","ca-eo","nn-nb","nb-nn","oc-ca","ca-oc","oc-es","es-oc")
    else:
        validEngine = False

    return validEngine


def main(argv):


    # tmp variables to parse input arguments and set defaults values
    engineName = 'ImaxinEngine'
    translationDir = ''
    mark = False

    try:
        opts, args = getopt.getopt(argv, "hmi:d:e:", ["help", "--mark", "--input-file=", "--direction=", "--engine="])
    except getopt.GetoptError:
        usage("\nError: Probably you tipe some argumet that is not in the list of expected arguments")

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage(None)
        elif opt in ('-m', '--mark'):
            mark = True
        elif opt in ('-i', '--input-file'):
            try:
                po = polib.pofile(arg)
            except IOError:
                print "\n\tA problem was encountered opening de file, probably it doesn't exist\n"
                sys.exit()
        elif opt in ('-d', '--direction'):
            translationDir = arg
        elif opt in ('-e', '--engine'):
            engineName = arg
        else:
            usage('\nError: ' + opt + 'is not a valid argument')

    # load the engine, and its configuration params
    try:
        engine = globals()[engineName]()
    except KeyError:
        print engineName + 'is not a valid engine'
        sys.exit()

    if not engine.setQuery (translationDir, mark):
        print 'Translation direction is not valid for this engine'
        sys.exit()

    for entry in po:
        print entry.msgid
        engine.setTextToTranslate(entry.msgid)
        page = urllib2.urlopen(engine.url,urllib.urlencode(engine.query))
        entry.msgstr = engine.parsePage(page)
        print entry.msgstr


    po.save()




if __name__ == "__main__":
    # Python use ascii and encoding by default if we pipe the out, this solved it.
    #sys.stdout = codecs.getwriter('utf8')(sys.stdout)
    main(sys.argv[1:])
