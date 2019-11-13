const mongoose = require("mongoose");
const faker = require("faker");

const User = require("../models/user");


mongoose.connect("mongodb://localhost:27017/myProject", { useNewUrlParser: true, useUnifiedTopology: true });

//async function userSeed(count = 10) {
//  for (let index = 0; index < count; index++) {
 //   const user = new User({
 //     username: faker.name.firstName,
 //     login: faker.internet.userName,
 //     email: faker.internet.email,
 //     password: faker.internet.password,
 //     anotherModelArr: [],
 //   });
 //   await user.save();
 // }
//}

