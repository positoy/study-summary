### slf4j (simple logging facade for java)

- SLF4J API

  - 다양한 로깅 라이브러리를 동일한 인터페이스로 사용하게 해주는 인터페이스

    ```java
    static Logger logger = LoggerFactory.getLogger(MyClass.class);
    
    public static void test() {
        logger.info("string{}, float{}, int{}, char{}, date{} empty{}", "hello world", 1.123, 123, 'a', new Date());
    }
    ```

  - pom.xml

    ```xml
    <!-- https://mvnrepository.com/artifact/org.slf4j/slf4j-api -->
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>1.7.30</version>
    </dependency>
    ```

- SLF4J Binding

  - SLF4J 가 실제로 호출하는 로깅 라이브러리

  - API 와 버전을 맞춰야 함

    ```xml
    <!-- https://mvnrepository.com/artifact/org.slf4j/slf4j-log4j12 -->
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-log4j12</artifactId>
      <version>1.7.30</version>
    </dependency>
    ```

  - compile time 의 classpath 바인딩을 찾아서 의존성 해결

  - 없으면 로그 출력이 안됨 (nop), 2개 이상 있으면 하나가 선택되어 컴파일 됨 (duplicate)

  - 2개 이상의 바인딩이 있는 경우, exclusion을 사용하여 원하는 라이브러리 바인딩 가능

    ```xml
    <dependencies>
      <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <exclusions>
          <exclusion>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
          </exclusion>
        </exclusions>
      </dependency>
    ```

- LOG4J

  - 다양한 경로로 포맷 로그를 출력해주는 로깅 라이브러리

    - Loggers
    - 레벨이 설정되지 않으면 부모 로거의 레벨을 상속 받음
      - getRootLogger : 최상위 로거 / getLogger("com.foo.bar") : 자식 로거
    - Appenders
      - console 이나 DB, 서버 등으로 최종 로그가 전달되는 지점
      - Additive true 이면, 부모의 appender에도 내용 전달
    - Layouts
      - 로그 포멧 적용 가능
  
  - 1.2 configuration
  
    - http://logging.apache.org/log4j/1.2/
    
      ```xml
      <!DOCTYPE log4j:configuration PUBLIC "-//APACHE//DTD LOG4J 1.2//EN" "log4j.dtd">
      <log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
      	<appender name="console" class="org.apache.log4j.ConsoleAppender">
      		<layout class="org.apache.log4j.PatternLayout">
      			<param name="ConversionPattern" value="%d{yyyy-MM-dd HH:mm:ss.SSS} %X{userId} %-5p %c{2}.%M %m%n" />
      		</layout>
      	</appender>
      
      	<root>
      		<priority value="info" />
      		<appender-ref ref="console" />
      	</root>
      </log4j:configuration>
      
      ```
    
  - 2.x configuration
  
    - https://logging.apache.org/log4j/2.x/manual/configuration.html
    
  - log level
    <img src="http://myblog.opendocs.co.kr/wp-content/uploads/2015/03/log4j-1024x453.png" alt="log4j" style="zoom:50%;" />