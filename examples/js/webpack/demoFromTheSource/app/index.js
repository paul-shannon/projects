import _ from 'lodash';

function component () {
  var element = document.createElement('div');
  element.innerHTML = _.join(['Hello','webpack'], ' ');    /* lodash is required for the next line to work */
  return element;
}
document.body.appendChild(component());
