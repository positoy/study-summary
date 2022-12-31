# Spring Batch



### 배치

사용자 인터랙션 없이 진행하는 프로그램



### 문제점 → 대용량, 재시작, 복잡성 등..

예 ) 마케팅메시지 전송

- 재시작 : 중간에 전원이 차단되면 어떡하지?
- 대용량 : DB에서 메시지를 얼마큼씩 읽어 보내야하지?
- 복잡성 : 마케팅메시지를 발송하고 파트너에게 보고서를 보내줘야 한다면?
- 에러처리 : 메시지 데이터의 json이 유효하지 않으면 어떡하지?



### 스프링배치

![Figure 2.1: Batch Stereotypes](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/spring-batch-reference-model.png)

- 추상화를 통해서 문제 해결
  - 재시작 : JobRepository 에 작업내용을 저장하고 실패한 Job 은 다시 시도 할 수 있음
  - 대용량 : DB트랜잭션을 발생시키는 ItemReader, ItemWriter 로 분리하고, chunk 단위로 트랜잭션 할 수 있음
  - 복잡성 : 작업의 최소단위 (Step)을 연결하여 일(Job)의 Flow 를 조직할 수 있음
  - 에러처리 : 입력 데이터의 filter, validator 등 적용 가능
- 스프링의 DI, AOP, 서비스추상화 이용하여 비즈니스 로직 분리 (XML, Annotation 지원)



## 1. Step ([ref](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/step.html#configureStep))

작업의 최소 단위. StepBuilderFactory 를 이용해서 Step 을 만들자



### Tasklet 을 이용한 구현

- 배치를 구현할 수 있는 execute 메소드를 제공하는 인터페이스
- 배치코드를 그대로 옮겨 담기
- Tasklet 을 이용한 마케팅메시지 전송 Step

```java
@Configuration
public class BatchConfiguration {
  
  @Autowired
  StepBuilderFactory stepBuilderFactory;
  
  @Bean
  public Step marketingMessageStep() {
    return stepBuilderFactory.get("marketingMessageStep")
      .tasklet(new MarketingGroupMessageSendToUserTasklet())
      .build();    
  }
}
```

```java
public class MarketingGroupMessageSendToUserTasklet implements Tasklet {

  @Override
  public RepeatStatus execute(StepContribution stepContribution, ChunkContext chunkContext) throws Exception {
    
    // 마케팅 메시지 불러오기
    List<Message> messages = messageRepository.selectMarketingGroupMessageSendList();
    
    // 마케팅 메시지 전송하기
    for (Message message : messages) {      
      MessageSendResult result = messageV2SendService.send(messageWithBloc);
    }
    
    return RepeatStatus.FINISHED;
  }
}
```



### Reader,Writer,Processor 를 이용한 구현

![Step](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/step.png)

- 비즈니스 로직과 트랜잭션의 분리

- 트랜잭션 비용의 감소 (chunk 이용)

- 인터페이스

  - Input, Output
  - Writer만 List 파라미터


  ![image-20210121134014189](/Users/positoy/Library/Application Support/typora-user-images/image-20210121134014189.png)

#### ![Chunk Oriented Processing](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/chunk-oriented-processing.png)



- Reader,Writer,Processor 를 이용한 마케팅메시지 전송 Step
  - <I,O>chunk(size) : Tasklet 의 interval-limit 과 동일
  - reader, processor, writer

  ```mysql
  @Configuration
  public class BatchConfiguration {

    @Autowired
    StepBuilderFactory stepBuilderFactory;

    @Bean
    public Step marketingMessageStep() {
      return stepBuilderFactory.get("marketingMessageStep")
        .<Message, Message>chunk(100)
        .reader(messageReader())
        .processor(messageSender())
        .writer(messageUpdater())
        .build();
    }

  	// 마케팅메시지 불러오기
  private ItemReader<Message> messageReader() {...}
  
	// 마케팅메시지 전송하기
    private ItemProcessor<Message, Message> messageSender() {...}
  
  	// 마케팅메시지 업데이트 하기  
  private ItemWriter<Message> messageUpdater() {...}
  }
  ```
  
- ItemReader<I>, ItemWriter<O> ([ref](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/readersAndWriters.html#database))

  - 인터페이스
    ![image-20210122140045140](/Users/positoy/Library/Application Support/typora-user-images/image-20210122140045140.png)

    ![image-20210122140118463](/Users/positoy/Library/Application Support/typora-user-images/image-20210122140118463.png)

  - Builder 를 이용하자

  - 다양한 구현체 제공 (FlatFile, XML, JSON, DB, ...)

  - 대용량 처리 (cursor-based, paging)

    ```java
    @Bean
    public JdbcCursorItemReader<CustomerCredit> itemReader() {
    	return new JdbcCursorItemReaderBuilder<CustomerCredit>()
    			.dataSource(this.dataSource)
    			.name("creditReader")
    			.sql("select ID, NAME, CREDIT from CUSTOMER")
    			.rowMapper(new CustomerCreditRowMapper())
    			.build();
    }
    ```

- ItemProcessor<I,O> ([ref](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/processor.html#itemProcessor))

  - 인터페이스
    ![image-20210122140030294](/Users/positoy/Library/Application Support/typora-user-images/image-20210122140030294.png)

    - ItermProcessor 인터페이스를 구현하는 클래스
    - lambda (java8~)
    - filtering (null 리턴)
    
    ```java
    @Bean
    public Step nameSwitchStep(JdbcBatchItemWriter<Person> writer) {
      return stepBuilderFactory.get("nameSwitchStep")
        .<Person,Person>chunk(1)
        .reader(reader())
        .processor((ItemProcessor<Person,Person>)person -> new Person(person.getLastName(), person.getFirstName()))
        .writer(writer)
        .build();
    }
    ```
    
  - chaining (Foo→Bar→Foobar)

    ```java
    @Bean
    public CompositeItemProcessor compositeProcessor() {
    	List<ItemProcessor> delegates = new ArrayList<>(2);
    	delegates.add(new FooProcessor());
    	delegates.add(new BarProcessor());
    
    	CompositeItemProcessor processor = new CompositeItemProcessor();
    
    	processor.setDelegates(delegates);
    
    	return processor;
    }
    ```

  

## 2. Job ([ref](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/job.html#configureJob))

Flow 와 Restartability 정보를 담고 있는 Step들의 컨테이너. JobBuilderFactory를 이용해서 Job 을 만들자.

### Flow ([ref](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/step.html#controllingStepFlow))

- Sequential flow
  ![Sequential Flow](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/sequential-flow.png)

  ```java
  @Bean
  public Job job() {
    return this.jobBuilderFactory.get("job")
      .start(stepA())
      .next(stepB())
      .next(stepC())
      .build();
  }
  ```

  

- Conditional flow
  ![Conditional Flow](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/conditional-flow.png)

  ```java
  @Bean
  public Job job() {
    return this.jobBuilderFactory.get("job")
      .start(stepA())
      .on("*").to(stepB())
      .from(stepA()).on("FAILED").to(stepC())
      .end()
      .build();
  }
  ```



### Restartability ([ref](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/job.html#restartability))

- Job Instance, Job Execution

  ![Job Parameters](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/job-stereotypes-parameters.png)

- 재시작 여부 설정

  ```java
  @Bean
  public Job footballJob() {
      return this.jobBuilderFactory.get("footballJob")
                       .preventRestart()
                       ...
                       .build();
  }
  ```

  



## 3. JobLauncher, JobRepository ([ref](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/job.html#configuringJobRepository))

![Figure 2.1: Batch Stereotypes](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/spring-batch-reference-model.png)



### @EnableBatchProcessing

- @EnableWebMvc 배치 버전
- 기본 설정 Bean 제공 (JobLauncher, JobRepository, StepBuilderFactory, JobBuilderFactory, ... )
- Job, Step 을 정의하면 Component scan 하여 자동으로 동작



### BatchConfigurer 

- WebConfigurer 배치 버전
  ![image-20210122150536779](/Users/positoy/Library/Application Support/typora-user-images/image-20210122150536779.png)

- Job Launcher

  - REST API 와 연동하는 경우 run 이 즉시 응답을 주도록 Async 설정
    ![Async Job Launcher Sequence](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/job-launcher-sequence-async.png)

    ```java
    @Controller
    public class JobLauncherController {
    
        @Autowired
        JobLauncher jobLauncher;
    
        @Autowired
        Job job;
    
        @RequestMapping("/jobLauncher.html")
        public void handle() throws Exception{
            jobLauncher.run(job, new JobParameters());
        }
    }
    ```

    ```java
    @Bean
    public JobLauncher jobLauncher() {
      SimpleJobLauncher jobLauncher = new SimpleJobLauncher();
      jobLauncher.setJobRepository(jobRepository());
      jobLauncher.setTaskExecutor(new SimpleAsyncTaskExecutor());
      jobLauncher.afterPropertiesSet();
      return jobLauncher;
    }
    ```

- Job Repository

  - 재시작이 가능하도록 Job, Step 상태를 저장하는 DB

    ```java
    @Override
    protected JobRepository createJobRepository() throws Exception {
        JobRepositoryFactoryBean factory = new JobRepositoryFactoryBean();
        factory.setDataSource(dataSource);
        factory.setTransactionManager(transactionManager);
        factory.setIsolationLevelForCreate("ISOLATION_SERIALIZABLE");
        factory.setTablePrefix("BATCH_");
        factory.setMaxVarCharLength(1000);
        return factory.getObject();
    }
    ```

    



  - Step, Step Execution
    ![Figure 2.1: Job Hierarchy With Steps](https://docs.spring.io/spring-batch/docs/4.3.x/reference/html/images/jobHeirarchyWithSteps.png)

  - org.springframework.batch.core 에 Job, Step 의 DBMS 별 스키마 제공

  ![image-20210113190341701](/Users/positoy/Library/Application Support/typora-user-images/image-20210113190341701.png)
  ![image-20210121135357686](/Users/positoy/Library/Application Support/typora-user-images/image-20210121135357686.png)

  

