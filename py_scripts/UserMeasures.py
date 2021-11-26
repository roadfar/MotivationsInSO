# coding: UTF-8
import urllib2
import sys
import codecs
import csv
import json
import MySQLdb
import zlib
import gzip
import StringIO
import datetime
import numpy


class UserMeasures:

    def __init__(self, conn, cur):
        self.conn = conn
        self.cur = cur


    def get_qustions_answers(self):
        self.cur.execute("select UserId from RespondentMeasures")
        ids = self.cur.fetchall()
        for id in ids:
            self.cur.execute("select count(*) from Posts WHERE PostTypeId = 1 and OwnerUserId = '%s';" % id[0])
            q_count = self.cur.fetchone()
            self.cur.execute("select count(*) from Posts WHERE PostTypeId = 2 and OwnerUserId = '%s';" % id[0])
            a_count = self.cur.fetchone()
            self.cur.execute("select count(*) from Comments WHERE UserId = '%s';" % id[0])
            c_count = self.cur.fetchone()
            self.cur.execute(
                "update RespondentMeasures set nQuestions = '%s', nAnswers = '%s', nComments = '%s' where UserId = '%s'" % (
                    str(q_count[0]), str(a_count[0]), str(c_count[0]), str(id[0])))
            self.conn.commit()

    def get_avg_answer_response_time(self):
        self.cur.execute("select UserId from RespondentMeasures")
        ids = self.cur.fetchall()
        i = 1
        for id in ids:
            print i
            self.remote_cur.execute(
                "select CreationDate, ParentId from Posts where OwnerUserId = '%s' and PostTypeId = 2;" % id[0])
            parent_ids = self.remote_cur.fetchall()
            if len(parent_ids) > 0:
                avg_response_time = 0
                for parent_id in parent_ids:
                    self.remote_cur.execute(
                        "select TIMESTAMPDIFF(MINUTE, CreationDate, '%s') from Posts where id = '%s'" % (
                            parent_id[0], parent_id[1]))
                    response_time = self.remote_cur.fetchone()
                    avg_response_time = avg_response_time + response_time[0]
                self.cur.execute("update RespondentMeasures set avgAnswerResponseTime = '%s' where UserId = '%s';" % (
                    str(avg_response_time / len(parent_ids)), str(id[0])))
                self.conn.commit()
            i += 1

    def get_percAcceptedAnswer(self):
        self.cur.execute("select UserId, nAnswers from RespondentMeasures where nAnswers <> 0")
        ids = self.cur.fetchall()
        for id in ids:
            self.cur.execute("select id from Posts where OwnerUserId = '%s' and PostTypeId = 2;" % id[0])
            answer_ids = self.cur.fetchall()
            n_accepted_answer = 0
            for answer_id in answer_ids:
                self.cur.execute("select count(*) from Posts where AcceptedAnswerId = '%s' limit 1" % answer_id[0])
                count = self.cur.fetchone()
                if count[0] == 1:
                    n_accepted_answer += 1
            print n_accepted_answer
            self.cur.execute("update RespondentMeasures set percAcceptedAnswer = '%s' where UserId = '%s'" % (
                str(round(float(n_accepted_answer) / id[1], 3)), str(id[0])))
            self.conn.commit()

    def get_suggested_edits(self):
        self.cur.execute("select UserId from RespondentMeasures where nAnswers <> 0 and nQuestions <> 0")
        ids = self.cur.fetchall()
        ii = 0
        for id in ids:
            ii += 1
            print ii
            self.cur.execute("select id from Posts where OwnerUserId = '%s'" % id[0])
            post_ids = self.cur.fetchall()
            splited_posts = []
            loop = len(post_ids)/100
            mod = len(post_ids) % 100
            for i in range(loop):
                tmp = ""
                for index in range(100):
                    tmp = tmp + str(post_ids[index+i*100][0])+";"
                tmp = tmp[:-1]
                splited_posts.append(tmp)
            tmp_mod = ""
            for index in range(mod):
                tmp_mod = tmp_mod + str(post_ids[index+loop*100][0]) + ";"
            tmp_mod = tmp_mod[:-1]
            splited_posts.append(tmp_mod)
            for splited_post in splited_posts:
                print splited_post
                url = "https://api.stackexchange.com/2.2/suggested-edits/"+splited_post+"?site=stackoverflow&key=uKa70oh8UghY9o*DBa1u8A(("
                request_content = urllib2.Request(url)
                try:
                    author_url = urllib2.urlopen(request_content).read()
                    data = StringIO.StringIO(author_url)
                    gzipper = gzip.GzipFile(fileobj=data)
                    content = gzipper.read()
                    rhs = json.loads(content)
                    count = len(rhs['items'])
                    if count != 0:
                        print count
                except urllib2.URLError, e:
                    print e.reason
                    continue


    def get_question_answer_quality(self):
        self.cur.execute("select UserId from RespondentMeasures")
        ids = self.cur.fetchall()
        for id in ids:
            self.cur.execute("select round(AVG(Score),2) from Posts where OwnerUserId = '%s' and PostTypeId = 1" % id[0])
            qQuality = self.cur.fetchone()
            if qQuality[0] is not None:
                qQuality = qQuality[0]
                self.cur.execute(
                    "update RespondentMeasures set avgQuestionQuality = '%s' where UserId = '%s'" % (
                    qQuality, id[0]))
                self.conn.commit()
            self.cur.execute("select round(AVG(Score),2) from Posts where OwnerUserId = '%s' and PostTypeId = 2" % id[0])
            aQuality = self.cur.fetchone()
            if aQuality[0] is not None:
                aQuality = aQuality[0]
                self.cur.execute("update RespondentMeasures set avgAnswerQuality = '%s' where UserId = '%s'" % (aQuality,id[0]))
                self.conn.commit()


    def get_comment_score(self):
        self.cur.execute("select UserId from RespondentMeasures")
        ids = self.cur.fetchall()
        for id in ids:
            self.cur.execute("select round(AVG(Score),2) from Comments WHERE UserId = '%s'" % id[0])
            score = self.cur.fetchone()
            if score[0] is not None:
                self.cur.execute(
                    "update RespondentMeasures set avgCommentQuality = '%s' where UserId = '%s'" % (score[0], id[0]))
                self.conn.commit()



    def get_question_answer_quality_wilson(self):
        self.cur.execute("select UserId from RespondentMeasures")
        ids = self.cur.fetchall()
        for id in ids:
            self.cur.execute("select id from Posts where OwnerUserId = '%s' and PostTypeId = 1" % id[0])
            q_ids = self.cur.fetchall()
            if len(q_ids)>0:
                qQuality = 0
                for q_id in q_ids:
                    self.cur.execute("select count(*) from Votes v where v.PostId = '%s' and v.VoteTypeId = 2;" % q_id[0])
                    upvotes = self.cur.fetchone()
                    self.cur.execute("select count(*) from Votes v where v.PostId = '%s' and v.VoteTypeId = 3;" % q_id[0])
                    downvotes = self.cur.fetchone()
                    n = upvotes[0] + 1 + downvotes[0] + 1
                    p = round(float(upvotes[0] + 1) / n,2)
                    tempQuality = round((p + pow(1.96,2)/(2*n) - (1.96/(2*n))*pow((4*n*(1-p)*p+pow(1.96,2)),0.5))/(1+pow(1.96,2)/n),2)
                    qQuality = qQuality + tempQuality
                qQuality = round(qQuality/len(q_ids),2)
                self.cur.execute(
                    "update RespondentMeasures set avgQuestionQuality = '%s' where UserId = '%s'" % (qQuality, id[0]))
                self.conn.commit()
            self.cur.execute("select id from Posts where OwnerUserId = '%s' and PostTypeId = 2" % id[0])
            a_ids = self.cur.fetchall()
            if len(a_ids) > 0:
                aQuality = 0
                for a_id in a_ids:
                    self.cur.execute("select count(*) from Votes v where v.PostId = '%s' and v.VoteTypeId = 2;" % a_id[0])
                    upvotes = self.cur.fetchone()
                    self.cur.execute("select count(*) from Votes v where v.PostId = '%s' and v.VoteTypeId = 3;" % a_id[0])
                    downvotes = self.cur.fetchone()
                    n = upvotes[0] + 1 + downvotes[0] + 1
                    p = round(float(upvotes[0] + 1) / n,2)
                    tempQuality = round((p + pow(1.96,2)/(2*n) - (1.96/(2*n))*pow((4*n*(1-p)*p+pow(1.96,2)),0.5))/(1+pow(1.96,2)/n),2)
                    aQuality = aQuality + tempQuality
                aQuality = round(aQuality/len(a_ids),2)
                self.cur.execute("update RespondentMeasures set avgAnswerQuality = '%s' where UserId = '%s'" % (aQuality,id[0]))
                self.conn.commit()

    def create_cl_sankey_data(self):
        self.cur.execute("select id,NodeName from nodes_map where tag = 'Role';")
        roles = self.cur.fetchall()
        self.cur.execute("select id,NodeName from nodes_map where tag = 'Theme';")
        themes = self.cur.fetchall()
        self.cur.execute("select id,NodeName from nodes_map where tag = 'Challenge';")
        challenges = self.cur.fetchall()
        for role in roles:
            for theme in themes:
                self.cur.execute("select count(*) from Challenges where role = '%s' and theme = '%s'" % (role[1],theme[1]))
                count = self.cur.fetchone()
                self.cur.execute("select NodeName from nodes_map WHERE id ='%s';" % str(role[0]))
                link_group = self.cur.fetchone()
                self.cur.execute("insert into SankeyData(source, target, value, linkGroup) VALUES ('%s','%s','%s','%s');" % (str(role[0]),str(theme[0]),str(count[0]),link_group[0]))
                self.conn.commit()
        for theme in themes:
            for challenge in challenges:
                self.cur.execute("select count(*) from Challenges where theme = '%s' and challenge = '%s'" % (theme[1],challenge[1]))
                count = self.cur.fetchone()
                self.cur.execute("select NodeName from nodes_map WHERE id ='%s';" % str(theme[0]))
                link_group = self.cur.fetchone()
                self.cur.execute("insert into SankeyData(source, target, value, linkGroup) VALUES ('%s','%s','%s','%s');" % (str(theme[0]),str(challenge[0]),str(count[0]),str(link_group[0])))
                self.conn.commit()