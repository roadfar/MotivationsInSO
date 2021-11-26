# coding: UTF-8
import urllib2
import sys
import codecs
import csv
import json
import MySQLdb
import zlib

import datetime


class Users:
    def __init__(self, conn, cur):
        self.conn = conn
        self.cur = cur

    def get_user_answers(self):
        self.cur.execute("select id from Users where AnswerCount is NULL order by reputation desc limit 5000")
        user_ids = self.cur.fetchall()
        i = 1
        for user_id in user_ids:
            print i
            self.cur.execute("select count(*) from Posts where OwnerUserId = '%s' and ViewCount is NULL" % user_id[0])
            answer_count = self.cur.fetchone()
            self.cur.execute("update Users set AnswerCount = '%s' where id = '%s';" % (answer_count[0], user_id[0]))
            self.conn.commit()
            i += 1


    def input_github_account(self):
        with open(
                "****") as seed:
            reader = csv.reader(seed)
            next(reader, None)
            for line in reader:
                if line[1] != "":
                    self.cur.execute(
                        "update Users set GitHubAccount = '%s', is_verified = '%s', auto_id = '%s' where id ='%s';" % (
                            line[1], "0", line[2], line[0]))
                    self.conn.commit()

    def update_user_email_by_ghaccount(self):
        # max id: 1276814
        self.cur.execute("select id,GitHubAccount from Users WHERE is_verified = 0;")
        ghs = self.cur.fetchall()
        print len(ghs)
        for j in range(0, len(ghs)):
            print j
            url = "https://api.github.com/users/%s?access_token=******" % str(
                ghs[j][1])
            request_content = urllib2.Request(url)
            try:
                author_url = urllib2.urlopen(request_content).read()
            except urllib2.URLError, e:
                print e.reason
                continue
            if author_url != "[]":
                author_json = json.loads(author_url)
                email = author_json['email']
                if email is not None:
                    try:
                        self.cur.execute("update Users set Email = '%s' where id = '%s';" % (email, ghs[j][0]))
                        self.conn.commit()
                    except MySQLdb.Error, e:
                        print "Mysql Error!", e;

    def update_sankeydata(self):

        nodes = []
        # Female:1, Male:2, Full-time open source developer: 3, Company employee: 4, Self-employed: 5, Researcher: 6,
        # Student: 7, Unemployed: 8, Other (please specify): 9, <1 year: 10, 1~5 years: 11, 6~10 years: 12, >10 years: 13, Never:14, Rarely: 15, Sometimes: 16, Usually: 17, Always: 18

        self.cur.execute(
            "select count(*) from SurveyAnswers where Gender = 'Female' and Occupation = 'Full-time open source developer';")
        n = self.cur.fetchone()
        nodes.append({"source": 1, "target": 3, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where Gender = 'Female' and Occupation = 'Company employee';")
        n = self.cur.fetchone()
        nodes.append({"source": 1, "target": 4, "value": n[0]})
        self.cur.execute("select count(*) from SurveyAnswers where Gender = 'Female' and Occupation = 'Self-employed';")
        n = self.cur.fetchone()
        nodes.append({"source": 1, "target": 5, "value": n[0]})
        self.cur.execute("select count(*) from SurveyAnswers where Gender = 'Female' and Occupation = 'Researcher';")
        n = self.cur.fetchone()
        nodes.append({"source": 1, "target": 6, "value": n[0]})
        self.cur.execute("select count(*) from SurveyAnswers where Gender = 'Female' and Occupation = 'Student';")
        n = self.cur.fetchone()
        nodes.append({"source": 1, "target": 7, "value": n[0]})
        self.cur.execute("select count(*) from SurveyAnswers where Gender = 'Female' and Occupation = 'Unemployed';")
        n = self.cur.fetchone()
        nodes.append({"source": 1, "target": 8, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where Gender = 'Female' and Occupation = 'Other (please specify)';")
        n = self.cur.fetchone()
        nodes.append({"source": 1, "target": 9, "value": n[0]})

        self.cur.execute(
            "select count(*) from SurveyAnswers where Gender = 'Male' and Occupation = 'Full-time open source developer';")
        n = self.cur.fetchone()
        nodes.append({"source": 2, "target": 3, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where Gender = 'Male' and Occupation = 'Company employee';")
        n = self.cur.fetchone()
        nodes.append({"source": 2, "target": 4, "value": n[0]})
        self.cur.execute("select count(*) from SurveyAnswers where Gender = 'Male' and Occupation = 'Self-employed';")
        n = self.cur.fetchone()
        nodes.append({"source": 2, "target": 5, "value": n[0]})
        self.cur.execute("select count(*) from SurveyAnswers where Gender = 'Male' and Occupation = 'Researcher';")
        n = self.cur.fetchone()
        nodes.append({"source": 2, "target": 6, "value": n[0]})
        self.cur.execute("select count(*) from SurveyAnswers where Gender = 'Male' and Occupation = 'Student';")
        n = self.cur.fetchone()
        nodes.append({"source": 2, "target": 7, "value": n[0]})
        self.cur.execute("select count(*) from SurveyAnswers where Gender = 'Male' and Occupation = 'Unemployed';")
        n = self.cur.fetchone()
        nodes.append({"source": 2, "target": 8, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where Gender = 'Male' and Occupation = 'Other (please specify)';")
        n = self.cur.fetchone()
        nodes.append({"source": 2, "target": 9, "value": n[0]})

        # occupation -> development experience
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and Occupation = 'Full-time open source developer';")
        n = self.cur.fetchone()
        nodes.append({"source": 3, "target": 10, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and Occupation = 'Company employee';")
        n = self.cur.fetchone()
        nodes.append({"source": 4, "target": 10, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and Occupation = 'Self-employed';")
        n = self.cur.fetchone()
        nodes.append({"source": 5, "target": 10, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and Occupation = 'Researcher';")
        n = self.cur.fetchone()
        nodes.append({"source": 6, "target": 10, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and Occupation = 'Student';")
        n = self.cur.fetchone()
        nodes.append({"source": 7, "target": 10, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and Occupation = 'Unemployed';")
        n = self.cur.fetchone()
        nodes.append({"source": 8, "target": 10, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and Occupation = 'Other (please specify)';")
        n = self.cur.fetchone()
        nodes.append({"source": 9, "target": 10, "value": n[0]})

        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and Occupation = 'Full-time open source developer';")
        n = self.cur.fetchone()
        nodes.append({"source": 3, "target": 11, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and Occupation = 'Company employee';")
        n = self.cur.fetchone()
        nodes.append({"source": 4, "target": 11, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and Occupation = 'Self-employed';")
        n = self.cur.fetchone()
        nodes.append({"source": 5, "target": 11, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and Occupation = 'Researcher';")
        n = self.cur.fetchone()
        nodes.append({"source": 6, "target": 11, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and Occupation = 'Student';")
        n = self.cur.fetchone()
        nodes.append({"source": 7, "target": 11, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and Occupation = 'Unemployed';")
        n = self.cur.fetchone()
        nodes.append({"source": 8, "target": 11, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and Occupation = 'Other (please specify)';")
        n = self.cur.fetchone()
        nodes.append({"source": 9, "target": 11, "value": n[0]})

        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and Occupation = 'Full-time open source developer';")
        n = self.cur.fetchone()
        nodes.append({"source": 3, "target": 12, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and Occupation = 'Company employee';")
        n = self.cur.fetchone()
        nodes.append({"source": 4, "target": 12, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and Occupation = 'Self-employed';")
        n = self.cur.fetchone()
        nodes.append({"source": 5, "target": 12, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and Occupation = 'Researcher';")
        n = self.cur.fetchone()
        nodes.append({"source": 6, "target": 12, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and Occupation = 'Student';")
        n = self.cur.fetchone()
        nodes.append({"source": 7, "target": 12, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and Occupation = 'Unemployed';")
        n = self.cur.fetchone()
        nodes.append({"source": 8, "target": 12, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and Occupation = 'Other (please specify)';")
        n = self.cur.fetchone()
        nodes.append({"source": 9, "target": 12, "value": n[0]})

        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and Occupation = 'Full-time open source developer';")
        n = self.cur.fetchone()
        nodes.append({"source": 3, "target": 13, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and Occupation = 'Company employee';")
        n = self.cur.fetchone()
        nodes.append({"source": 4, "target": 13, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and Occupation = 'Self-employed';")
        n = self.cur.fetchone()
        nodes.append({"source": 5, "target": 13, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and Occupation = 'Researcher';")
        n = self.cur.fetchone()
        nodes.append({"source": 6, "target": 13, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and Occupation = 'Student';")
        n = self.cur.fetchone()
        nodes.append({"source": 7, "target": 13, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and Occupation = 'Unemployed';")
        n = self.cur.fetchone()
        nodes.append({"source": 8, "target": 13, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and Occupation = 'Other (please specify)';")
        n = self.cur.fetchone()
        nodes.append({"source": 9, "target": 13, "value": n[0]})

        # OSS contribution   <1 year: 10, 1~5 years: 11, 6~10 years: 12, >10 years: 13, Never:14, Rarely: 15, Sometimes: 16, Usually: 17, Always: 18
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and OSSParticipation = 'Never';")
        n = self.cur.fetchone()
        nodes.append({"source": 13, "target": 14, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and OSSParticipation = 'Rarely';")
        n = self.cur.fetchone()
        nodes.append({"source": 13, "target": 15, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and OSSParticipation = 'Sometimes';")
        n = self.cur.fetchone()
        nodes.append({"source": 13, "target": 16, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and OSSParticipation = 'Usually';")
        n = self.cur.fetchone()
        nodes.append({"source": 13, "target": 17, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '>10 years' and OSSParticipation = 'Always';")
        n = self.cur.fetchone()
        nodes.append({"source": 13, "target": 18, "value": n[0]})

        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and OSSParticipation = 'Never';")
        n = self.cur.fetchone()
        nodes.append({"source": 12, "target": 14, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and OSSParticipation = 'Rarely';")
        n = self.cur.fetchone()
        nodes.append({"source": 12, "target": 15, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and OSSParticipation = 'Sometimes';")
        n = self.cur.fetchone()
        nodes.append({"source": 12, "target": 16, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and OSSParticipation = 'Usually';")
        n = self.cur.fetchone()
        nodes.append({"source": 12, "target": 17, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '6~10 years' and OSSParticipation = 'Always';")
        n = self.cur.fetchone()
        nodes.append({"source": 12, "target": 18, "value": n[0]})

        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and OSSParticipation = 'Never';")
        n = self.cur.fetchone()
        nodes.append({"source": 11, "target": 14, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and OSSParticipation = 'Rarely';")
        n = self.cur.fetchone()
        nodes.append({"source": 11, "target": 15, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and OSSParticipation = 'Sometimes';")
        n = self.cur.fetchone()
        nodes.append({"source": 11, "target": 16, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and OSSParticipation = 'Usually';")
        n = self.cur.fetchone()
        nodes.append({"source": 11, "target": 17, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '1~5 years' and OSSParticipation = 'Always';")
        n = self.cur.fetchone()
        nodes.append({"source": 11, "target": 18, "value": n[0]})

        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and OSSParticipation = 'Never';")
        n = self.cur.fetchone()
        nodes.append({"source": 10, "target": 14, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and OSSParticipation = 'Rarely';")
        n = self.cur.fetchone()
        nodes.append({"source": 10, "target": 15, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and OSSParticipation = 'Sometimes';")
        n = self.cur.fetchone()
        nodes.append({"source": 10, "target": 16, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and OSSParticipation = 'Usually';")
        n = self.cur.fetchone()
        nodes.append({"source": 10, "target": 17, "value": n[0]})
        self.cur.execute(
            "select count(*) from SurveyAnswers where DevelopmentExp = '<1 year' and OSSParticipation = 'Always';")
        n = self.cur.fetchone()
        nodes.append({"source": 10, "target": 18, "value": n[0]})

        for node in nodes:
            self.cur.execute("insert into SankeyData (source,target,value) values ('%d','%d','%d')" % (
                node["source"], node["target"], node["value"]))
            self.conn.commit()


    def update_age_sankey(self):
        ages = ["35-44","25-34","45-54","18-24","65+","55-64"]
        motives = ["ExternalMotivation", "IntrojectedMotivation", "IdentifiedMotivation", "IntegratedMotivation","IntrinsicMotivation"]
        for i in range(0,7):
            for j in range(0,6):
                self.cur.execute("select count(*) from FormalSankeyResults where Age = '%s' and")

    def exclude_user(self):
        writer = csv.writer(
            file('******', 'wb'))
        writer.writerow(['id'])
        with open("******") as seed:
            reader = csv.reader(seed)
            next(reader, None)
            i = 1
            for line in reader:
                print i
                self.cur.execute("select * from ly WHERE id = '%s' limit 1;" % line[0])
                count = self.cur.fetchall()
                if len(count) == 0:
                    writer.writerow([line[0]])
                i += 1
