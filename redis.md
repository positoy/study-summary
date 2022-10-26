# [redis](https://www.youtube.com/watch?v=jgpVdJB2sKQ)

## install & run
```bash
brew install redis
redis-server &
redis-cli
```

## [data types](https://redis.io/docs/data-types/)

### string
```bash
set name andy
get name

expire name 10
ttl name

set name andy ex 10 // setex name 10 andy 
ttl name

set age 10
incr age // 11
incrby age 10 // 21
```

### list
```bash
lpush greetings hello
rpush greetings aloha
lpush greetings hi
rpush greetings nihao

lpop greetings // hi
rpop greetings // nihao

llen greetings // 2
lrange greetings 0 -1 // hello aloha
```

### hash
```bash
hset profile name andy age 35 job developer
hget profile name
hgetall profile
```
