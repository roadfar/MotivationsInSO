# coding: UTF-8

import urllib2
import sys
import codecs
import json
import MySQLdb
from UserMeasures import UserMeasures


if __name__ == '__main__':
    conn = MySQLdb.connect(host='127.0.0.1', user='root', passwd='******', db='crowdsourced_learning')
    cur = conn.cursor()

    # m_user_answer = Users(conn, cur)
    # m_user_answer.update_user_email_by_ghaccount()

    # m_user_answer = UserMeasures(conn, cur, re_conn, re_cur)
    # m_user_answer.get_percAcceptedAnswer()

    local_user_measure = UserMeasures(conn, cur)
    local_user_measure.create_cl_sankey_data()
