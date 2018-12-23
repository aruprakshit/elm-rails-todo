import Cookies from 'js-cookie';

document.addEventListener('DOMContentLoaded', function (event) {
  const app = Elm.Main.init({
      node: document.getElementById('root'),
      flags: Cookies.get('appAuthToken')
  })

  app.ports.storeAuthInfo.subscribe(function(auth) {
    Cookies.set('appAuthToken', auth, { expires: 7 });
  });
})
