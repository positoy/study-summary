# [자바 스프링 프레임워크](https://www.inflearn.com/course/%EC%8A%A4%ED%94%84%EB%A7%81-%ED%94%84%EB%A0%88%EC%9E%84%EC%9B%8C%ED%81%AC_renew)

## 1. 스프링 동작방식 이해

- 스프링은 서블릿 컨테이너의 확장
- Request 를 다양한 객체들이 협업하여 처리하고 Response 를 생성하여 응답
- 다양한 객체 : beans
  - 객체들의 의존성이 너무 복잡하고 생성/소멸 비용이 크다 → Dependency Injection, GenericXmlApplicationContext
  - XML 작성하는 것도 복잡하다 → AnnotationConfigApplicationContext (내부적으로 ComponentScan 하는 bean 을 xml 로드)
  - 객체들의 역할도 깔끔하게 나누자 → Controller, Service, Repository
- 문제들을 해결하는 DispatcherServlet 의 도입 (web.xml 정의)



## 2. 의존객체

### 2-1. DI (Dependency Injection)

- 다양한 Service 객체가 동일한 DAO를 사용하는 경우
- 다양한 Controller 객체가 동일한 Service 를 사용하는 경우



### 2-2. 다양한 의존객체 주입

- 서비스 로직에서 구현한 클래스들의 의존성을 해결하려니 문제점이 많음

  - 복잡한 의존관계
  - 인스턴스의 생성/소멸 비용

- xml 에 클래스들의 의존관계를 정의해두고 컨텍스트에서 꺼내쓰자 (bean 탄생)

  - 의존관계는 알아서 해결해 줌
  - 기본값으로 인스턴스는 싱글턴으로 관리 되어 생성/소멸 비용이 중복되지 않음

- 생성방식

  1. Factory

     ```xml
     <bean id="studentFactory"
           class="project.StudentFactory"
           factory-method="getInstance"/>
     ```

  2. 생성자

     ```xml
     <bean id="reigsterService" class="project.StudentRegisterService">
       <constructor-arg ref="studentDao"/>
     </bean>
     ```

     ```xml
     <bean id="reigsterService" class="project.StudentRegisterService">
       <constructor-arg type="long" value="10"/>
     </bean>
     ```

  3. Setter

     - 객체

       ```xml
       <bean id="reigsterService" class="project.StudentRegisterService">
         <property name="testDao">
           <ref bean="implTestDao"/>
         </property>
       </bean>
       ```

     - 값

       ```xml
       <bean id="studentDao" class="project.StudentDao">
         <property name="url" value="jdbc:/...">
         <property name="id" value="root">
         <property name="pw" value="1234">
       </bean>
       ```

     - 리스트

       ```xml
       <bean id="reigsterService" class="project.StudentRegisterService">
         <property name="students">
           <list>
             <value>andy</value>
             <value>brian</value>
             <value>cathy</value>
           </list>    
         </property>
       </bean>
       ```

     - 맵

       ```xml
       <bean id="studentDao" class="project.StudentDao">
         <property name="info">
           <map>
             <entry>
               <key><value>url</value></key>
               <value>jdbc:/mysql...</value>
             </entry>
             <entry>
               <key><value>id</value></key>
               <value>root</value>
             </entry>
             <entry>
               <key><value>pw</value></key>
               <value>1234</value>
             </entry>
           </map>
         </property>
       </bean>
       ```

     - properties

       ```xml
       <bean id="urlMapping" class="org.springframework.web...SimpleUrlHandlerMapping">
         <property name="mappings">
           <props>
             <prop key="/login/login.mw">loginController</prop>
           </props>
         </property>
       </bean>
       ```

       

### 2-3. 스프링 설정 파일 분리

- 변경전

  ```java
  GenericXmlApplicationContext context
    = new GenericXmlApplicationContext("classpath:context.xml");
  ```

- 변경후

  - 방법1

    ```java
    String[] contexts = ["classpath:service.xml", "classpath:db.xml", "classpath:info.xml"]
    GenericXmlApplicationContext context = new GenericXmlApplicationContext(contexts);
    ```

  - 방법2

    ```xml
    <!-- context.xml -->
    <?xml .../?>
    <beans xmlns="...">
    	<import resource="classpath:service.xml"/>
    	<import resource="classpath:db.xml"/>
    	<import resource="classpath:info.xml"/>
    </beans>
    ```

    ```java
    GenericXmlApplicationContext context
      = new GenericXmlApplicationContext("classpath:context.xml");
    ```

  

### 2-4. 의존객체 자동 주입

- @Autowired

  ```java
  public class StudentService {  
    private StudentDao studentDao;
    
    @Autowired
    StudentService(StduentDao studentDao) {
      this.studentDao = studentDao;
    }
  }
  ```

  ```xml
  <!-- context.xml -->
  <?xml .../?>
  <beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.1.xsd
      http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.3.xsd">
  
    <context:annotation-config/>
    <bean id="studentDao" class="project.StudentDao"/>
    <bean id="studentService" class="project.StudentService">
      <!-- <constructor-arg ref="studentDao"/> -->
    </bean>    
  </beans>
  ```

- @Resource
  
- 객체의 타입이 아니라 name 을 보고 resolve 수행
  
- 제한사항

  - 생성자에는 제약없이 사용 가능
  - 멤버변수, 메소드에 사용하려면 기본생성자가 꼭 명시되어야 함



### 2-5. 의존객체 선택

- bean 이 없을 때 무시

  ```java
  @Autowired(required=false)
  StudentDao studentDao;
  ```
  
- 동일한 타입의 bean이 여러개일 때

  ```xml
  <bean id="mathStudentDao" class="project.StudentDao"></bean>
  <bean id="physicsStudentDao" class="project.StudentDao"/>
  <bean id="literatureStudentDao" class="project.StudentDao"/>
  ```
  - 방법1 : 변수명과 동일한 bean 을 선택

      ```java
      @Autowired
      StudentDao mathStudentDao;
      ```

  - 방법2 : qualifier 이용하여 선택

      ```java
      @Autowired
      @Qualifier("math")
      StudentDao studentDao;
      ```

      ```xml
      <bean id="mathStudentDao" class="project.StudentDao"></bean>
        <qualifier value="math"/>
      </bean>
      ```

- @Inject

  - @Autowired 와 유사지만 required 미지원

      ```java
      @Inject
      @Named(value="mathStudentDao")
      StudentDao studentDao;
      ```




## 3. 설정 및 구현

### 3-1. 생명주기

- 빈 객체의 생명주기는 스프링 컨테이너의 생명주기와 같이 함

- 빈 객체의 생성/소멸 작업 추가

  - 방법1. InitializingBean, DisposableBean 구현

    ```java
    public class StudentRepository implements InitializingBean, DisposableBean {
        @Override
        public void destroy() throws Exception {
    			// do something
        }
    
        @Override
        public void afterPropertiesSet() throws Exception {
    			// do something
        }
    }
    
    ```

  - 방법2. 빈에 init-method, destroy-method 명시

    ```xml
    <bean id="studentRepository"
          class="project.StudentRepository"
          init-method="init"
          deinit-method="destroy"/>
    ```

    

### 3-2. 어노테이션을 이용한 스프링설정

- @Configuration, @Bean

  ```java
  AnnotationConfigApplicationContext context
    = new AnnotationConfigApplicationContext(MemberConfig.class);
  ```
  
  ```java
  @Configuration
  public class MemberConfig {
    @Bean
    // <bean id="studentDao" class="project.StudentDao"/>
    public StudentDao studentDao() {
      return new StudentDao();
    }
    
    @Bean
    public StudentService studentService(StudentDao studentDao) {
      return new StudentService(studentDao());
    }
  }
  ```


- @Configuration 분리하기
  - 방법1. 하나의 Configuration 에서 다른 Configuration 클래스를 포함

    ```java
    @Configuration
    @Import({MemberConfig2.class, MemberConfig3.class})
    public class MemberConfig {
      // beans
    }
    ```
  
  - 앗

    ```java
    AnnotationConfigApplicationContext context
      = new AnnotationConfigApplicationContext(MemberConfig1.class, MemberConfig2.class);
    ```



### 3-3. 웹프로그래밍 설계 모델

- model1 : View + Model
- model2 : Model + View + Controller (스프링)
  - web.xml 에 DispatcherServlet 클래스와 servlet-context.xml 파라미터 설정
    
  - DispatcherServlet 이 모든 서블릿을 대체하는 슈퍼 서블릿
    
    - init-param 이용해서 servlet-context.xml 을 참조
      - annotation 사용을 가능케 함 (<annotation-driven/>)
      - ComponentScan
    
    ```xml
    <!-- web.xml -->
    <servlet>
      <servlet-name>DispatcherServlet</servlet-name>
      <servlet-class>org.springframework...DispatcherServlet</servlet-class>
      <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/spring/appServlet/servlet-context.xml</param-value>
      </init-param>
    </servlet>
    <servlet-mapping>
      <servlet-name>DispatcherServlet</servlet-name>
      <url-pattern>/</url-pattern>
    </servlet-mapping>
    
    ```
    
    - DispatcherServlet 동작
      - HandlerMapping → Controller 반환
      - HandlerAdapter → url 을 처리할 수 있는 Controller method 반환
      - Controller method → mav(model and view) 반환
      - ViewResolver → 주어진 mav를 처리할 수 있는 view 반환
      - View → response 반환
    
    ![image-20210106153847278](/Users/positoy/Library/Application Support/typora-user-images/image-20210106153847278.png)

### 3-4. Controller 객체 구현

- Request Parameter

  - 커맨드 객체

    - 스프링에서 변환하여 할당
    - checkbox 의 경우 List 로 자동변환 가능
  
    ```java
    @PostMapping("/login")
    public String login(Member member) { // view에서는 ${member.id} 사용
    Member mem = users.getByLoginInfo(member.getId(), member.getPw());
      ...
  }
    ```
  
  - RequestParam
  
    ```java
    @PostMapping("/login")
    public String login(@RequestParam String id, @RequestParam String pw) {
      Member member = users.getByLoginInfo(id, pw);
      ...
    }
    ```
    
  - HttpServletRequest
  
	  ```java
    @PostMapping("/login")
    public String login(HttpServletRequest request) {
      Member member = users.getByLoginInfo(request.getParameter("id"), request.getParameter("pw"));
      ...
    }
    ```
  
- @ModelAttribute

  - Model 에 주어진 이름의 attribute 를 추가

  - 메소드에 사용 : 모든 메소드의 반환 모델에 attribute 추가

    ```java
    public class MemberController {
      
      @ModelAttribute("serverTime")
      public String getServerTime(Locale locale) {
        Date date = new Date();
        DateFormat dateformat = DateFormat.getDateTimeInstance(DateFormat.LONG, );
        return dateformat.format(date);
      }
    }
    ```

  - 메소드 파라미터에 사용 : View 에서 사용하는 변수명 변경

    ```java
    @PostMapping("/login")
    public String login(@ModelAttribute("mem") Member member) { // view에서는 ${mem.id} 사용
      Member mem = users.getByLoginInfo(member.getId(), member.getPw());
    }
    ```

- ModelAndView

  - ModelAndView 객체를 반환 가능

    ```java
    @PostMapping("/login")
    public ModelAndView login(Member member) {  
      ModelAndView mav = new ModelAndView();
      mav.addObject("id", member.getId());
      mav.addObject("pw", member.getPw());
      mav.setViewName("loginOK");
    
      return mav;
    }
    ```

    



## 4. 연결

### 4-1. 세션, 쿠키

- session (서버에 저장)

  - 세션저장

    ```java
    // HttpServeletRequest 아규먼트에서 session 얻기
    @PostMapping("/login")
    public String login(HttpServletRequest request, String id, String password) {
      HttpSession session = request.getSession();
    	session.setAttribute("member", members.findByLogin(id, password));
      return "/member/loginok";
    }
    
    //아규먼트에서 session 을 바로 얻기
    @PostMapping("/login")
    public String login(HttpSession session, String id, String password) {
    	session.setAttribute("member", members.findByLogin(id, password));
      return "/member/loginok";
    }
    ```

  - 세션 삭제

    ```java
    @PostMapping("/logout")
    public String logout(HttpSession request) {
    	session.invalidate()
      return "/member/logoutOk";
    }
    ```

    

- cookie (클라이언트에 저장)

  - 응답 헤더에 쿠키 추가

    ```java
    @PostMapping("/login")
    public String login(HttpSession session, String id, String password, HttpServletResponse response) {
      Member member = members.findByLogin(id, password);
      session.setAttribute("member", member);
    
      Cookie genderCookie = new Cookie("gender", member.getGender());
      genderCookie.setMaxAge(60*60*24*30);
      response.addCookie(genderCookie);
    
      return "/member/loginok";
    }
    ```

  - 요청 헤더의 쿠키 확인

    ```java
    @PostMapping("/showroom")
    public String showroom(
      Showroom showroom, @CookieValue(value="gender", required=false) Cookie 
      genderCookie) {
      if (genderCookie != null)
        showroom.setGender(genderCookie.getValue());
      return "/showroom";
    }
    ```



### 4-2. 리다이렉트, 인터셉트

- Redirect

  ```java
  @GetMapping("/users/modify")
  public String modifyUser(HttpSession session, Model model) {
    Member member = session.getAttribute("member");
  
    if (member == null) {
      return "redirect:/";
    } else {
      model.addAttribute("member", member);    
    }
    return "/users/modify";
  }
  ```

- Interceptor

  - 요청이 Controller 에 도달하기 전/후에 Interceptor에서 검증하여 redirect 가능
  - 중복된 redirect 코드를 제거할 수 있음
  - preHandle, postHandle, afterCompletion

  ```java
  public class EventInterceptor implements HandlerInterceptor {
  
      @Override
      public boolean preHandle(...) throws Exception {
          if (request.getSession() != null &&
              request.getSession().getAttribute("member") != null)
              return true;
  
          response.sendRedirect(request.getContextPath()+"/");
          return false;
      }
  ```

  ```java
  @Configuration
  public class WebConfig implements WebMvcConfigurer {
      @Override
      public void addInterceptors(InterceptorRegistry registry) {
          registry.addInterceptor(new EventInterceptor());
      }
  }
  ```

  

### 4-3. JdbcTemplate

- JDBC의 드라이버 로딩, DB연결, 자원해제를 간편하게 관리 가능

- JDBC

  ```java
  public int insert(Member member) {
    int result = 0;
    try {
      Class.forName(driver);
      private Connection conn = DriverManager.getConnection(url, id, pw);
      String sql = "insert into member (id, pw, mail) values(?,?,?)";
      PreparedStatement pstmt = conn.prepareStatement(sql);
      pstmt.setString(1, member.getId());
      pstmt.setString(2, member.getPw());
      pstmt.setString(3, member.geteEmail());
      result = pstmt.executeUpdate();
    } catch (Exception e) {
      e.printStackTrack();
    } finally {
      try {
        if (pstmt != null) pstmt.close();
        if (conn != nuill) conn.close();
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    
    return result;
  }
  ```

- JdbcTemplate

  - update
    - template.update(sql, params...)
    - template.update(new PreparedStatementCreator(){ ... })
    - template.update(sql, new PreparedStatementSetter(){ ... })
  - select
    - template.query(sql, new Object[]{ ... }, new RowMapper<Member>(){. ...})
    - template.query(new PreparedStatementCreator() { ... }, new RowMapper<Member>{ ... })
    - template.query(sql, new PreparedStatementSetter() { ... }, new RowMapper<Member> { ... })

  ```java
  public class MemberDao {
    
    private DriverManagerDataSource dataSource;
    private JdbcTemplate template;
    
    public MemberDao() {
      dataSource = new DriverManagerDataSource();
      dataSource.setDriverClassName(driver);
      dataSource.setUrl(url);
      dataSource.setUsername(id);
      dataSource.setPassword(pw);
      
      template = new JdbcTemplate();
      template.setDataSource(dataSource);
    }
    
    public List<Member> select(Member member) {    
      final String sql = "insert into member (id, pw, mail) values(?,?,?)";
      List<Member> members = template.query(sql,
        new PreparedStatement pstmt) throws SQLException {
          @Override
          public void setValues(PreparedStatement pstmt) throws SQLException {
            pstmt.setString(1, member.getId());
            pstmt.setString(2, member.getPw());
          }
      	}, new RowMapper<Member>() {
        @Override
        public Member mapRow(ResultSet rs, int rowNum) throws SQLException {
          return new Member(rs.getString("id"), rs.getString("pw"), rs.getString("email"));
        }
      });
      
      return members.isEmpty() ? null : members;
    }
  }
  ```



### 4-4. 커넥션풀(DBCP)

- https://d2.naver.com/helloworld/5102792

- DB 드라이버 로드, DB 연결 비용이 크기 때문에 커넥션풀을 유지

- Common DBCP, Tomcat-JDBC, BoneCP, HikariCP 등

- Common DBCP

- pom.xml

  ```xml
  <!-- Common DBCP -->
  <dependency>
    <groupId>commons-dbcp</groupId>
    <artifactId>commons-dbcp</artifactId>
    <version>1.4</version>
  </dependency>
  ```

- applicationContext.xml

  ```xml
  <bean id="dataSource" class="org.apache.commons.dbcp2.BasicDataSource"  
      destroy-method="close"
      p:driverClassName="${db.driverClassName }"
      p:url="${db.url}"
      p:username="${db.username}"
      p:password="${db.password}"
      p:maxTotal="${db.maxTotal}"
      p:maxIdle="${db.maxIdle}"
      p:maxWaitMillis="${db.maxWaitMills}""
  />
  ```

  

