import pyspark
import sys

#Submitted by Devansh Sanghvi, BE19B002

if len(sys.argv) != 3:
  raise Exception("Exactly 2 arguments are required: <input_url> <output_url>")

input_url=sys.argv[1]
output_url=sys.argv[2]

def get_click_time(line):
    time = line.split(",")[1]
    hour = time.split(":")[0]
    hour_num = int(hour)
    if hour_num>=0 and hour_num<=5:
        return '0-6'
    elif hour_num>=6 and hour_num<=11:
        return '6-12'
    elif hour_num>=12 and hour_num<=17:
        return '12-18'
    else:
        return '18-24'



sc = pyspark.SparkContext()
lines = sc.textFile(sys.argv[1])
head = lines.first()
lines = lines.filter(lambda x: x!=head)
words = lines.map(lambda line: get_click_time(line))
clickCounts = words.map(lambda word: (word, 1)).reduceByKey(lambda count1, count2: count1 + count2)
clickCounts.saveAsTextFile(sys.argv[2])



