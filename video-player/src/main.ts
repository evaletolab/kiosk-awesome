import Vue from 'vue'
import App from './App.vue'
import router from './router'
import { $config } from '@/services';
import { $content } from './services/content-service';

Vue.config.productionTip = false


//
// load config before starting
const load = [$config.get(), $content.load()];

Promise.all(load)
.then(() => {
  new Vue({
    router,
    render: h => h(App)
  }).$mount('#app')
})
.catch(e => {
  console.log("error", e);
})
