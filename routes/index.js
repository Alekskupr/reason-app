const express = require('express');
const wtf = require('wtf_wikipedia');
const { CountryApi } = require('country-api');

const router = express.Router();
const fetch = require('node-fetch');

const Reason = require('../models/reason');

router.get('/', (req, res, next) => {
  res.render('startButton');
});

router.get('/reason', async (req, res) => {
  const resp = await fetch('https://date.nager.at/api/v2/NextPublicHolidaysWorldwide');
  const reasons = await resp.json();
  for (let i = 0; i < reasons.length; i++) {
    const reason = new Reason({
      date: reasons[i].date,
      localName: reasons[i].localName,
      name: reasons[i].name,
      countryCode: reasons[i].countryCode,
    });
    await reason.save();
  }
  const reasonsF = await Reason.find({});
  res.render('reason', { reasonsF });
});

router.get('/reason/:id', async (req, res) => {
  const reason = await Reason.findById(req.params.id);
  const dataCountry = await new CountryApi().byIso3166Code(`${reason.countryCode}`);
  const doc = await wtf.fetch(`${reason.name}`);
  const data = doc.text().substring(0, 1000);
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

module.exports = router;
