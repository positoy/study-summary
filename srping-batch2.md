1. 배치?

   - 배치 : 사용자와 상호작용 없이 동작하는 명령
   - 실행

     ```bash
     java -jar \
     -Dspring.profiles.active=beta \
     ${BATCH_JAR_HOME}/settler-batch.jar \
     --job.name=adAccruedBatch \
     baseDate=${baseDate} \
     version=${VERSION} \
     ```

   

2. 스프링배치

   - 대용량 데이터를 처리하기 위해 chunk 와 job repository 를 지원
   - 대용량을 처리하기 위한 chunk
   - 실패한 시점부터 재개하기 위한 job repository
   - 추상화

   

3. 사용예

   - 톡톡으로 메시지를 발송하는 사용자가 얼마나 되지? (DAU, WAU, MAU 집계)

   - 마케팅메시지를 활용하는 스토어가 얼마나 되지? (월말 Monthly Active 파트너 집계)

     

4. 용어

   - Job, Step, Reader, Processor, Writer

   - Job Launcher, Job Repository

   - Job Instance (with Job Parameters), Job Execution (with Execution Parameters)

     ![Figure 2.1: Batch Stereotypes](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/spring-batch-reference-model.png)

     ![Job Parameters](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/job-stereotypes-parameters.png)

     ![image-20210113190341701](/Users/positoy/Library/Application Support/typora-user-images/image-20210113190341701.png)




5. 구현

6. 더 알아보기

   - XML, Tasklet
   - 다양한 구현체

   

7. 관리도구

   - Cron
   - Spring MVC + API Call
   - Spring Batch Admin
     (deprecated → Spring Cloud Data Flow )
   - Quartz + Admin
   - CI tools (Jenkins, Teacity)

8. 기본편 

   - Job

     - Step (ChunkOrientedTasklet)
       - reader
       - processor
       - Writer

     ![image-20210117110257734](/Users/positoy/Library/Application Support/typora-user-images/image-20210117110257734.png)

9. 활용편

   - JobParameter

     - Long, String, Double, Date 만 사용 가능
     - Tasklet 에서 사용시

   - ![image-20210117110638056](/Users/positoy/Library/Application Support/typora-user-images/image-20210117110638056.png)

     - Job 에서 사용시

       ![image-20210117110722485](/Users/positoy/Library/Application Support/typora-user-images/image-20210117110722485.png)

- 