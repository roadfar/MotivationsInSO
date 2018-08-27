# coding: UTF-8
import urllib2
import sys
import codecs
import csv
import json
import MySQLdb

conn = MySQLdb.connect(host='127.0.0.1', user='root', passwd='******', db='StackOverflowDump')
cur = conn.cursor()
writer = csv.writer(
    file('/root/remain.csv', 'wb'))
writer.writerow(['id'])
with open("/root/users.csv") as seed:
    reader = csv.reader(seed)
    next(reader, None)
    i = 1
    for line in reader:
        print i
        cur.execute("select * from ly WHERE id = '%s' limit 1;" % line[0])
        count = cur.fetchall()
        if len(count) == 0:
            writer.writerow([line[0]])
        i += 1