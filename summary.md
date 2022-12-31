# Redis

- Remote Dictionary Server
- KEY:VALUE 구조로 데이터를 수급하는 In-memory DB (단순, 빠름)
  - KEY : 4.0.7 버전 이후로 64비트를 제공
  - VALUE : 타입으로 String, BitMap, Hash, List, Set, ... 제공
- 클러스터 내 데이터 형태를 유지하고 경합문제 해결 위해 자체 VALUE 타입 제공 / Single Threaded
- 주의사항
  - Single-Threaded 이므로 O(n) 수행시간을 충족하지 않는, keys, flush, getAll 명령 사용에 주의
  - Memory 파편화 주의 (필요한 용량보다 큰 메모리 사용해야 함)
  - Swap 에 의한 성능 지연이 있음 주의
  - replication 생성을 위해 process fork 시 용량이 부족하여 서버가 죽을 수 있음
- 관련주제
  - redis 를 저장소처럼 : redis persistant
  - 주기적인 scale out, backup : redis cluster
  - 부하분산 : constant hashing
  - in-memory 만 사용하는 data grid : spring gemfire, hazlecast



