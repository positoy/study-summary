# MongoDB

- 관련자료 https://docs.mongodb.com/manual/crud/

### 1. database

```javascript
show dbs
use testDb
db
db.stats()
db.dropDatabase()
```



### 2. collection

```javascript
show collections
db.createCollection("testCollection", { // name & options
capped : true,
size : 6142800,
max: 10000
})
db.testCollection.drop()
db.testCollection.renameCollection("renamedCollection")
```



### 3. document

```javascript
db.testCollection.insert([
  {"name" : "first"},
  {"name" : "second"},
  {"name" : "third"}  
])
db.testCollection.find([
  {"name":"thrid"}, // query
  {"_id":false, "name":true} // projection 
]) // cursor 반환 (leftime : 5mins)
db.testCollection.remove(
  {"name" : "third"}, // criteria
  true // justOne
)
```



### 4. CRUD

```js
// equal
db.myCollection.find({name:"비즈톡"})

// in
db.myCollection.find({name:{$in:["MTS", "비즈톡", "루나소프트"]}})

// and (less than)
db.agent.find({name:'루나소프트', createdAt:{$lt:new Date()}})

// or
db.agent.find({$or:[{agentKey:'n989Ao58QN6mmDRTt4dA'}, {name:'루나소프트'}]})    

// 
```

