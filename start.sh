npm init -yes
npm install eslint eslint-config-airbnb-base eslint-plugin-import -d
touch .eslintrc.js 
echo '{
  module.exports={"extends" : "airbnb-base", "env": {"browser": true}}
}' > .eslintrc.js

touch app.js
echo '
const express = require("express");
const path = require("path");
const morgan = require("morgan");
const handlebars = require("express-handlebars");
const createError = require("http-errors");
const cookieParser = require("cookie-parser");
const methodOverride = require("method-override");
const session = require("express-session");
const FileStore = require("session-file-store")(session);
const { cookiesCleaner } = require("./middleware/auth");
const mongoose = require("mongoose");

mongoose.set("useCreateIndex", true);
mongoose.connect("mongodb://localhost:27017/myProject", { useNewUrlParser: true, useUnifiedTopology: true });

const hbs = handlebars.create( {
	defaultLayout: "layout",
    extname: "hbs",
    layoutsDir: path.join(__dirname, "views"),
    partialsDir: path.join(__dirname, "views"),
});

const app = express();

app.use(morgan("dev"));
app.use(express.urlencoded({extended: true}));
app.use(express.json());
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

const fileStoreOptions = {};
app.use(
  session({
    store: new FileStore(fileStoreOptions),
    // retries: 0,
    key: "user_sid",
    secret: "anything here",
    resave: false,
    saveUninitialized: false,
    cookie: {
      expires: 600000,
    },
  }),
);

app.use(cookiesCleaner);

app.use(
  methodOverride((req, res) => {
    if (req.body && typeof req.body === "object" && "_method" in req.body) {
      // look in urlencoded POST bodies and delete it
      const method = req.body._method;
      delete req.body._method;
      return method;
    }
  }),
);

const indexRouter = require("./routes/index");
const userRouter = require("./routes/users");

app.use("/", indexRouter);
app.use("/users", userRouter);

app.set("views", path.join(__dirname, "views"));
app.set("view engine", "hbs");

app.engine( "hbs", hbs.engine );

app.use((req, res, next) => {
  next(createError(404));
});

// error handler
app.use((err, req, res, next) => {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get("env") === "development" ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render("error");
});

module.exports = app;
' > app.js

mkdir routes
cd routes
touch index.js
echo '
const express = require("express");

const router = express.Router();

router.get("/", (req, res, next) => {
  res.send("Все готово для создания приложения.Уииииии!");
});

module.exports = router;
' > index.js
touch users.js
echo '
const express = require("express");
const router = express.Router();
const bcrypt = require("bcrypt");
const User = require("../models/user");
const { sessionChecker } = require("../middleware/auth");
router
  .route("/regForm")
  .get((req, res) => {
    res.render("regForm");
  })
  .post(async (req, res) => {
    try {
      const user = new User({
        username: req.body.username,
	login: req.body.login,
        email: req.body.email,
        password: await bcrypt.hash(req.body.password, 10),
      });
      await user.save();
      req.session.user = user;
      res.redirect("/users/logForm");
    } catch (error) {
      res.send("Ой, всё сломалось");
    }
  });

router
  .route("/logForm")
  .get((req, res) => {
    res.render("logForm");
  })
  .post(async (req, res) => {
    const { username, password } = req.body;
    const user = await User.findOne({ username });
    if (!user) {
      res.redirect("/users/logForm");
    } else if (await bcrypt.compare(password, user.password)) {
      req.session.user = user;
      res.redirect(`/users/${user.id}`);
    } else {
      res.redirect("/users/logForm");
    }
  });

router.get("/logout", async (req, res, next) => {
  if (req.session.user && req.cookies.user_sid) {
    try {
      await req.session.destroy();
      res.redirect("/");
    } catch (error) {
      next(error);
    }
  } else {
    res.redirect("/users/logForm");
  }
});
module.exports = router;
' > users.js
cd ..

mkdir middleware
cd middleware
touch auth.js
echo '
function cookiesCleaner(req, res, next) {
  console.log("middleware func");
  if (req.cookies.user_sid && !req.session.user) {
    res.clearCookie("user_sid");
  }
  next();
}

// middleware function to check for logged-in users
const sessionChecker = (req, res, next) => {
  if (req.session.user) {
    res.redirect("/entries");
  } else {
    next();
  }
};

module.exports = {
  sessionChecker,
  cookiesCleaner,
};
' > auth.js
cd ..


mkdir views
cd views
touch layout.hbs
echo '<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
    integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
  <link rel="stylesheet" href="/css/style.css">
  <title>Document</title>
</head>
<body>
  {{{body}}}
  <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js"
    integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN"
    crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"
    integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q"
    crossorigin="anonymous"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"
    integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl"
    crossorigin="anonymous"></script>
</body>

</html>
' > layout.hbs
touch regForm.hbs
echo '<header role="banner" class="mar-t-5 pad-t-2 pad-b-4 pad-s-1 wrap-float bg-white">
  <div class="max-w-700 center wrap-float">
    <nav class="clearfix mar-b-1">
      <ul class="no-bullets no-margin no-padding right">
        <li class="pipe-separate t-light-green left"><a href="/">home</a></li>
      </ul>
    </nav>

    <div class="logo-container">
      <img class="logo" src="" class="center block">
      <h1>Broccoli Blog</h1>
    </div>
  </div>
</header>

<form method="post" action="/users/regForm">
  <input id="name-input" name="username" type="text" placeholder="name"  value="" tabindex="1"
    class="block w-100 no-outline no-border pad-1 mar-b-2">

<input id="login-input" name="login" type="text" placeholder="login"  value="" tabindex="1"
    class="block w-100 no-outline no-border pad-1 mar-b-2">

  <input id="email-input" name="email" type="text" placeholder="email" value="" tabindex="1"
    class="block w-100 no-outline no-border pad-1 mar-b-2 ">

  <input id="password-input" name="password" type="password" placeholder="password" value="" tabindex="1"
    class="block w-100 no-outline no-border pad-1 mar-b-2">


  <input type="submit" value="registration" tabindex="3"
    class="block button w-100 mar-t-4 mar-b-3 pad-2 round-1 text-c center no-border no-outline">
</form>
' > regForm.hbs
touch error
echo '<h1>{{message}}</h1>
<h2>{{error.status}}</h2>
<pre>{{error.stack}}</pre>
' > error.hbs
cd ..


mkdir models
cd models
touch user.js
echo '
const mongoose = require("mongoose");
const uniqueValidator = require("mongoose-unique-validator");

const userSchema = new mongoose.Schema({
  admin: {
    type: Boolean,
    default: false
  },
  username: {
    type: String,
    required: [true, "поле не может оставаться пустым"]
  },
  login: {
    type: String,
    lowercase: true,
    unique: true,
    required: [true, "поле не может оставаться пустым"],
    match: [/^[a-zA-Z0-9]+$/, "is invalid"]
  },
  email: {
    type: String,
    lowercase: true,
    unique: true,
    required: [true, "поле не может оставаться пустым"],
    match: [/\S+@\S+\.\S+/, "is invalid"]
  },
  password: { type: String, required: [true, "поле не может оставаться пустым"] },
  anotherModelArr: [{ type: mongoose.Schema.Types.ObjectId, ref: "anotherModel" }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

userSchema.plugin(uniqueValidator, { message: "is already taken." });

module.exports = mongoose.model("User", userSchema);
'>user.js
cd ..


touch server.js
echo '
const http = require("http");
const app = require("./app");

const server = http.createServer(app);
const port = process.env.PORT || 3000;

server.listen(port);
' >server.js

mkdir seeders
cd seeders
touch seeder.js
echo 'const mongoose = require("mongoose");
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
' >seeder.js
cd ..
mkdir sessions

mkdir public
cd public
mkdir js
cd js
touch application.js
cd ..

mkdir css
cd css
touch style.css
cd ..
cd ..

npm install express --save
npm install express-handlebars --save
npm install morgan --save
npm install nodemon --save
npm install mongoose --save
npm install path --save
npm install http --save
npm install bcrypt --save
npm install http-errors --save
npm install cookie-parser --save
npm install method-override --save
npm install express-session --save
npm install session-file-store --save
npm install mongoose-unique-validator --save
npm i -S faker



