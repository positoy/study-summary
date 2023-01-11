# strings

```
# given.txt
2022-12-31 22:08:11,264  ERROR [com.naver.talk.marketing.batch.job.point.runnable.MonthlyConsumerRunnable:checkFriendSyncIssue:129] - $$$ 알림받기 동기화 에러 확인필요 : 계정(w4581x6) 친구수 101, 스스채널([101756477, 101781009]) Max 친구수 102

# filter 1st field
cat given.txt | cut -d' ' -f1
cat given.txt | awk '{print $1}'
awk '{print $1}' given.txt

```
