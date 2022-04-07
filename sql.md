# SQL

### tip

#### charset

- 대소문자 비교가 필요할 때는 `collate`를 `utf8_bin` 으로 설정
  ```sql
  CREATE TABLE xx_new_table (
  user_id VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '유저 아이디',
  part_id VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '파트너 아이디',
  )
  ```
- 이모지를 저장할 때에는 charset 을 `utf8mb4` 로 설정
  ```sql
  ALTER TABLE trgt_tbl MODIFY COLUMN trgt_col charset set utf8mb4 collate utf8_general_ci;
  ```
- 기본설정 확인

  ```sql
  SHOW VARIABLES LIKE 'c%';
  SHOW CHARACTER SET;
  SHOW FULL COLUMNS FROM trgt_tbl;
  ```

- 참고도서 `SQL 첫걸음`

### 1~3. 데이터베이스와 SQL

- SQL 종류 : DDL(definition, create), DML(manipulation - insert,delete,update,drop), DCL(control)

- DB 종류 : 계층형(파일시스템), 관계형(MySQL), 객체지향, XML,key-value(NoSQL)
- RDBMS : Oracle,MySQL,PostgreSQL,SQLServer,SQLite
- SQL : 왠만하면 표준 SQL 로 습관들이자 [MySQL 참고](https://dev.mysql.com/doc/refman/8.0/en/sql-statements.html)

### 4~8. 데이터 검색

- 데이터베이스 객체 : table, view, ...
- 예약어, 데이터베이스 객체명은 대소문자를 구별하지 않음
- 타입 : integer, char(n), varchar, date, time, ... [MySQL 참고](https://dev.mysql.com/doc/refman/8.0/en/data-types.html)

- 비교 연산자
  - =, <, <=, >, >=, <>
  - null 비교는 is null 사용 (= 연산자 사용 불가)
  - 적극적으로 괄호 사용. AND가 OR 보다 연산자 순위가 높음.
- 패턴매칭
  - like ~
    - 포함 : '%SQL%' / 접두어 'SQL%' / 접미어 '%SQL'
    - 한글자 : '\_SQL'
    - 정규표현식
  - 이스케이프
    - '\%', 'I''ts my life'

### 9. ORDER BY

- order by
- order by desc
- 문자열의 경우 `1 - 11 - 12 - 2` 순서로 정렬됨에 유의
- null 값은 mysql 기준 가장 작은 값으로 취급됨

### 10. ORDER BY COL1, COL2

- order by col1 desc, col2 asc
- col1 기준으로 정렬하고, 같은 값에 대해서 col2 로 정렬

### 11. LIMIT

- select \* from sample order by no desc limit 3
- (Pagination; 4페이지) select \* from sample order by no desc limit 10 offset 30
- MySQL, PostgreSQL 에서 사용 가능 (표준아님)

### 12. 수치연산

- 사칙연산(+-\*/%MOD), 함수(ROUND, TRUNCATE 등)

- 연산자 우선순위 적용

- select price, quantity, price\*quantity [as] amount from sample;

- as 는 생략할 수 있고, amount 는 "금액"(객체명), '금액'(문자열상수)로 대체할 수 있음

- null 사칙연산 결과는 모두 null

- select 구에서 지정한 별명을 where 구에서 사용 불가, order by 구에서 사용 가능.
  where → group by → having → select → order by 순서로 처리되기 때문.

  ```sql
  select price*quantity as amount from sample where amount >= 2000; // 오류
  select price*quantity as amount from sample where price*quantity >= 2000;
  select price*quantity as amount from sample order by amount desc;
  ```

### 13. 문자열 연산

- 붙이기 (+, ||, CONCAT), 부분문자열 (SUBSTRING), 여백제거(TRIM)
- 길이(CHAR_LENGTH, CHARACTER_LENGTH), 바이트길이(OCTET_LENGTH)

- 같은 문자열도 character set 설정에 따라서 바이트 길이가 달라질 수 있음 (EUC-KR 은 한글 2바이트, UTF-8은 3바이트)

### 14. 날짜 연산

- 데이터베이스마다 시간 타입의 종류가 다름 (DATE, TIME, DATETIME)
- CURRNET_TIMESTAMP, CURRENT_DATE, CURRENT_TIME // 현재 시간을 확인하는 인수가 없는 함수
- CURRENT_DATE + INTERVAL 10 YEAR/MONTH/DAY/HOUR/MINUTE/...

### 15. CASE 문으로 데이터 변환하기

- select a, CASE when a=1 then '남자' when a=2 then '여자' else '미지정' END from sample
- select a, CASE a when 1 then '남자' when 2 then '여자' else '미지정' END from sample
- null 은 비교연산자 = 사용이 불가능하여 1번의 경우 when a is null 처럼 써야하고 2번은 불가능
- null 경우 다음처럼 쓸 수 있음
  - select a, CASE when a is null then 0 else a END from sample
  - select a, COALESCE(a,0) from sample
- ELSE 를 기술하지 않으면 ELSE NULL 로 간주 됨

### 16. INSERT

- insert into sample values(val1, val2, val3, ...);
- insert into sample(col1, col2, col3, ...) values(val1, null, DEFAULT, ...);
- 값을 지정하지 않으면 default 값이 삽입되지만, 명시적으로 default 값을 넣을 수 있음
- desc sample; //테이블 타입 확인

### 17. DELETE

- delete from sample whrere 조건

### 18. UPDATE

- update sample set col1=val1, col2=val2, ... where 조건
- update sample set no=no+1 // 모든 행의 no 열 값 1 증가
- set 구의 연산 순서
  - update sample set no=no+1, a=no;
  - update sample a=no, no=no+1;
  - MySQL에서는 갱신식 안에서 처리 순서 영향이 있어서 두 결과가 다르고, Oracle 에서는 동일함

### 19. 물리삭제와 논리삭제

- 물리삭제 : delete from sample where no=3;
- 논리삭제 : update set del_yn=1 where no=3;

### 20. COUNT

- select count(\*), count(name) from sample
- 집합의 원소 수를 구한다
- NULL 무시
- distinct : 중복제거
  - select distinct name from sample
  - select count(distinct name) from sample

### 21. COUNT 외 집계함수

- select SUM(quantity), AVG(quantity), MIN(quantity), MAX(quantity) from sample;
- NULL 무시

### 22. GROUP BY

- select \* from sample group by name, age, ...

- 집계함수를 사용하지 않으면 의미가 없음

  - select count(name) from sample group by name

- where 구에서는 집계함수를 사용할 수 없음. having 구를 사용.
  where → group by → having → select → order by 순서로 처리되기 때문.

  ```sql
  select name, count(name) from sample where count(name)=1 group by name; // 오류
  select name, count(name) as cn from sample group by name having cn=1;
  ```

- group by 에 지정되지 않은 열은 집계 함수를 사용해야 함.
  집계 함수를 사용하지 않을 경우 값이 모호하며, DBMS 에 따라서 에러 발생.

  ```sql
  select min(no), name, sum(quantity) from sample group by name;
  select no, quantity from sample group by name, quantity;
  ```

- 정렬

  ```sql
  select name, count(name), sum(quantity) from sample group by name order by sum(quantity);
  ```

### 23. 서브쿼리

- delete from sample where a=(select min(a) from sample);
- select 결과를 쿼리의 일부로 참조하는 것
  - MySQL은 예제 실행시 에러. insert, update, delete 의 서브 쿼리에서 동일한 테이블 사용 불가
  - MySQL은 as x 로 서브쿼리 결과를 인라인 뷰로 처리하고 update 가능
  - 또는 클라이언트 변수 사용, set @min=(select min(a) from sample); delete from sample where a=@min;
- 서브쿼리 결과 형태
  - 스칼라
  - 테이블

### 24. 상관 서브쿼리

- exists, not exists (존재여부 - 스칼라,테이블 무관)
  - update set val='있음' from table1 where exists (select \* from table2 where no2=no)
  - update set val='없음' from table1 where not exists (select \* from table2 where no2=no)
- 상관서브쿼리
  - 서브쿼리에 부모 쿼리 테이블과의 관계가 나타남 no2 = no 또는 table2.no2=table1.no
  - 서브쿼리만 떼어내어 실행 불가
- in, not in (집합관계)
  - select \* from table1 where no in (3,5)
  - select \* from table1 where no in (select no2 from table2)
  - null 은 비교할 수 없고, is null 사용해야 함.

### 25~26. 데이터베이스 객체

- 데이터베이스 객체 : 테이블, 뷰, 인덱스, 프로시저 등
- DDL
  - create/drop database database1 : 스키마
  - create/drop/alter table table1( ... ) : 테이블
  - truncate table table1 (=delete from table1) : 테이블의 모든 레코드 삭제
  - alter table add/drop/modify
    - alter table table1 add newcol integer
    - alter table table1 drop newcol
    - alter table table1 change old_col_name new_col_name text not null (v 5.6)
  - MySQL 버전에 따라서 명령이 다르므로 공식문서 참조 [MySQL 참고](https://dev.mysql.com/doc/refman/5.6/en/sql-statements.html)

### 27. 제약

- 열 제약 추가/삭제 - not null, unique

  - alter table students modify no integer not null
  - alter table students modify no integer

- 복수열(테이블) 제약 추가/삭제 - primary key

  - alter table add constraint pkey_sample primary key(no, id)
  - alter table drop constraint pkey_sample
  - alter table drop primary key

- 제약 이름

  - ​ constraint pkey_sample primary key (col1, col2)

    ```sql
    create table students (
      no integer not null,
      id varchar(30) not null,
      name varchar(30) not null,
      constraint pkey_sample primary key (no, id)
    );
    ```

- 기본키 (primary key)

  - not null 필수

### 28. 인덱스 구조

- 기본키는 기본 값으로 인덱스를 구성함
- 인덱스 : 이진탐색을 위해 준비된 정렬된 데이터. 기본키는 중복이 없으므로 인덱스를 만들기 적합.
- 데이터베이스 객체 또는 테이블로 존재.

### 29. 인덱스 작성과 삭제

- create index index_name on table_name (col1, col2, ...)
- drop index index_name
- create table table1 ( ..., KEY `ink4_bt_frnd` (`lst_noti_ymdt`))

- 테이블을 삭제하면 인덱스는 자동 삭제
- 인덱스를 만들면 insert 처리 속도가 조금 떨어짐
- explain {SQL명령} : 실행계획 확인 (possible_keys 컬럼에서 사용하는 인덱스 확인 가능)

### 30. 뷰 작성과 삭제

- create view view_name as {select명령}
- select \* from view_name
- drop view view_name
- 뷰 : select 명령을 데이터베이스 객체로 저장한 것
- 뷰는 가상공간이므로 select 명령에서만 사용

### 31. 집합연산

- 합집합

  - (select _ from table1) union (select _ from table2) union ...

- 중복허용 합집합

  - (select _ from table1) union all (select _ from table2) union ...

- 열의 갯수, 자료형이 일치하는 경우 가능

- 피연산자의 순서가 결과에 영향을 미치지 않음

- 피연산자가 아닌 전체 결과에만 order by 적용 가능

  ```sql
  (select name from students) union (select nickname as name from users) order by name desc
  ```

- 교집합 INTERSECT

- 차집합 EXCEPT

### 32. 테이블 결합

- 교차결합 (cross join)
  - select \* from alphabets, numbers : a1, a2, ..., b1, b2, ...
  - 두 집합 원소들의 곱집합(cartesian product)
  - select count(\*) from alphabets, numbers : alphabets, numbers 의 count 곱과 동일
- 내부결합
  - select \* from product, remains where product.id=remains.id
- JOIN (MySQL Only)
  - 내부결합 (inner join) : 연결이 있는 것만 보여줌
    - select m.name, p.name from product p inner join maker m on p.makerId=m.id
    - foreign key
      - 위에서 makerId 는 maker 테이블에서 primary key, product 테이블에서 foriegn key
  - 외부결합 (left/right join) : 기준되는 테이블은 모두 보여줌
    - select p.name, r.count from product p left join remains r on p.id=r.productId
  - MySQL이 아닌 RDBMS 에서는 특수 기호로 외부결합을 실행할 수 있음

### 33. 관계형 모델

- 관계형모델은 관계대수에 근거함
- 관계형모델의 관계는 테이블간이 아닌, 테이블 자체를 뜻함!
- 관계대수 : releation 간의 연산이 집한연산에 대응한다 - relation(테이블), tuple(행), attribute(열)
  - 하나 이상의 테이블로 연산
  - 테이블과 테이블의 연산 결과는 테이블
    (union, union all, except, intersect, cross join, selection, projection, join)
  - 연산을 중첩 구조로 실행할 수 있음

### 34. 데이터베이스 설계

- 테이블정의서
  - 타입
    - 숫자는 부담없이 사용
    - 문자열은 추후 숫자로 변경이 어려우니 신중하게
    - 정해진 리터럴을 사용하는 컬럼은 CHECK 제약 사용 (정합성 증가)
    - VARCHAR 는 최대 수천바이트 가능
    - 용량이 클 데이터는 LOB(Large Object) 타입 사용
  - 기본키
    - 마땅한 기본키가 없을 때에는 AUTO_INCREMENT 사용
    - AUTO_INCREMENT 사용하는 열은 유일성을 지정해야 함 (PRIMARY KEY 또는 UNIQUE)
- ER다이어그램
  - Entity(테이블,뷰) 의 관계
  - ER은 Foreign Key 설정에 활용할 수 있음
  - Foreign Key 제약을 설정하면 번거로워져서 사용하지 않기도 함

### 35. 정규화

- 테이블을 올바르게 변경하고 분할하는 것 (속도,용량 효율화 / 정합성 증가)

- "하나의 데이터는 한 곳에 있어야 한다"

- 제1정규화

  - 하나의 셀에 하나의 값만 저장 (행이 늘어남)

    ```
    [주문]
    //변경전
    "당근 2개 사과 3개"

    //변경후
    "당근" 2
    "사과" 3
    ```

  - 중복제거

    ```
    // 변경후
    [주문]
    주문번호, 날짜, 성명, 연락처

    [주문상품]
    주문번호, 상품코드, 상품명, 개수
    ```

  - 기본키 지정

- 제2정규화

  - 기본키로 특정되는 데이터, 불가능한 데이터를 분리

    ```
    // 주문번호, 상품코드, 상품명, 개수
    primary key(주문번호, 상품코드)인 경우 → '상품명'은 특정할 수 있지만 '개수'는 특정 불가하므로 분리
    ```

- 제3정규화

  - 기본키 외의 부분에서 중복이 없는지 확인

### 36. 트랜잭션

- start transaction (MySQL)
- commit
- rollback
- 복수의 sql 명령을 수행하는 상황에서, 실패한 쿼리가 발생했을 때 rollback 가능
