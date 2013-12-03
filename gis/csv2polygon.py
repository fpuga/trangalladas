#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2013 Francisco Puga
# Developed at Cartolab http://cartolab.es
# GPL v3

import csv
import os, sys
from itertools import islice
from shapely.geometry import Polygon, mapping, shape
from fiona import collection
from fiona.crs import from_epsg

class csv2polygon:
    def __init__(self, csv_file_path):
        self.csv_file_path = csv_file_path
        self.filename = os.path.splitext(os.path.basename(csv_file_path))
        self.shp_file_path = os.path.splitext(self.csv_file_path)[0] + '.shp'
        self.epsg=25829

    def convert(self):
        schema = { 'geometry': 'Polygon', 'properties': { 'id': 'int', 'tipo':'str' } }
        with collection(
            self.shp_file_path, "w", driver="ESRI Shapefile", crs=from_epsg(self.epsg), schema=schema) as output:
            with open(self.csv_file_path, 'rb') as f:
                reader = csv.reader(f)
                bad_rows = []
                for row in islice(reader, 1, None):
                    point_list = [(float(row[i]), float(row[i+1])) for i in range(1, len(row)-1, 2) if row[i] and row[i+1] and float(row[i]) and float(row[i+1])]
                    if len(point_list) > 2:
                        polygon = Polygon(point_list)
                        output.write({
                                'properties': {
                                    'id': row[0],
                                    'tipo': self.filename[0]
                                    },
                                'geometry': mapping(polygon)
                                })
                    else:
                        bad_rows.append(row[0])
        print bad_rows

if __name__ == "__main__":
    a = csv2polygon(sys.argv[1])
    a.convert()
