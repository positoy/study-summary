## 스프링

### @JsonView

- JsonView 클래스와 내부의 인터페이스를 사용하여 json 응답을 마스킹할 수 있음
- @JsonView 어노테이션을 붙이지 않은 값들은 기본값으로 제외 됨
  - 스프링부트의 기본값(mapper.DEFAULT_VIEW_INCLUSION)을 true로 변경하면 포함 됨

```java
class Book {
  @JsonView(BookJsonView.Simple.class)
  private Long id;

  @JsonView(BookJsonView.Simple.class)
  private String isbn;

  @JsonView(BookJsonView.Simple.class)
  private String title;

  @JsonView(BookJsonView.Complex.class)
  private Date published;

  private Set<Author> authors;
}
```

```java
@RestController
public class BookController {
  @GetMapping("/books")
  @JsonView(BookJsonView.Complex.class)
  public List<Book> getBooks() {
    return books();
  }
}
```

- 참고

  - https://www.youtube.com/watch?v=5QyXswB_Usg

    

### @ExceptionHandler

Controller 내부에서 발생한 예외를 별도의 메소드에서 처리할 수 있게 해 준다

```java
@RestController
public class MyRestController {
  
  @GetMapping("/hello")
  public String hello() {
    return new NullPointerException("random throw");
  }

  @ExceptionHandler(NullPointerException.class)
  public Object nullex(Exception e) {
    System.err.println(e.getClass());
    return "error occurred";
  }
}
```



### @ControllerAdvice

모든 Controller, 또는 선언한 Cotnroller 에서 발생한 예외를 별도의 메소드에서 처리할 수 있게 해 준다.

`@RestControllerAdvice`는 `@ResponseBody`를 같이 선언해주는 효과가 있다 

```java
@ControllerAdvice(basePackageClasses = {CouponConfigController.class})
public class ApiExceptionHandler {
  
  @RestExceptionHandler(HttpMessageNotReadableException.class)
  public RemoteResponse resolveHttpMessageNotReadableException(HttpServletResponse response, Exception ex) {
    ...
      return "not readable";
  }
  
  @RestExceptionHandler(InvalidRequestBodyException.class)
  @ResponseStatus(HttpStatus.BAD_REQUEST)
  public RemoteResponse resolveInvalidRequestBodyException(InvalidRequestBodyException ex) {
    ...
      return "invalid request body";
  }
}
```



### MySQL JDBC Driver 추가

- pom.xml

```xml
<dependency>
  <groupId>mysql</groupId>
  <artifactId>mysql-connector-java</artifactId>
  <version>5.1.40</version>
</dependency>
```



### JSP View Resolver 추가

- pom.xml

  ```xml
  <dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>jstl</artifactId>
  </dependency>
  ```

- jsp 기본 위치는 `src/main/webapp/`, jstl, jasper 에서 정의함

- application.properties (optional)

  ```xml
  spring.mvc.view.prefix=/WEB-INF/jsp/
  spring.mvc.view.suffix=.jsp
  ```




### Async method

#### 방법1. Thread

```java
@RequesteMapping("/")
public String hello() {
  new Thread(new Runnable() {
    @Override
    public void run() {
      for (int i=0; i<10; i++)
        Thread.sleep(100);
    }
  });
  return "hello";
}
```

#### 방법2. EnableAsync (SimpleAsyncTaskExecutor)

- method 는 public 이어야 함
- method 는 caller 와 다른 클래스에 위치해야 함

```java
@SpringBootApplication
@EnableAsync
public class DemoApplication { ... }

@Component
public class MyAsyncService {
  @Async
  public Future<String> doAsyncMethod() {
    for (int i=0; i<5; i++) {
      Thread.sleep(1000);
    }
    return new AsyncResult<String>("hello");
  }
}

@RestController
public class MainController {
  @Autowired
  MyAsyncService myAsyncService;
  
  @RequestMapping("/")
  public String hello() {
    Future<String> future = myAsyncService.doAsyncMethod();

    return "hello";
    // or    
    while (!future.isDone())
      Thread.sleep(100);
    return future.get();
  }
}
```

#### 방법3. EnableAsync (ThreadPoolTaskExecutor)

```java
@Configuration
@EnableAsync
public class MyAsyncService {

  @Bean
  public Executor threadPoolTaskExecutor() {
    ThreadPoolTaskiterhromExecutor executor = new ThreadPoolTaskExecutor();
    executor.setCorePoolSize(5);
    executor.setMaxPoolSize(50);
    executor.setQueueCapacity(10);
    executor.setThreadNamePrefix("Executor-");
    executor.initialize();
    return executor;
  }
}

@Component
public class MyAsyncService {
  @Async("threadPoolTaskExecutor")
  public Future<String> doAsyncMethod() {
    // do async method
  }
}
```



## 자바

### ThreadLocal

스레드에 Generic Type 으로 변수를 저장할 수 있는 클래스. get(), set(), remove() 메소드를 사용한다.
요청 당 하나의 스레드가 처리하는 점을 이용하여 요청 단위의 변수 관리가 가능하다. filter 에서 비즈니스 로직에 필요한 도메인 오브젝트를 ThreadLocal 에 저장해놓고 Controller 에서 처리하는 식. 참고로, 동일한 타입을 여러개 관리하고 싶을 수도 있으니 NamedThreadLocal 을 제공한다.

```java
public abstract class Domain {
	private static final ThreadLocal<ServiceDomain> threadLocal = new NamedThreadLocal<ServiceDomain>("ServiceDomain");

	public static ServiceDomain get() {
		return threadLocal.get();
	}
```



### CollectionUtils

empty 확인 시 null 체크를 피하기 위해 사용

```java
if (CollectionUtils.isNotEmpty(obj)) //doSomething
```
