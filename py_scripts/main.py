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
    # re_conn = MySQLdb.connect(host='10.107.10.110', user='root', passwd='******', db='stackoverflow2018')
    # re_cur = re_conn.cursor()
    # mRanking = Reputation_rankings(conn,cur)
    # mRanking.get_reputation_by_week(292)

    # m_user_answer = Users(conn, cur)
    # m_user_answer.update_user_email_by_ghaccount()

    # m_user_answer = UserMeasures(conn, cur, re_conn, re_cur)
    # m_user_answer.get_percAcceptedAnswer()

    local_user_measure = UserMeasures(conn, cur)
    local_user_measure.create_cl_sankey_data()
