# Reactor Core

### dependencies
```xml
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-core</artifactId>
    <version>3.3.9.RELEASE</version>
</dependency>

<dependency> 
    <groupId>ch.qos.logback</groupId> 
    <artifactId>logback-classic</artifactId> 
    <version>1.2.6</version> 
</dependency>

```

### 2 types
```java
Flux<Integer> just = Flux.just(1, 2, 3, 4);
Mono<Integer> just = Mono.just(1);
```

### subscription
```java
List<Integer> elements = new ArrayList<>();
Flux.just(1, 2, 3, 4)
  .log()
  .subscribe(elements::add);
```

actually, whole interface looks like

```java
Flux.just(1, 2, 3, 4)
  .log()
  .subscribe(new Subscriber<Integer>() {
    @Override
    public void onSubscribe(Subscription s) {
      s.request(Long.MAX_VALUE);
    }

    @Override
    public void onNext(Integer integer) {
      elements.add(integer);
    }

    @Override
    public void onError(Throwable t) {}

    @Override
    public void onComplete() {}
});
```

### backpressure
The reason why flux is not same to `Stream.of(1,2,3,4)`
```java
Flux.just(1, 2, 3, 4)
  .log()
  .subscribe(new Subscriber<Integer>() {
    private Subscription s;
    int onNextAmount;

    @Override
    public void onSubscribe(Subscription s) {
        this.s = s;
        s.request(2);
    }

    @Override
    public void onNext(Integer integer) {
        elements.add(integer);
        onNextAmount++;
        if (onNextAmount % 2 == 0) {
            s.request(2);
        }
    }

    @Override
    public void onError(Throwable t) {}

    @Override
    public void onComplete() {}
});
```

### mapping
```java
Flux.just(1, 2, 3, 4)
  .log()
  .map(i -> i * 2)
  .subscribe(elements::add);
```

### zipping (combining)
```java
Flux.just(1, 2, 3, 4)
  .log()
  .map(i -> i * 2)
  .zipWith(Flux.range(0, Integer.MAX_VALUE), 
    (one, two) -> String.format("First Flux: %d, Second Flux: %d", one, two))
  .subscribe(elements::add);
```

### Hot Streams
means opposite of cold stream which means static, fixed-length stream data.
```java
        ConnectableFlux<Object> publish = Flux.create(fluxSink -> {
                    while (true) {
                        fluxSink.next(System.currentTimeMillis());
                    }
                })
                .sample(Duration.ofMillis(1000)) // throttling
                .publish();

        publish.subscribe(System.out::println);
        publish.connect();
```

### Concurrency
```java
Flux.just(1, 2, 3, 4)
  .log()
  .map(i -> i * 2)
  .subscribeOn(Schedulers.parallel())
  .subscribe(elements::add);
```
