# 데이터베이스

## 톡톡 DB

### 마케팅메시지 데이터베이스 : biztalk

- 마케팅메시지 테이블

  - bt_part

    ```mysql
    // 전체 파트너 수
    select count(*) from bt_part
    ```

  - bt_user

    ```mysql
    // 전체 유저 수
    select count(*) from bt_user 
    
    // 사용자정보 by 네이버아이디
    select * from bt_user where nv_id='nvqa_shop52'
    ```

  - bt_frnd

    ```mysql
    // 사용자가 소식받기 한 파트너 수
    select count(*) from bt_frnd where user_id='4MMDx' 
    
    // by 네이버아이디
    select user.*, frnd.svc_cd, frnd.part_id
    from bt_frnd frnd
    join bt_user user
    ON frnd.user_id=user.user_id
    where nv_id='nvqa_shop52'
    
    // 파트너의 소식받기 한 유저수
    select * from bt_frnd where part_id='wc8cz9'
    ```

  - bt_chat

    ```mysql
    // 사용자의 채팅방 목록
    select * from bt_chat
    where user_id='4MMDx'
    order by lst_ymdt desc
    
    // by 네이버아이디
    select chat.*, user.nv_id
    from bt_chat chat
    join bt_user user on chat.user_id=user.nv_id
    where user.nv_id='nvqa_shop52'
    
    // 파트너의 채팅방 목록
    select * from bt_chat where part_id='wc8cj8' order by lst_ymdt desc
    
    // by 네이버아이디 .. to be continued
    ```

  - bt_msg

    ```mysql
    // bt_msg 종류
    select cont_type from bt_msg group by cont_type
    ```

    

- 파트너센터 테이블

  - bm_acnt

  - bm_acnt_mgr

  - bm_mbr

    ```mysql
    // 파트너아이디 by 네이버아이디
    select nv_id_no from bm_mbr where nv_mbr_id='nvqa_shop52'
    ```

    

## Spring

### mybatis

- pom.xml

  ```xml
  <!-- mybatis -->
  <dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.3.0</version>
  </dependency>
  
  <dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis-spring</artifactId>
    <version>2.0.6</version>
  </dependency>
  ```

- src/main/resources/mybatis-config.xml

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE configuration
    PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-config.dtd">
  <configuration>
    
    <typeAliases>
      <typeAlias alias="ArticleRecord" type="io.github.positoy.testmybatis.model.ArticleRecord"/>
      <typeAlias alias="Article" type="io.github.positoy.testmybatis.model.Article"/>
    </typeAliases>
  
    <settings>
      <setting ../>
  	</settings>
  
  	<typeHandlers>
  		<typeHandler .. />
  	</typeHandlers>
    
    <mappers>
      <mapper resource="mybatis-mappers/board.xml"/>
    </mappers>
    
  </configuration>
  ```

- mybatis-mappers/board.xml

  ```xml
  <?xml version="1.0" encoding="UTF-8" ?>
  <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
  
  <mapper namespace="board">
  
    <select id="getList" resultType="ArticleRecord">
      select * from board
    </select>
  
    <insert id="post" parameterType="Article">
      insert into board (title,content) values (#{title}, #{content})
    </insert>
  
    <delete id="delete" parameterType="Integer">
      delete from board where id=#{id}
    </delete>
  
  </mapper>
  ```

  

- DBConfig.java

  ```java
  @Configuration
  public class DBConfig {
  	@Bean
    public BasicDataSource dataSource() {
      BasicDataSource dataSource = new BasicDataSource();
      dataSource.setDriverClassName(driverClassName);
      dataSource.setUrl(url);
      dataSource.setUsername(username);
      dataSource.setPassword(password);
      return dataSource;
    }
  
    @Bean
    public SqlSessionFactory sqlSessionFactory() throws Exception {
      SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
      sqlSessionFactoryBean.setDataSource(dataSource());
      sqlSessionFactoryBean.setConfigLocation(context.getResource("classpath:mybatis-config.xml"));
      sqlSessionFactoryBean.setMapperLocations(context.getResources("classpath:mybatis-mapper/**/*.xml"));
      
      return sqlSessionFactoryBean.getObject();
    }
  
    @Bean
    public SqlSessionTemplate sqlSessionTemplate() throws Exception {
      return new SqlSessionTemplate(sqlSessionFactory());
    }
  }
  ```

- BoardDao.java

  ```java
  @Repository
  public class BoardDao {
  
    @Autowired
    SqlSession sqlSession;
  
    public List<ArticleRecord> getList() {
      return sqlSession.selectList("board.getList");
    }
    
    ...
  ```

  

## DBMS

### mongo

- 연결

  ```bash
  mongo "mongodb://id@cluster0.vf3bm.mongodb.net" // mongo server
  mongo "mongodb+srv://id@cluster0.vf3bm.mongodb.net" // mongo dns server
  ```

- 데이터베이스

  ```mysql
  use myDatabase // 있으면 use, 없으면 create
  
  show dbs
  
  db.dropDatabase("dbName")
  ```

- 콜렉션

  ```mysql
  // use myDatabase
  
  db.createCollection("myCollection")
  
  show collections
  
  db.myCollection.drop()
  ```

- 도큐먼트

  ```mysql
  // use myDatabase;
  
  db.myCollection.insert({key:"value", extra:"data"})
  
  db.myCollection.find({extra:"data"})
  
  db.myCollection.update({extra:"data"},{$set:{extra:"data2"}})
  
  db.myCollection.remove({key:"value2"})
  ```

  

### MySQL

- https://www.mysqltutorial.org/getting-started-with-mysql/

- 데이터베이스

  ```mysql
  create database myDatabase
  
  show databases;
  
  use myDatabase;
  ```

- 테이블

  ```mysql
  // use myDatabase
  
  create table myTable{
    id unsigned int not null auto_increment
    username varchar(100) not null,
    email varchar(100) not null
  }
  
  show tables;
  
  drop myTable;
  
  describe myTable;
  
  show create table myTable;
  ```

- 레코드

  ```mysql
  // use myDatabase
  
  insert into myTable(username, email) values('andy', 'andy@naver.com')
  
  select * from myTable where username='andy' and email='andy@naver.com'
  
  update myTable set username='candy' where username='andy'
  
  delete from myTable where username='candy'
  ```

- JOIN (https://futurists.tistory.com/17)

  - (INNER) JOIN
    ![img](https://t1.daumcdn.net/cfile/tistory/243BF43A58340E0A06)

    

  - LEFT/RIGHT (OUTER) JOIN
    ![img](https://t1.daumcdn.net/cfile/tistory/26310B3458340C9F1C)

  - OUTER JOIN
    ![img](https://t1.daumcdn.net/cfile/tistory/2121D43658340EA733)

    