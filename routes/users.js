
// const express = require("express");
// const router = express.Router();
// const bcrypt = require("bcrypt");
// const User = require("../models/user");
// const { sessionChecker } = require("../middleware/auth");
// router
//   .route("/regForm")
//   .get((req, res) => {
//     res.render("regForm");
//   })
//   .post(async (req, res) => {
//     try {
//       const user = new User({
//         username: req.body.username,
// 	login: req.body.login,
//         email: req.body.email,
//         password: await bcrypt.hash(req.body.password, 10),
//       });
//       await user.save();
//       req.session.user = user;
//       res.redirect("/users/logForm");
//     } catch (error) {
//       res.send("Ой, всё сломалось");
//     }
//   });

// router
//   .route("/logForm")
//   .get((req, res) => {
//     res.render("logForm");
//   })
//   .post(async (req, res) => {
//     const { username, password } = req.body;
//     const user = await User.findOne({ username });
//     if (!user) {
//       res.redirect("/users/logForm");
//     } else if (await bcrypt.compare(password, user.password)) {
//       req.session.user = user;
//       res.redirect(`/users/${user.id}`);
//     } else {
//       res.redirect("/users/logForm");
//     }
//   });

// router.get("/logout", async (req, res, next) => {
//   if (req.session.user && req.cookies.user_sid) {
//     try {
//       await req.session.destroy();
//       res.redirect("/");
//     } catch (error) {
//       next(error);
//     }
//   } else {
//     res.redirect("/users/logForm");
//   }
// });
// module.exports = router;

