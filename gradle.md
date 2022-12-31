# Gradle

### Basics

- 빌드 시스템 (의존성 해결, 컴파일, 패키징, 테스트, 배포 자동화 등 포함)

- gradle wrapper https://gradle-initializr.cleverapps.io/

- Groovy,Kotlin 언어를 이용하여 빌드 설정 (settings.gradle, build.gradle)

- gradle

  ```bash
  $ brew install gradle // 설치
  $ gradle init --type java-application // 프로젝트 생성
  $ gradle projects // 프로젝트 목록
  $ gradle tasks // 태스크 목록
  ```

- gradle wrapper https://gradle-initializr.cleverapps.io/

  ```groovy
$ ./gradlew build
  $ ./gradlew build --info
  $ ./gradlew clean
  $ ./gradlew tasks --all
  // plugins { id("com.dorongold.task-tree" version "1.4")} 추가필요
  $ ./gradlew build taskTree
  $ ./gradlew dependencies
  $ ./gradlew build --refresh-dependencies
  ```

- gradle.build

  ```bash
  apply plugin : "java" // java 프로젝트와 관련된 task, class 를 추가해줌
  
  
  ```

  

### Dependencies and Configurations

### Tasks



- 설명

  - 빌드 시스템
  - Groovy 또는 Kotlin 으로 개발 명세를 작성할 수 있음 (각각, build.gradle / build.gradle.kts)

- Gradle 명령어

  ```bash
  $ brew install gradle // 설치
  $ gradle init --type java-application // 프로젝트 생성
  $ gradle projects // 프로젝트 목록
  $ gradle tasks // 태스크 목록
  ```

- Gradle Wrapper 명령어

  - 환경과 독립적인 동작환경 제공

  - gradlew 포함된 패키지를 생성할 수 있음 https://gradle-initializr.cleverapps.io/

  - 명령어

    ```bash
    $ ./gradlew build
    $ ./gradlew build --info
    $ ./gradlew clean
    $ ./gradlew tasks --all
    $ ./gradlew build taskTree
    // plugins { id("com.dorongold.task-tree" version "1.4")} 추가필요
    $ ./gradlew dependencies
    $ ./gradlew build --refresh-dependencies
    ```

- 개념
  - plugin : 외부에서 import 할 수 있는 자동화 작업 단위. Plugin 인터페이스의 구현체이며, `build.gradle`에 추가하면 새로운 task, domain objects, convention 을 사용할 수 있다. (예, compileJava, sourceSets)
    - binary
    - Script
  - Project
    - Task (clean, build, run, ...)
    - Domain Objects
  - sourceSet
  
- 기타

  - 인코딩 이슈 해결
  - 의존성 라이브러리를 포함한 jar 를 생성할 때 플러그인 사용 [shadow jar](https://plugins.gradle.org/plugin/com.github.johnrengelman.shadow) 


## Tasks

- `gradle blah`로 실행할 수 있는 작업 단위
  - group, description : `gradles tasks`에 출력되는 task 정보
  - configuration phase : task 실행 전에 호출되는 설정부
  - execution phase : 실제로 동작하는 부분. doFirst, doLast 는 configuration 이후에 호출되며 실행부의 앞뒤로 동작을 append 함.
  ```groovy
  task hello(group: 'greeting', description:'Greets you.') {
    ...
  }

  task hello {
      group 'greeting'
      description 'greets you.'

      // configuration phase
      println('configuration here')
      ext.greeting = 'How\'s it going?'

      // execution phase --> 4312
      doLast{ print(1) }
      doLast{ print(2) }
      doFirst{ print(3) }
      doFirst{ print(4) }

      doLast{ println "\n$greeting" }
  }
  ```

- Task types

  - 확장할 수 있는 Task 프리셋?!
  - 이미 구현된 Task 의 properties 를 재설정해줌으로 Task 를 구현할 수 있음
  - 예 [Exec](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.Exec.html)

  ```groovy
  task runJar(type:Exec, dependsOn:jar) {
    executable 'java'
  args '-jar', "$jar.archivePath", 'Hello World'
  }
  ```
  
  - 예 [JavaExec](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.JavaExec.html)
    - `gradle tasks`
  
  ```groovy
  task run(type:JavaExec, dependsOn:classes) {
    main 'com.naver.talk.batch.Main'
    classpath sourceSets.main.runtimeClasspath
    args 'Hello World'
  }
  ```
  
- skip task

  ```groovy
  task hello {
    onlyIf{true}
    println 'configuration phase always executed'
  } << {
    println 'this doesn\'t get printed when hello disabled'
  }
  hello.enabled=falses
  ```

- skip up-to-date

  ```groovy
  
  ```

  

- dependsOn 참조할 때 먼저 선언된 task 명만 인지할 수 있지만, 문자열로 전달하면 나중에 선언된 task 를 참조할 수 있음



- 참고
  - http://www.devkuma.com/books/pages/454
  - https://ddmix.blogspot.com/2019/10/get-used-to-gradle.html
  - https://proandroiddev.com/writing-dsls-in-kotlin-part-1-7f5d2193f277