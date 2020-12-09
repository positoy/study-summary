# 스프링

톡톡 프로젝트들은 Oracle Java8, 톰캣 8.5 환경에서 실행 권장

## [인프런 웹-MVC](https://www.infleaarn.com/course/%EC%9B%B9-mvc)

### 스프링 MVC 동작원리

1. 스프링 MVC 소개
   - 웹 서비스의 Model, View, Controller 를 분리하여 개발 효율성과 유지보수가 좋아짐 (lose coupling high cohesion)
   - POJO 객체인 모델을 컨트롤러를 통해 View 로 전달하고 동적으로 페이지를 만듦. Controller - View 사이에 Service 를 사용하여 복잡한 비즈니스 로직을 처리하고 Controller - Model 의존성을 떼어냄.

```java
// Model
class Event {
...
}

@Service
class EventService {

	public List<Event> getEvents() {
		List<Event> list = new ArrayList<>();
		list.add(new Event());
		list.add(new Event());
		return list;

}
  
// Controller
@Controller
class EventController {

	@Autowired
	EventService eventService;
	
	@GetMapping("/class")
	public List<Event> getEvents(Model model) {
		model.addAttribute("events", eventService.getEvents());
		return "class";
	}
}
```

```html
<!-- View (class.html) -->
<table>
  <tr>
    <th>이름</th>
    <th>주최자</th>
  <tr>
  <tr th:each="event:${events}">
    <td th:text="${event.name}">MVC</td>
    <td th:text="${event.holder}">Andy</td>
  </tr>
```



2. 서블릿 소개

   - 자바에서 애플리케이션 개발 단위(?)
   - 스펙 및 API 에 맞는 서블릿은 만들면 서블릿 엔진 or 컨테이너 (tomcat, jetty 등) 에서 요청당 스레드를 만들어서 동작
   - 세션관리, MIME 메시지 변환, 생명주기 등 제공
   - 프로세스 단위로 요청을 처리하던 과거 방식보다 빠름
   - 생명주기 : 최초 1회 init() → 매 요청 service()/doGet()/doPost() → 요청 끝 destroy()

   

3. 서블릿 애플리케이션 개발

   - 서블릿 클래스를 상속하여 service 메소드 구현
   - web.xml 에서 구현한 서블릿을 명시하고 주소 매핑

   ```java
   public class HelloServlet extends HttpServlet {
     
     @Override
     public void init() throws ServletException {}
     
     @Override
     protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
       resp.getWriter().println("<h1>Hello World!</h1>");
     }
     
     @Override
     public void destroy() {}
   }
   ```

   ```xml
   <servlet>
     <servlet-name>hello</servlet-name>
     <servlet-class>com.navercorp.mvc2.HelloServlet</servlet-class>
   </servlet>
   
   <servlet-mapping>
     <servlet-name>hello</servlet-name>
     <url-pattern>/hello</url-pattern>
   </servlet-mapping>
   ```

   

4. 서블릿 리스너와 필터
   서블릿리스너와 필터를 만들어 web.xml 선엄하으로써, 요청을 처리하기 전 적절한 전처리를 수행할 수 있음

   1. 서블릿 리스너

      - 서블릿컨테이너의 context 변화를 감지하여 service 메소드 호출 전 필요한 동작을 수행하는 Filter 를 추가할 수 있음
      - 처리한 내용은 서블릿 컨텍스트에 저장 할 수 있음

      ```xml
      <listener>
        <listener-class>com.navercorp.mvc2.MyListener</listener-class>
      </listener>
      ```

      ```java
      // Listener
      public class MyListener implements ServletContextListener {
      
          @Override
          public void contextInitialized(ServletContextEvent sce) {
              System.out.println("contextInitialized");
              sce.getServletContext().setAttribute("name", "andy");
          }
      
          @Override
          public void contextDestroyed(ServletContextEvent sce) {
              System.out.println("contextDestroyed");
          }
      }
      
      
      // Servlet
      public class HelloServlet extends HttpServlet {
        	@Override
          protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
            resp.getWriter().println(getServletContext().getAttribute("name"));
          }
      }
      ```

   2. 필터

![image](https://media.oss.navercorp.com/user/21427/files/cc5e9780-2dd4-11eb-8af4-8235170ca198)

      - 필터는 순차적으로 연계되어 동작함. doFilter 로 응답을 넘겨주어야 요청이 전달 됨.
      - 서블릿 매핑, URI 매핑이 가능

   ```xml
   <filter>
     <filter-name>myFilter</filter-name>
     <filter-class>com.navercorp.mvc2.MyFilter</filter-class>
   </filter>
   
   <filter-mapping>
     <filter-name>myFilter</filter-name>
     <servlet-name>hello</servlet-name>
   </filter-mapping>
   ```

   ```java
   public class MyFilter implements Filter {
       @Override
       public void init(FilterConfig filterConfig) throws ServletException {
           System.out.println("filter init");
       }
   
       @Override
       public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
           System.out.println("filter");
           filterChain.doFilter(servletRequest, servletResponse);
       }
   
       @Override
       public void destroy() {
           System.out.println("filter destroy");
       }
   }
   
   ```

   

5. 스프링 IoC 컨테이너 연동 (ContextLoaderListener)

   - ContextLoaderListener를 리스너로 등록하여 AnnotationConfig 클래스를 로드할 수 있음

   - Config 클래스가 컨텍스트에 필요한 Bean을 로드 (@Configuration, @ComponentScan 이용)

   - 컨텍스트에서 얻어온 Bean으로 의존성을 해결할 수 있게 됨

     ```xml
     <context-param>
       <param-name>contextClass</param-name>
       <param-value>org.springframework.web.context.support.AnnotationConfigWebApplicationContext</param-value>
     </context-param>
     
     <context-param>
       <param-name>contextConfigLocation</param-name>
       <param-value>com.navercorp.mvc2.AppConfig</param-value>
     </context-param>
     
     ...
     
     <listener>
       <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
     </listener>
     ```

     ```java
     @Configuration @ComponentScan
     public class AppConfig {
         @Autowired
         HelloService helloService;
     }
     
     public class HelloServlet extends HttpServlet {
     
       @Override
     	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
     		ApplicationContext context = getServletContext().getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE);
     		HelloService helloService = context.getBean(HelloService.java);
     		return "Hello " + helloService.getName();
       }
     } 
     ```

       

6. 스프링 MVC 연동 (DispatcherServlet)

   - DispatcherServlet을 서블릿으로 등록하여 AnnotationConfig 클래스를 등록할 수 있음

   - Listener를 사용한 방식과 동일하지만 두 AnnotationConfig의 스캔 범위를 제한하여 관리하는 Bean을 분리할 수 있음

     ```xml
     <servlet>
       <servlet-name>app</servlet-name>
       <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
       <init-param>
         <param-name>contextClass</param-name>
         <param-value>org.springframework.web.context.support.AnnotationConfigWebApplicationContext</param-value>
       </init-param>
       <init-param>
         <param-name>contextConfigLocation</param-name>
         <param-value>com.navercorp.mvc2.WebConfig</param-value>
       </init-param>
     </servlet>
     
     <servlet-mapping>
       <servlet-name>app</servlet-name>
       <url-pattern>/app/*</url-pattern>
     </servlet-mapping>
     ```

     ```java
     // AppConfig.java
     @Configuration
     @ComponentScan(excludeFilters = @ComponentScan.Filter(Controller.class))
     public class AppConfig {
         @Autowired
         HelloService helloService;
     }
     
     // WebConfig.java
     @ComponentScan(useDefaultFilters = false, includeFilters = @ComponentScan.Filter(Controller.class))
     public class WebConfig {
     }
     
     // HelloController.java
     @RestController
     public class HelloController {
     
         @Autowired
         HelloService helloService;
     
         @GetMapping("hello")
         public String getHello() {
             return "hello " + helloService.getName();
         }
     }
     ```

   -  최근에는 DispatcherServlet이 모든 Bean을 관리하는 구조가 더 일반적임

   

7. DispatcherServlet

   - Multipart, Locale, Theme 등 request 전처리하기 (processedRequest)
   - handler 찾기 (mappedHandler)
   - handlerAdapter 찾기 (ha)
   - 요청처리 : ha.handle(processedRequest, response, mappedHandler.getHandler())
   - ViewResolver
   - 예외처리 or 응답처리

   

8. 스프링 MVC 구성 요소

   - DispatcherServlet 은 다양한 HTTP Request 형태를 처리하는 resolver 들을 갖고 있음
   - DispatcherServlet.properties 파일에 기본 전략이 정의되어 있음 (Multipart, Locale, Theme 등)
   - HandlerMapping 과 HandlerAdapter 를 이용하여 사용자가 등록한 Bean 을 도입한다.

   

9. 스프링 MVC 동작 원리 정리

   - 스프링 MVC는 서블릿 컨텍스트에 스프링이 로드되지만, Boot 는 스프링부트 애플리케이션이 직점 톰캣과 스프링을 로드 함



### 스프링 MVC 설정

1. 스프링 MVC 빈 설정

   - `DispatcherServlet.properties` 에 선언된 클래스들을 기본으로 사용하게 됨

   - 다음처럼 사용자가 Bean을 추가하여 변경할 수 있음 (하지만 @Bean 등록은 잘 사용하지 않는 방식)

     ```java
     @Configuration
     @ComponentScan
     public class WebConfig {
     
         @Bean
         public ViewResolver viewResolver() {
             InternalResourceViewResolver viewResolver = new InternalResourceViewResolver();
             viewResolver.setPrefix("/WEB-INF/");
             viewResolver.setSuffix(".jsp");
             return viewResolver;
         }
     }
     
     ```

     

2. @EnableWebMvc

   - 스프링 MVC 자동 구성은` WebMvcAutoConfiguration`이 담당하는데, `WebMvcConfigurationSupport` 타입의 빈을 찾을 수 없으면 기본 설정을 적용
   - `@EnableWebMvc` 표시하면 기본 설정을 사용하지 않고 `WebMvcConfigurer` 타입의 빈을 검색해서 기본 설정을 쉽게 변경할 수 있는 기능 제공
   - 아래처럼 선언하면 `WebMvcConfigurationSupport`에서 자동구성한 스프링 MVC 구성에 `Formatter`, `MessageConverter` 등을 추가적으로 등록할 수 있다.

   ```java
   @Configuration
   @EnableWebMvc
   public class WebMvcConfig implements WebMvcConfigurer {
     @Override
     public void addFormatters(FormatterRegistry formatterRegistry) {
   	  formatterRegistry.addConverter(new MyConverter());
     }
   
     @Override
     public void configureMessageConverters(List<HttpMessageConverter> converters) {
   	  converters.add(new MyHttpMessageConverter());
     }
   }
   ```

   - `@EnableWebMvc`를 사용하지 않으면 다음 방법으로 MVC 구성을 변경 가능

     ```java
     @Configuration
     public class WebMvcConfig extends WebMvcConfigurationSupport {
       @Bean
       @Override
       public RequestMappingHandlerMapping requestMappingHandlereMapping() {
         return super.requestMappingHandlerMapping();
       }
     }
     ```

     

3. WebMvcConfigurer

   - @WebMvcConfigurer 를 구현하여 MVC 설정 변경 가능

     ```java
     @Configuration
     @ComponentScan
     @EnableWebMvc
     public class WebConfig implements WebMvcConfigurer {
       @Override
       public void configureViewResolvers(ViewResolverRegistry registry) {
         registry.jsp("/WEB-INF/", ".jsp");
       }
     }
     ```

     

4. 스프링 부트의 스프링 MVC 설정

   1. application.properties (Boot Only)
   2. @Configuration + WebMvcConfigurer 구현 : MVC 자동설정 + 추가설정
   3. @Configuration + @EnableWebMvc + WebMvcConfigurer 구현 : MVC 자동설정 사용하지 않음

   

5. 스프링 부트 실행

   - 직접 실행 : jar 배포하여 실행 가능. 내장 tomcat 이 서버 실행.
   - tomcat 배포 :  `SpringBootServletInitializer` 구현체를 war 배포하여 실행 가능

   

6. WebMvcConfigurer 1부 Formatter

   - Formatter를 이용하여 요청의 문자열을 객체로 변환 가능

   ```java
   @RestController
   public class SampleController {
       @GetMapping("/hello/{person}")
       public String helloName(@PathVariable Person person) {
           System.out.println(person.toString());
           return "hello, " + person.getName();
       }
   }
   ```

   - DispatcherServlet 이 시작될 때 handler 에 Formatter가 추가될 수 있도록,
     WebMvcConfigurer의 구현체에서 Formatter 등록이 필요

   ```java
   @Configuration
   public class WebConfig implements WebMvcConfigurer {
       @Override
       public void addFormatters(FormatterRegistry registry) {
           registry.addFormatter(new PersonFormatter());
       }
   }
   ```

   ```java
   public class PersonFormatter implements Formatter<Person> {
       @Override
       public Person parse(String s, Locale locale) throws ParseException {
           Person person = new Person();
           person.setName(s);
           return person;
       }
   
       @Override
       public String print(Person person, Locale locale) {
           return person.toString();
       }
   }
   ```

   - Spring Boot

     Boot에서는 PersonFormatter에 @Component 를 붙여주면 WebMvcConfigurer를 구현하지 않아도 등록된다
     
     

7. 도메인 클래스 컨버터 (Spring Data JPA 관련)
   Spring Data JPA 는 JPARepository 를 구현하는 것만으로, 요청의 파라미터를 PK로 DB의 객체를 가져오는 기능을 제공한다

   ```java
   public interface PersonRepository extends JpaRepository<Person, Long> {
   }
   ```

   ```java
   @Entity
   public class Person {
   
       @Id @GeneratedValue
       private Long id;
     ...
   ```

   ```java
   @RestController
   public class HelloController {
   
       @GetMapping("/hello/{id}")
       public String hello(@PathVariable("id") Person person) {
           return person.toString();
       }
   }
   ```

   

8. 핸들러 인터셉터

   - DispatcherServlet.interceptorList 자료구조에 등록 순서대로 저장 되고, ServletDispatcher.doDispatch에서 handle 전후로 preHandle, postHandle 를 적용한다.

   - 2개 이상의 인터셉터를 등록한 경우, preHandle 은 등록 순서대로, postHandle과 afterCompleteion 은 역순으로 적용된다. order 메소드를 이용해서 임의로 순서를 적용할 수 있다. addPathPattern 메소드를 이용해서 URL 범위를 제한할 수 있다.

     ```java
     @Configuration
     public class WebConfig implements WebMvcConfigurer {
         @Override
         public void addInterceptors(InterceptorRegistry registry) {
             registry.addInterceptor(new InterceptorOne()).order(0);
             registry.addInterceptor(new InterceptorTwo()).order(-1);
             registry.addInterceptor(new InterceptorTwo()).addPathPattern("/hello");
         }
     }
     
     ```

   - preHandle은 리턴 값이 true 일 때에만 연쇄적으로 다음 인터셉터로 전파된다.

     ```java
     public class InterceptorOne implements HandlerInterceptor {
         @Override
         public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
             return true;
         }
     ```

   - afterCompletion 은 예외발생 시에 호출 된다.

     

9. 리소스 핸들러 

   - 정적 리소스는 default servlet 으로 처리된다.

   - 사용자가 등록한 ResourceHandler 로 요청을 처리할 수 있다.

     ```java
     @Configuration
     public class WebConfig implements WebMvcConfigurer {
         @Override
         public void addResourceHandlers(ResourceHandlerRegistry registry) {
             registry.addResourceHandler("/m/*")
                     .addResourceLocations("classpath:/mobile/")
                     .setCacheControl(CacheControl.maxAge(10, TimeUnit.MINUTES));
         }
     }
     ```

   - WebMvcMock 에서 헤더 내용을 확인하는 테스트를 만들 수 있다.

     ```java
         @Test
         public void testCacheControl() throws Exception {
             this.mockMvc.perform(get("/index.html"))
                     .andDo(print())
                     .andExpect(header().doesNotExist(HttpHeaders.CACHE_CONTROL));
     
             this.mockMvc.perform(get("/m/index.html"))
                     .andDo(print())
                     .andExpect(header().exists(HttpHeaders.CACHE_CONTROL))
                     .andExpect(status().isOk());
     
     
             this.mockMvc.perform(get("/m/index.html"))
                     .andDo(print())
                     .andExpect(header().exists(HttpHeaders.CACHE_CONTROL))
                     .andExpect(status().is3xxRedirection())
                     .andExpect(status().is(304)); // mockMvc sends 200 ?!
         }
     ```

     

10. HTTP 메시지 컨버터
    요청/응답의 Body를 객체로 변환해줌 @RequestBody @ResponseBody

    ```java
    @Controller
    public class SampleController {
        @GetMapping("/person")
        @ResponseBody
        public Person person(@RequestBody Person person) {
            return person;
        }
    }
    ```

    - Request Header 의 `Content-Type`과 `Accept`  참고하여 컨버터를 적용함

    - 컨버터를 구현하지 않더라도 의존성을 확인하여 XML, JSON 을 객체로 변환하거나 반대로 변환 가능

    - `WebMvcConfigurationSupport.getDefaultMediaTypes` 에서 의존성에 따라 분기하는 내용 확인 가능

      - JSON `{ "name" : "andy" }`

        ``` java
            @Test
            public void testPerson() throws Exception {
                Person person = new Person();
                person.setName("andy");
                String jsonString = objectMapper.writeValueAsString(person);
        
                this.mockMvc.perform(get("/person")
                        .contentType(MediaType.APPLICATION_JSON)
                        .accept(MediaType.APPLICATION_JSON)
                        .content(jsonString))
                        .andDo(print())
                        .andExpect(status().isOk());
            }
        ```

      - XML `<person><name>andy</name></person>`

        ```java
            @Test
            public void testPersonXml() throws Exception {
                Person person = new Person();
                person.setName("andy");
        
                StringWriter stringWriter = new StringWriter();
                Result result = new StreamResult(stringWriter);
                marshaller.marshal(person, result);
                String xmlString = stringWriter.toString();
        
                this.mockMvc.perform(get("/person")
                        .contentType(MediaType.APPLICATION_XML)
                        .accept(MediaType.APPLICATION_XML)
                        .content(xmlString))
                        .andDo(print())
                        .andExpect(status().isOk())
                        .andExpect(xpath("person/name").string("andy"));
            }
        ```

        

### 스프링 MVC 활용

1. 요청 매핑하기 1부 HTTP Method

   - GET/POST/PUT/PATCH/DELETE

     - POST 빼고 모두 idemponent
     - POST, PUT, PATCH 는 비슷하지만 idemponent, URI, payload 에 차이가 있음

   - RequestMapping

     ```java
     @RequestMapping(value="/hello", method={RequestMethod.GET, RequestMethod.POST})
     public String hello() {
       return "hello";
     }
     ```

   - Get/Post/Put/Patch/DeleteMapping

     ```java
     @GetMapping("/hello")
     public String hello() {
       return "hello";
     }
     ```

   - Controller 에 Annotation 을 붙이면 @RequestMapping이 붙은 Method 에 일괄 적용 됨

   

2. 요청 매핑하기 2부 URI 패턴

   - Controller 와 Method 를 연결할 수 있음

     ``` java
     @Controller
     @RequestMapping("/hello")
     public class SampleController {
       
       @RequestMapping("/hi")
       public String hellohi() {
         return "hello hi";
       }
     }
     ```

   - 패턴 (?,*)

     ```java
     @GetMapping("/hello/?") // 한글자
     @GetMapping("/hello/*") // 여러글자
     @GetMapping("/hello/**") // path level 이 깊어지더라도 뭐든지
     ```

   - 정규식 ({name:정규식})

     ```java
     @GetMapping("/{name:[a-z]+}")
     @ResponseBody
     public String alphabets(@PathVariable("name") String name) {
       return "hello " + name;
     }
     ```

   - 패턴이 중복될 때에는 먼저 정의된 핸들러가 매칭 됨

   - 확장자 (MVC는 지원, Boot에서는 기본 지원되지 않음)
     RFD 보안 이슈가 있기 때문에 특정 형식의 응답을 원할 때에는 요청 헤더의 Accept 또는 파라미터 사용 권장

   - 테스트

     ```java
         @Test
         public void testAlphabetURI() throws Exception {
             this.mockMvc.perform(get("/hello/andy"))
                     .andDo(print())
                     .andExpect(status().isOk())
                     .andExpect(content().string("hello andy"))
                     .andExpect(handler().handlerType(SampleController.class))
                     .andExpect(handler().methodName("alphabets"));
         }
     ```

     

3. 요청 매핑하기 3부 미디어 타입

   - consumes/produces

     - 요청 헤더의 Content-Type (consumes) 과 Accept (produces) 에  따라서 다르게 endpoint 를 제공할 수 있다.
     - Controller와 method에 겹쳐 선언하면 method 의 내용만 사용

     ```java
     @GetMapping(
       value="/hello",
       consumes=MediaType.APPLICATION_JSON_UTF8_VALUE,
       produces=MediaType.TEXT_PLAIN_VALUE
     )
     public String hello() {
       return "hello";
     }
     ```

   - 테스트

     ```java
     @Test
     public void testMediaType() throws Exception {
       this.mockMvc.perform(get("/hello/person")
                            .contentType(MediaType.APPLICATION_JSON)
                            .accept(MediaType.TEXT_PLAIN))
         .andDo(print())
         .andExpect(status().isOk())
         .andExpect(content().string("new person"));
     }
     
     @Test
     public void testUnsupportedMediaType() throws Exception {
       this.mockMvc.perform(get("/hello/person")
                            .contentType(MediaType.APPLICATION_XML))
         .andDo(print())
         .andExpect(status().isUnsupportedMediaType());
     }
     
     @Test
     public void testNotAcceptable() throws Exception {
       this.mockMvc.perform(get("/hello/person")
                            .accept(MediaType.APPLICATION_XML))
         .andDo(print())
         .andExpect(status().isUnsupportedMediaType());
     }
     ```

     

4. 요청 매핑하기 4부 헤더와 파라미터

   ```java
   // 헤더
   @RequestMapping(header = "key") // 있음
   @RequestMapping(header = "!key") // 없음
   @RequestMapping(header = "key=value") // 특정값
   
   // 파라미터
   @RequestMapping(params = "key") // 있음
   @RequestMapping(params = "!key") // 없음
   @RequestMapping(params = "key=value") // 특정값
   ```

   ```java
   @Test
   public void testHeaderAndParam() throws Exception {
     this.mockMvc.perform(get("/header/params")
                          .header(HttpHeaders.FROM, "Mac")
                          .param("name","andy"))
       .andDo(print())
       .andExpect(status().isOk());
   }
   ```

   

5. 요청 매핑하기 5부 HEAD와 OPTIONS

   - HEAD : GET 과 동일하지만 응답에서 본문은 제외하는 요청. GetMapping이 자동으로 처리해줌

   - OPTIONS : 지원하는 메소드 확인

     ```java
     @Test
     public void testOPTIONS() throws Exception {
       this.mockMvc.perform(options("/hello/download"))
         .andDo(print())
         .andExpect(status().isOk())
         .andExpect(header().stringValues(HttpHeaders.ALLOW,
                                          hasItems(
                                            containsString("OPTIONS"),
                                            containsString("POST"),
                                            containsString("HEAD"),
                                            containsString("GET")
                                          )));
     }
     ```

     

6. 요청 매핑하기 6부 커스텀 애노테이션

   ```java
   @Documented
   @Target(ElementType.METHOD)
   @Retention(RetentionPolicy.RUNTIME) // 기본값 CLASS, 주석으로만 사용시 SOURCE
   @RequestMapping(method = RequestMethod.GET, value = "/hello") // Get,PostMapping 은 이미 커스텀 애노테이션이어서 사용 불가
   public @inteface GetHelloMapping {}
   ```

   

7. 핸들러 메소드 1부 아규먼트와 리턴 타입

   - @PathVariable

     ```java
     @GetMapping("events/{id}")
     public Event getEvents(@PathVariable(name = "id", required = false) Integer val) {
       Event event = new Event();
       event.setId(val);
       return event;
     }
     ```

     

8. 핸들러 메소드 2부 URI 패턴

9. 핸들러 메소드 3부 요청 매개변수 (단순 타입)

   - @RequestParam
     GET, POST 의 요청 매개변수 모두 @RequesetParam 으로 받을 수 있음 (어노테이션 생략 가능)

     ```java
     @RequestMapping(value = "person", method = {RequestMethod.GET, RequestMethod.POST})
     public Person person(@RequestParam String name, @RequestParam Integer age) {
       Person person = new Person();
       person.setName(name);
       person.setAge(age);
       return person;
     }
     ```

     

10. 핸들러 메소드 4부 폼 서브밋

    - label 요소를 사용할 수 없을 때 식별자로 title 사용

    - name 은 전달하는 데이터의 key 로 사용

    - 전달되는 데이터 인코딩은 url-encoded 기본설정

      ```html
      <form action="/person" method="post">
        <input type="text" title="name" name="name"/>
        <input type="text" title="name" name="age" />
        <input tpye="submit" value="입력" />
      </form>
      ```

    - thymeleaf 사용시 다음처럼 작성 가능

      ```xml
      <form th:action="@{/person}" method="post" th:object="${person}">
        <input type="text" title="name" th:field="*{name}" />
        <input type="text" title="age" th:field="*{age}" />
        <input type="submit" value="create" />
      </form>
      ```

      

11. 핸들러 메소드 5부 @ModelAttribute

    - 여러 경로(query, body, session, cookie, ...)로 들어온 매개변수를 하나의 객체로 묶어 변환 가능 (@ModelAttribute 생략가능)

    - Binding 실패시 404 Bad Requeset 응답

    - Error 혹은 이를 상속한 BindingResult 매개변수를 추가함으로써 Binding 에러 예외처리 가능

      ```java
      @RequestMapping(value = "person", method = {RequestMethod.GET, RequestMethod.POST})
      @ResponseBody
      public Person person(@ModelAttribute Person person, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
          bindingResult.getAllErrors().forEach(c -> {
            System.out.print(c.toString());
          });
        }
        return person;
      }
      ```

      

12. 핸들러 메소드 6부 @Validated

    - @Valid, @Validated 로 객체의 유효성 검사 가능

    - 바인딩이 성공하더라도 (타입체크) 유효성 검사에 실패하면 bindingResult 에 담겨서 전달 됨

      ```xml
      <!-- https://mvnrepository.com/artifact/javax.validation/validation-api -->
      <dependency>
        <groupId>javax.validation</groupId>
        <artifactId>validation-api</artifactId>
        <version>2.0.1.Final</version>
      </dependency>
      
      <!-- https://mvnrepository.com/artifact/org.hibernate/hibernate-validator -->
      <dependency>
        <groupId>org.hibernate</groupId>
        <artifactId>hibernate-validator</artifactId>
        <version>6.1.6.Final</version>
      </dependency>
      ```

      ```java
      @RequestMapping(value = "person", method = {RequestMethod.GET, RequestMethod.POST})
      @ResponseBody
      public Person person(@ModelAttribute Person person, BindingResult bindingResult) {
      ```

      ```java
      public class Person {
          @Min(0)
          Integer age;
      ```

    - @Validated 는 group 으로 클래스 validation 을 분리하여 적용할 수 있도록 제공

      - groups 선언 된 제한사항은 @Valid @Validated 만으로는 적용이 불가능

      ```java
      public class Person {
      
          static public interface ValidateName{}
          static public interface ValidateAge{}
      
          @NotBlank(groups = ValidateName.class)
          String name;
      
          @Min(value = 0, groups = ValidateAge.class)
          Integer age;
      ```

      ```java
          @RequestMapping(value = "person", method = {RequestMethod.GET, RequestMethod.POST})
          @ResponseBody
          public Person person(
                  @Validated(value = {Person.ValidateName.class, Person.ValidateAge.class})
                  @ModelAttribute
                          Person person,
                          BindingResult bindingResult) {
      ```

      

13. 핸들러 메소드 7부 폼 서브밋 에러 처리

    - 바인딩 에러 표시 : 바인딩 에러가 모델에 포함되므로 view 에서 이 정보를 표시할 수 있음

      ```java
          @PostMapping("/people")
          public String person(
                  @Validated(value = {Person.ValidateName.class, Person.ValidateAge.class})
            			@ModelAttribute Person person,
                  BindingResult bindingResult) {
              if (bindingResult.hasErrors())
                  return "form";
      ```

      ```xml
      <form th:action="@{/people}" method="post" th:object="${person}">
          <p th:if="${#fields.hasErrors('name')}" th:errors="*{name}">wrong!</p>
          <p th:if="${#fields.hasErrors('age')}" th:errors="*{age}">wrong!</p>
          <input type="text" title="name" th:field="*{name}" />
          <input type="text" title="age" th:field="*{age}" />
          <input type="submit" value="create" />
      </form>
      ```

    - PRG 패턴 : F5 누르는 경우 idemponent 하지 않은 POST 요청이 반복되는 것 방지 (Post > Redirect > Get)

      ```java
      @PostMapping("/people")
      public String person(Person person, BindingResult bindingResult) {  
          if (bindingResult.hasErrors())
            return "form";
      
          personRepository.add(person);
          return "redirect:/people/list";
      }
      
      @GetMapping("/people/list")
      public String list(Model model) {
        model.addAttribute("people", personRepository);
        return "list";
      }
      ```

      

14. 핸들러 메소드 8부 @SessionAttributes

    - Controller 에 @SessionAttributes 를 선언할 경우, 동일한 이름의 ModelAttribute 는 세션에서 유지
    - 이 방법으로 세션에서 아이템을 유지하는 기능 구현 가능 (장바구니)
    - SessionStatus 에서 setComplete 하면 세션에서 삭제 된다

    ```java
    @Controller
    @SessionAttributes("person")
    public class PersonController {
    
        @GetMapping("/people/register/complete")
        public String getRegisterComplete(
          @Validated({Person.ValidateName.class, Person.ValidateAge.class})
          @ModelAttribute
          Person person,
          BindingResult bindingResult,
          SessionStatus sessionStatus) {
            if (bindingResult.hasErrors())
                return "redirect:/people/register";
    
            sessionStatus.setComplete();
            return "register-complete";
        }
    ```

    

15. 핸들러 메소드 9부 @SessionAttribute

    - Session Attribute 를 HttpSession 를 사용하지 않고 꺼낼 수 있음

    - HttpSession 을 사용하면 강제 형변환이 필요함

      ```java
      public class VisitTimeInterceptor implements HandlerInterceptor {
          @Override
          public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
              if (request.getSession().getAttribute("visitTime") == null)
                  request.getSession().setAttribute("visitTime", LocalDateTime.now());
              return true;
          }
      }
      ```

      ```java
      @GetMapping("/people/register")
      public String getRegister(@SessionAttribute LocalDateTime visitTime) {
        System.out.println(visitTime.toString());
      ```

      

16. 핸들러 메소드 11부 RedirectAttributes

    - redirect 시 model 파라미터는 주소에 url 로 붙음

      ```java
      @PostMapping("/hello")
      public String hello(Model model) {
        model.addAttribute("name", "andy");
        model.addAttribute("age", "30");
        return "redirect:/hi";
      }
      ```

    - Spring Boot 에서는 설정이 꺼져있으므로 RedirectAttributes 를 사용할 수 있음

      ```java
      @PostMapping("/hello")
      public String hello(RedirectAttributes attributes) {
        attributes.addAttribute("name", "andy");
        attributes.addAttribute("age", "30");
        return "redirect:/hi";
      }
      ```

      

17. 핸들러 메소드 12부 Flash Attributes

    - addAttribute 와 비슷하지만 세션으로 전달되어 주소로 노출되지 않음

    - 주소로 전달되지 않으므로 객체도 전달 가능

    - redirect 된 핸들러에서 처리되고 세션에서 지워짐

      ```java
      @PostMapping("/hello")
      public String hello(RedirectAttributes attributes) {
        attributes.addFlashAttribute("name", "andy");
        attributes.addFlashAttribute("age", "30");
        return "redirect:/hi";
      }
      ```

      

18. 핸들러 메소드 13부 MultipartFile (업로드)

    - 코드

      ```java
      @GetMapping("/file")
      public String fileUploadForm(Model model) {
        return "file";
      }
      
      @PostMapping("/file")
      public String fileUpload(@RequestParam MultipartFile file, RedirectAttributes attributes) {
        // save
        attributes.addFlashAttribute("message", file.getOriginalFilename() + " is uploaded.");
        return "redirect:/file";
      }
      ```

      ```html
      <div th:if="${message}">
        <h2 th:text="${message}"/>
      </div>
      <form th:action="@{/file}" method="post" enctype="multipart/form-data">
        File : <input type="file" name="file" />
        <input type="submit" value="UPLOAD"/>
      </form>
      ```

    - 테스트

      ```java
      @Test
      public void testFileUploadPage() throws Exception {
        MockMultipartFile file = new MockMultipartFile("file", "test.txt", "text/plain", "hello world!".getBytes());
        this.mockMvc.perform(multipart("/file").file(file))
          .andDo(print())
          .andExpect(status().is3xxRedirection());
      }
      ```

      

19. 핸들러 메소드 14부 ResponseEntity (다운로드)

    ```xml
    <!-- https://mvnrepository.com/artifact/org.apache.tika/tika-core -->
    <dependency>
      <groupId>org.apache.tika</groupId>
      <artifactId>tika-core</artifactId>
      <version>1.24.1</version>
    </dependency>
    ```

    ```java
    @GetMapping("/file/{filename}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String filename) throws IOException {
      Resource resource = resourceLoader.getResource("classpath:" + filename);
      File file = resource.getFile();
      String contentType = new Tika().detect(file);
    
      return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename")
        .header(HttpHeaders.CONTENT_TYPE, contentType)
        .header(HttpHeaders.CONTENT_LENGTH, file.length() + "")
        .body(resource);
    }
    ```

    

20. 핸들러 메소드 15부 @RequestBody & HttpEntity

    - @RequestBody 를 사용하면 요청의 바디를  HttpMessageConvert 를 통해 객체로 받아올 수 있다.

    - @Valid, @Validated, BindingResult 사용 가능하다.

      ```java
      @PostMapping("/person/body")
      @ResponseBody
      public Person postPersonBody(@Validated({Person.ValidateName.class, Person.ValidateAge.class})@RequestBody Person person, BindingResult bindingResult) {
        if (bindingResult.hasErrors())
          System.out.println(person.toString());
        return person;
      }
      ```

    - HttpEntity 는 부가적으로 헤더 정보를 확인할 수 있다

      ```java
      @PostMapping("/person/body")
      @ResponseBody
      public Person postPersonBody(HttpEntity<Person> request) {
        System.out.println(request.getHeaders().getContentType());
        return request.getBody();
      }
      ```

    - 테스트

      ```java
      @Test
      public void testPostPerson() throws Exception {
        String json = objectMapper.writeValueAsString(new Person("andy", 33));
        this.mockMvc.perform(post("/person/body").contentType(MediaType.APPLICATION_JSON).content(json))
          .andDo(print())
          .andExpect(status().isOk())
          .andExpect(jsonPath("name").value("andy"))
          .andExpect(jsonPath("age").value(33));
      }
      ```

      

21. 핸들러 메소드 16부 @ResponseBody & ResponseEntity

    - @ResponseBody 를 사용하면 응답의 객체를  HttpMessageConvert 를 통해 텍스트로 전달할 수 있다.

    - @RestController 적용시 모든 핸들러 메소드에 적용

    - ResponseEntity 사용시 상태 코드나 헤더를 정의할 수 있음

      ```java
      @PostMapping("/hello")
      public ResponseEntity<Person> helloPerson(@RequestBody Person person, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
          return ResponseEntity.badRequest().build();
        }
      
        return ResponseEntity.ok().body(person).build();
      }
      ```

      

