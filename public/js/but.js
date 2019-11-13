window.requestAnimFrame = (function () {
  return (
    window.requestAnimationFrame
    || window.webkitRequestAnimationFrame
    || window.mozRequestAnimationFrame
    || window.oRequestAnimationFrame
    || window.msRequestAnimationFrame
    || function (callback) {
      window.setTimeout(callback, 1000 / 60);
    }
  );
}());

Math.randMinMax = function (min, max, round) {
  let val = min + Math.random() * (max - min);

  if (round) val = Math.round(val);

  return val;
};
Math.TO_RAD = Math.PI / 180;
Math.getAngle = function (x1, y1, x2, y2) {
  const dx = x1 - x2;
  let dy = y1 - y2;

  return Math.atan2(dy, dx);
};
Math.getDistance = function (x1, y1, x2, y2) {
  let xs = x2 - x1;
  let ys = y2 - y1;

  xs *= xs;
  ys *= ys;

  return Math.sqrt(xs + ys);
};

const FX = {};

(function () {
  const canvas = document.getElementById('myCanvas');
  let ctx = canvas.getContext('2d');
  let lastUpdate = new Date();
  let mouseUpdate = new Date();
  let lastMouse = [];
  let width;
  let height;

  FX.particles = [];

  setFullscreen();
  document.getElementById('button').addEventListener('mousedown', buttonEffect);

  function buttonEffect() {
    const button = document.getElementById('button');
    let height = button.offsetHeight;
    let left = button.offsetLeft;
    let top = button.offsetTop;
    let width = button.offsetWidth;
    let x;
    let y;
    let degree;

    for (let i = 0; i < 40; i += 1) {
      if (Math.random() < 0.5) {
        y = Math.randMinMax(top, top + height);

        if (Math.random() < 0.5) {
          x = left;
          degree = Math.randMinMax(-45, 45);
        } else {
          x = left + width;
          degree = Math.randMinMax(135, 225);
        }
      } else {
        x = Math.randMinMax(left, left + width);

        if (Math.random() < 0.5) {
          y = top;
          degree = Math.randMinMax(45, 135);
        } else {
          y = top + height;
          degree = Math.randMinMax(-135, -45);
        }
      }
      createParticle({
        x,
        y,
        degree,
        speed: Math.randMinMax(100, 150),
        vs: Math.randMinMax(-4, -1),
      });
    }
  }
  window.setTimeout(buttonEffect, 100);

  loop();

  window.addEventListener('resize', setFullscreen);

  function createParticle(args) {
    const options = {
      x: width / 2,
      y: height / 2,
      color: `hsla(${Math.randMinMax(160, 290)}, 100%, 50%, ${Math.random().toFixed(2)})`,
      degree: Math.randMinMax(0, 360),
      speed: Math.randMinMax(300, 350),
      vd: Math.randMinMax(-90, 90),
      vs: Math.randMinMax(-8, -5),
    };

    for (key in args) {
      options[key] = args[key];
    }

    FX.particles.push(options);
  }

  function loop() {
    const thisUpdate = new Date();
    let delta = (lastUpdate - thisUpdate) / 1000;
    let amount = FX.particles.length;
    let size = 2;
    let i = 0;
    let p;

    ctx.fillStyle = 'rgba(15,15,15,0.25)';
    ctx.fillRect(0, 0, width, height);

    ctx.globalCompositeStyle = 'lighter';

    for (; i < amount; i += 1) {
      p = FX.particles[i];

      p.degree += p.vd * delta;
      p.speed += p.vs; // * delta);
      if (p.speed < 0) continue;

      p.x += Math.cos(p.degree * Math.TO_RAD) * (p.speed * delta);
      p.y += Math.sin(p.degree * Math.TO_RAD) * (p.speed * delta);

      ctx.save();

      ctx.translate(p.x, p.y);
      ctx.rotate(p.degree * Math.TO_RAD);

      ctx.fillStyle = p.color;
      ctx.fillRect(-size, -size, size * 2, size * 2);

      ctx.restore();
    }

    lastUpdate = thisUpdate;

    requestAnimFrame(loop);
  }

  function setFullscreen() {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
  }
}());
