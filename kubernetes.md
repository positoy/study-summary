### Docker

- docker 에 nginx 와 스프링 app 올리고 프록시 연결하기

```bash
apk add openjdk11-jdk
export JAVA_HOME = "/usr/lib/openjdk11"

git clone https://github.com/positoy/spring-boot-docker
cd spring-boot-docker
./mvnw package
docker build -t spring-boot-docker .

docker run -d --rm -p 8080:8080 spring-boot-docker --name web
docker run -d --rm -p 80:80 nginx --name nginx

docker network create myNetwork
docker network connect myNetwork web
docker network connect myNetwork nginx

docker exec -it web bash
$ vim /etc/nginx/conf/default.conf

http {
  server / {
    proxy_pass http://{web_ip}:8080;
  }
}

$ nginx -s reload
```



# Docker

![docker](https://www.bogotobogo.com/DevOps/Docker/images/DockerCheat/docker-lifecycle.png)  

#### 컨테이너 라이프사이클

```bash
$ docker pull {repository:tag}
$ docker run {repository:tag}
$ docker stop {containerId}
$ docker start {containerId}
$ docker pause {containerId}
$ docker unpause {containerId}
```



#### 컨테이너 확인

```bash
$ docker run -it --name {repository:tag} -v {hostPath:containerPath} -p {port:port} --network {networkName} {image}
$ docker exec -it {containerId} bash
$ docker attach
$ docker logs -f {containerId}
```



#### 컨테이너, 이미지 관리

```bash
$ docker images
$ docker rmi {imageId}
$ docker ps -a
$ docker rm {containerId}
```



#### 컨테이너 만들기

- Dockerfile

  - RUN 은 이미지 생성, CMD 는 프로세스 실행에만 사용
  - CMD 는 1 줄 이어야 함

  ```Dockerfile
  FROM alpine:latest
  RUN apk update && apk add figlet
  ADD ./message /message
  CMD cat /message | figelet
  ```

- 이미 만들고 레지스트리 저장

  ```bash
  $ docker build -t {repository:tag} .
  $ docker tag {imageId} {repository:tag}
  $ docker login
  $ docker push {remote repository:tag}
  ```



#### 네트워크

```bash
docker network ls 
docker network create {my-network}
docker network rm {my-network}
```
- none, host, bridge 네트워크
- 동일한 네트워크에 연결된 컨테이너들은 컨테이너 이름으로 통신할 수 있음
- bridge 네트워크는 외부로 포트를 공개할 수 있음



#### 컨테이너 API
- 환경변수로 전달
  ```bash
  docker run -it --name tag -e INTERVAL=10 {image}
  ```
- 컨테이너 볼륨에 저장
  ```bash
  # 저장
  save() {
    echo $COUNT > save.dat
    exit 0
  }
  trap save TERM
  
  # 복구
  COUNT=`cat save.dat`
  ```
- 퍼시스턴트 볼륨에 저장

  ```bash
  run -it --name tag -v `pwd`/data:/pv {image}
  
  PV=/pv/save.dat
  # 저장
  save() {
    echo $COUNT > $PV
    exit 0
  }
  trap save TERM
  
  # 복구
  COUNT=`cat $PV`
  ```




# Kubernetes

![kubernetes](https://monitoringlove.sensu.io/hubfs/Kubernetes%20architecture%20diagram.png)

- 워크로드 : 오브젝트의 카테고리 (container, pod, controller 그룹)
- 컨테이너 : 도커 이미지가 실행된 인스턴스
- 파드 : 컨테이너를 여러개 담고 있는 오브젝트
- 컨트롤러 : 파드의 실행 제어
- 설정 : 비밀번호 등 정보를 담는 시크릿 오브젝트
- 서비스 : 대표 IP 주소를 취득하여 파드에 부하분산
- 스토리지 : 퍼시스턴트 스토리지를 연결하기 위한 추상화 오브젝트



#### 클러스터 정보

```bash
$ kubectl cluster-info
$ kubectl get all
$ kubectl get pod|deploy|..
$ kubectl get pod -o wide // 파드의 클러스트 네트워크 상 ip 주소
$ kubectl describe {podName}
```



#### Single Pod

```bash
$ kubectl run hello-world --image=hello-world -it --restart=Never --rm
$ kubectl delete hello-world
$ kubectl logs -f hello-world  

// 임시작업용 파드
$ kubectl run busybox --image=busybox --restart=Never --rm -it sh
$ kubectl run ubuntu --image=ubuntu --restart=Never --rm -it /bin/bash -c "do something"
$ kubectl exec --stdin --tty {container} -- /bin/bash
```

- restart 옵션은 Always, OnFailure, Never 선택 가능 (기본값 Always)
- OnFailure 는 프로세스가 0이 아닌 값으로 종료되었을 때 재시작



#### Deployment Controller

- 계속 실행하는 서비스 애플리케이션
  
- replicaset 과 pod 를 생성
  
- replicaset 오브젝트는 파드 갯수를 일정하게 유지해줌
  
  ```bash
  $ kubectl create deployment nginx --image=nginx
  $ kubectl scale deployment/nginx --replicas=5
  $ kubectl delete pod/nginx-6799fc88d8-f6shf // 새로운 pod 가 생성됨
  $ kubectl delete deployment/nginx
  $ kubectl logs pod/nginx
  ```



#### Job Controller

- 1회성 실행하는 배치 애플리케이션

- pod 를 생성

  ```bash
  $ kubectl create job returning-0 --image=ubuntu -- /bin/bash -c "exit 0" // Completed
  $ kubectl create job returning-1 --image=ubuntu -- /bin/bash -c "exit 1" // Error 
  ```

- CronJob Controller
  - 스케줄에 맞춰 Job Controller 와 Garbage Collect Controller 를 생성
  - Garbage Collector Controller 는 종료된 컨테이너를 정리

#### Service

- ClusterIP
- NodePort
- LoadBalanacer
- ExternalName

#### Storage

- 종류
  - k8s : emptyDir(동일컨테이너, pod lifecycle), hostPath(파드간), Persistent Volume(노드간)
  - oss : 
  - cloud : azure, aws 등
- 권한
  - ReadOnlyMany
  - ReadWriteOnce - 단일 노드
  - ReadWriteMany - 복수노드
- 추상화
  - 수동 : 수동으로 의존정보 기술
  - 자동 : PersistentVolumeClaim 을 통해 StorageClass 에서 동적으로 PV 연결

    ```yaml
    apiVersion: v1  ##「표１PersistentVolumeClaim v1 core」
    kind: PersistentVolumeClaim
    metadata:       ##「표2 ObjectMeta v1 meta」
      name: data1
    spec:           ##「표3 PersistentVolumeClaimSpec v1 core」
      accessModes:
      - ReadWriteOnce
      storageClassName: standard
      resources:
        requests:
          storage: 2Gi
    ```

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: pod1
    spec:
      volumes:               ##「표5 Volume v1 core」참고
      - name: pvc1
        persistentVolumeClaim:
          claimName: data1   ## <-- PVC의 이름 설정
      containers:
      - name: ubuntu
        image: ubuntu:16.04
        volumeMounts:        ## 「표6 VolumeMount v1 core」참고
        - name: pvc1
          mountPath: /mnt    ## <-- 컨테이너 상 마운트 경로
        command: ["/usr/bin/tail","-f","/dev/null"]      
    ```

    ```bash
    $ kubectl get pv,pvc
    $ sudo kubectl get storageclass
    ```



#### Statefulset

- 

#### ConfigMap

- pod 에 key:value 형태로 설정값 전달

```
project=ncc
cluster=ad1
namespace=edu
```

```bash
$ kubectl create configmap example-config --from-file=./myconfig.conf
```

- 환경변수

  ```yaml
  spec:
    containers:
      - name: example
        image: nginx:1.7.6
        env:
          - name: WHAT_IS_MY_PROJECT
            valueFrom:
              configMapKeyRef:
                name: example-config
                key: project
  ```

- 설정파일

  ```yaml
  spec:
    containers:
      - name: example
        image: nginx:1.7.6
        volumeMounts:
        - name: example-volume
        mountPath: /config
    volumes:
      - name: example-volume
        configMap:
          name: example-config 
  ```

  

#### Secret

- ConfigMap과 비슷하지만 민감정보 저장

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4= # echo -n 'admin' | base64
  password: MWYyZDFlMmU2N2Rm # echo -n '1f2d1e2e67df' | base64
```

```bash
$ kubectl create -f ./secret.yml
```



#### Manifest

- 컨테이너들에 대한 명세를 json 이나 yaml 로 작성하고 파드를 배치할 수 있음

  ```bash
  $ kubectl apply|create -f test.yml or test.json
  $ kubectl delete -f test.yml or test.json
  ```

  ```yaml
  # test-pod.yml
  apiVersion: v1
  kind: Pod
  metadata:
    name: nginx
  spec:
    containers:
    - name: nginx
      image: nginx:latest
  ```

  ```json
  // test-pod.json
  {
      "apiVersion": "v1",
      "kind": "Pod",
      "metadata": {
    "name": "nginx"
      },
      "spec": {
          "containers": [
              {
                  "image": "nginx:latest",
                  "name": "nginx"
              }
          ]
      }
  }
  ```

- Pod Health Check

  - 매니페스토에 Liveness, Readiness 프로브 설정 가능
  - 프로브 방식은 exec(종료 리턴값), httpGet, tcpSocket
  - 프로브가 3번 연속 실패하면 kubelet 이 컨테이너를 강제 종료하고 재시작
  - 노드(베어메탈)의 헬스체크에는 컨트롤러를 사용 (하드웨어에 문제가 발생하면 파드도 정상 동작 보장할 수 없음)
  
  ```yaml
  spec:
    containers:
      - name : webapl
        image : maho/webapl:0.1
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 3
          periodSeconds : 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 15
          periodSeconds : 6
  ```

- initContainer

  - 파드의 초기화만 담당하는 컨테이너

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: init-sample
  spec:
    containers:
      volumeMounts:
      -  name: main
        image: ubuntu
        command: ["/bin/bash"]
        args: [ "-c", "tail -f /dev/null"]
      - mountsPath: /docs
        name: data-vol
        readOnly: false
  
    initContainers:
      - name: init
        image: alpine
        command: ["/bin/sh"]
        args: ["-c", "mkdir /mnt/html; chown 33:33 /mnt/html"]
        volumeMounts:
        - mountPath: /mnt
          name: data-vol
          readOnly: false
  
        volumes:
        - name: data-vol
          emptyDir: {}
  ```

  - main 컨테이너의 마운트 상태 확인

    ```bash
    $ kubectl exec -it init-sample -c main sh
    $ ls -al /docs
    ```

- sidecar

  - 파드에 여러개의 컨테이너 배치

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: webserver
  spec:
    containers:
    - name: nginx
      image: nginx
      volumeMounts:
      - mountPath: /usr/share/nginx/html
        name: contents-vol
        readOnly: true
        
    - name: cloner
      image: maho/c-cloner:0.1
      env:
      - name: CONTENTS_SOURCE_URL
        value: "https://github.com/takara9/web-contents"
      volumeMounts:
      - mountPath: /data
        name: contents-vol
        
    volumes:
    - name: contents-vol
      emptyDir: {}
  ```

- deployment

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: hello-world
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: hello-world
    template:
      metadata:
        labels:
          app: hello-world
      spec:
        containers:
          - name: hello-world
            image: nginx
            ports:
              - containerPort: 8080
  ```

  - rollout

    - 변경사항이 바로 적용됨

    ```bash
    $ watch -n 0.1 'kubectl get all -o wide'
    $ kubetl describe deployment/hello-world // 25% max unavailable, 25% max surge
    $ kubectl apply -f test.yml // replica 수의 1.25배를 넘지 않게 순차적으로 컨테이너 재생성
    ```

  - rollback

    - 변경전 상황으로 되돌림

    ```bash
    $ kubectl rollout undo deployment hello-world
    ```

  - recovery

    - 파드의 restart 옵션은 컨테이너가 죽었을 때 해당 새로운 컨테이너를 시작
    - deployment 로 배치하면 파드 단위로 재시작

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: test1
    spec:
      containers:
      - name: busybox
        image: busybox:1
        command: ["sh", "-c", "sleep 3600; exit 0"]
      restartPolicy: Always
    ```

  - drain

    - 파드의 노드 교체

      ```bash
      $ kubectl get node
      $ kubectl cordon node1
      $ kubectl drain node1 // cordon 기능을 포함하여 수행
      $ kubectl uncordon node1
      ```

#### 파드 이슈 분석

  ```bash
  $ kubectl get events
  $ kubectl describe {object}
  $ kubectl logs {object}
  ```

- 매니패스트 수정으로 애플리케이션 자동 실행 막기

  ```yaml
  spec:
  containers:
  - name: chatbot
    ...
    command: ["tail", "-f", "/dev/null"]
  ```

- 파드에서 직접 원인 확인

  ```bash
  $ kubectl exec -it chatbot bash
  ```







****
