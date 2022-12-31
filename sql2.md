# SQL2

- 참고도서 `SQL 레벨업`

### 1.DBMS 아키텍처

- 기록장치의 딜레마 : 빠를 수록 비싸다. 결국 적당히 빠르고 적당히 빠른 저장소를 많이 사용할 수밖에 없다.
- 속도개선을 위한 구조
  - 쿼리 평가 엔진
  - 버퍼 매니저
  - 디스크 용량 매니저
  - 트랜잭션/락 매니저
  - 리커버리 매니저

- 속도를 개선하기 위한 버퍼

  *대부분의 시스템이 검색 비중이 크다고 가정하고 데이터캐시를 로그버퍼 보다 크게 할당한다.*
  *갱신이 많은 시스템은 튜닝이 필요하다.*

  - 데이터캐시 (SELECT)
  - 로그버퍼 (INSERT, UPDATE, DELETE)

- 추가 메모리 영역

  *정렬(ORDER BY)에 사용한다. 용량이 부족하면 디스크 스왑을 사용하므로 성능이 떨어진다.*

  - 워킹버퍼 (정렬)

#### 쿼리평가엔진

- 쿼리평가엔진
  - 파서 : SQL 문법, 테이블명 등 검증
  - 옵티마이저 (실행계획, 평가) : 많은 실행 계획을 생성하고, 각 계획을 비용 계산
  - 카탈로그매니저(통계정보) : 옵티마이저가 실행계획을 세울 때 테이블, 인덱스의 통계정보 제공
  - 플랜평가 : 가장 비용이 적은 실행계획 선택
- 카탈로그매니저 통계정보
  - 각 테이블의 레코드 수
  - 필드 수, 크기
  - 값의개수(cardinality), 값의분포(histogram), null 수
  - 인덱스 정보
- 카탈로그매니저에 통계 정보가 충분하지 않으면 옵티마이저가 실패할 수 있다.
  - 테이블의 데이터가 많이 바뀌면 카탈로그의 통계 정보도 업데이트 필요
  - MySQL 의 카탈로그 업데이트 명령어 : `ANALYZE TABLE {schema}.{table}`



#### 실행계획

- MySQL 실행계획 확인 방법 : `EXPLAIN EXTENDED {SQL Query}`
  - operation, name(target), rows 확인
- 풀스캔 과 인덱스스캔
  - PRIMARY 키를 이용하여 인덱스스캔을 수행하면 row 증가에 따라 검색 시간이 log 스케일로 증가
- 결합쿼리
  - 알고리즘 사용 (Nested loop, Sort merge, hash mapping)

- 한계
  - 옵티마이저의 실행계획은 완벽하지 않다
  - 힌트구를 이용하면, 옵티마이저에게 실행 계획을 수동으로 변경 지시할 수 있다



### 2. SQL 기초

- SQL 기초

  - IN 으로 OR 조건 설정

    ```sql
    SELECT name, address FROM addresses WHERE address IN ('인천시','수원시');
    ```

  - NULL

    ```sql
    SELECT name, address FROM addresses WHERE address IS NULL;
    SELECT name, address FROM addresses WHERE address IS NOT NULL;
    ```

  - GROUP BY

    - 홀케잌 자르기

    - 자른 그룹에 연산을 사용할 수 있음

      ```sql
      SELECT address, count(*) FROM addresses GROUP BY address;
      ```

  - HAVING

    - 그룹을 한번 더 필터할 수 있음

      ```sql
      SELECT address, count(*) FROM addresses GROUP BY address HAVING count(*)=1;
      ```

- 뷰 & 서브쿼리

  - 만들기

    ```sql
    CREATE VIEW addressCount (vaddr, vcnt) AS
    SELECT address, count(*) FROM addresses GROUP BY address;
    ```
  
- 사용하기
  
  ```sql
    SELECT vaddr, vcnt FROM addressCount;
  ```
  
    사실상 아래의 서브쿼리를 수행
  
    ```sql
    SELECT vaddr, vcnt
    FROM (SELECT address, count(*) FROM addresses GROUP BY address);
    ```
  
    서브쿼리를 사용하면 쿼리 변경이 줄어듦
  
    ```sql
    SELECT name FROM addresses WHERE name IN (SELECT name FROM addresses2);
    ```
  
- CASE 식

  - 식을 적을 수 있는 어디에나 사용 가능 (SELECT, WHERE, GROUP BY, HAVING, ORDER BY)

  - 검색/단순

    ```sql
    CASE	WHEN {평가식} THEN {식}
    			WHEN {평가식} THEN {식}
    			WHEN {평가식} THEN {식}
    			ELSE {식}
    END
    ```

    ```sql
    SELECT name, address,
    			CASE WHEN address='서울시' THEN '경기'
    			CASE WHEN address='인천시' THEN '경기'
    			CASE WHEN address='부산시' THEN '경남'
    			ELSE NULL END as district
    FROM addresses;
    ```

- 집합연산

  - UNION (합집합)

    ```sql
    SELECT * FROM Address1 UNION SELECT * FROM Address2;
    ```

  - INTERSECT (교집합)

    ```sql
    SELECT * FROM Address1 INTERSECT SELECT * FROM Address2;
    ```

  - EXCEPT (제외)

    ```sql
    SELECT * FROM Address1 EXCEPT SELECT * FROM Address2;
    ```

- 윈도우함수

  - 함수 OVER(X)

    - group by 처럼 가르지만 하나로 합치지 않음

    ```sql
    SELECT address COUNT(*) OVER(PARTITION BY address) FROM Addresses;
    SELECT name, age, RANK() OVER(ORDER BY age DESC) AS rnk FROM Addresses;
    ```

- Multi-row insert

  ```sql
  INSERT INTO Addresses(name, phone, address, sex, age)
  VALUES
  ('인성', '0102223333','서울시','남',30),
  ('인성', '0102223333','서울시','남',30),
  ('인성', '0102223333','서울시','남',30);
  ```

  



### isolation level

- https://www.postgresql.kr/blog/pg_phantom_read.html

| level            | 동작방식                                               | 단점                                                        |
| ---------------- | ------------------------------------------------------ | ----------------------------------------------------------- |
| read uncommitted | 커밋되지 않은 변경사항이 다른 트랜잭션에 노출됨        | dirty read                                                  |
| read committed   | 커밋되지 않은 변경사항이 다른 트랜잭션에 노출되지 않음 | 다른 트랜잭션은 과거의 데이터를 봄                          |
| repeatable read  | id 가 보다 작은 트랜잭션의 변경사항을 수용함           | - phantom read 발생<br />- phantom read 방지 위해 쓰기 방지 |
| Serializable     | 모든 트랜잭션의 변경사항 정합성을 맞춤                 | 너무 느림                                                   |

