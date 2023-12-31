import Vue from 'vue';
// eslint-disable-next-line no-restricted-imports
import Vuex from 'vuex';
import ResponsiveApp from './components/responsive_app.vue';
import App from './components/top_nav_app.vue';
import { createStore } from './stores';

Vue.use(Vuex);

const mount = (el, Component) => {
  const viewModel = JSON.parse(el.dataset.viewModel);
  const store = createStore();

  return new Vue({
    el,
    name: 'TopNavRoot',
    store,
    render(h) {
      return h(Component, {
        props: {
          navData: viewModel,
        },
      });
    },
  });
};

export const mountTopNav = (el) => mount(el, App);

export const mountTopNavResponsive = (el) => mount(el, ResponsiveApp);
