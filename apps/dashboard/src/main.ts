// import('./bootstrap').catch((err) => console.error(err));
// import { setRemoteDefinitions } from '@nx/angular/mf';

// fetch('/module-federation.manifest.json')
//   .then((res) => res.json())
//   .then((definitions) => setRemoteDefinitions(definitions))
//   .then(() => import('./bootstrap').catch((err) => console.error(err)));

import { setRemoteDefinitions } from '@nx/angular/mf';

function loadRemotes() {
  const host = window.location.host;
  let env = '';
  if (host.indexOf('s3-website.eu-north-1.amazonaws.com') >= 0) {
    // TODO change to correct url
    env = 'prod';
  } else {
    env = 'local';
  }
  fetch(`./module-federation.manifest-${env}.json`)
    .then((res) => res.json())
    .then((definitions) => setRemoteDefinitions(definitions))
    .then(() => import('./bootstrap').catch((err) => console.error(err)));
}

loadRemotes();
