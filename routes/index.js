const express = require('express');
const wtf = require('wtf_wikipedia');
const { CountryApi } = require('country-api');
const translate = require('yandex-translate-api')(
  'trnsl.1.1.20191017T070315Z.3b150a032af947e0.500a72809072f99b405f6c2eb89b4111d99e354a',
);


const router = express.Router();
const fetch = require('node-fetch');
const fs = require('fs');
// const wikipedia = require('node-wikipedia');

const Reason = require('../models/reason');

router.get('/', (req, res, next) => {
  res.render('startButton');
});

router.get('/reason', async (req, res) => {
  const resp = await fetch('https://date.nager.at/api/v2/NextPublicHolidaysWorldwide');
  const reasons = await resp.json();
  console.log(reasons.length);
  for (let i = 0; i < reasons.length; i++) {
    const reason = new Reason({
      date: reasons[i].date,
      localName: reasons[i].localName,
      name: reasons[i].name,
      countryCode: reasons[i].countryCode,
    });
    console.log(reason);
    await reason.save();
  }
  const reasonsF = await Reason.find({});
  console.log(reasonsF);
  res.render('reason', { reasonsF });
});


router.get('/reason/:id', async (req, res) => {
  const reason = await Reason.findById(req.params.id);
  const dataCountry = await new CountryApi().byIso3166Code(`${reason.countryCode}`);
  console.log(dataCountry.name);
  const doc = await wtf.fetch(`${reason.name}`);
  const data = doc.text().substring(0, 1000);

  console.log(dataCountry);
  const info = ' - public holiday ';
  const dateForPage = reason.date.slice(3, 10);
  const dataReason = `The holiday is celebrated on ${dateForPage}`;
  res.render('dataReason', {
    reason,
    data,
    dataCountry,
    info,
    dataReason,
  });
});

// router.get('/reason', async (req, res) => {
//   const resp = await fetch('https://date.nager.at/api/v2/NextPublicHolidaysWorldwide');
//   const reasons = await resp.json();
//   console.log(reasons.length);

//   for (let i = 0; i < reasons.length; i++) {
//     const reason = new Reason({
//       date: reasons[i].date,
//       localName: reasons[i].localName,
//       name: reasons[i].name,
//       countryCode: reasons[i].countryCode,
//     });
//     console.log(reason);
//     await reason.save();
//   }
//   res.render('reason', { reasons });
// });

module.exports = router;
