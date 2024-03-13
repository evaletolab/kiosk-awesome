import Vue from 'vue'
import VueRouter, { RouteConfig } from 'vue-router'
import Home from '../views/Home.vue'
import Playlist from '../views/Playlist.vue';
import MetaView from '../views/MetaView.vue';
import TestVideoPlayer from '../views/TestVideoPlayer.vue';

Vue.use(VueRouter)

const routes: Array<RouteConfig> = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/playlist',
    name: 'Playlist',
    component: Playlist
  },
  {
    path: '/metaview',
    name: 'MetaView',
    component: MetaView,
  },
  {
    path: '/testVideoPlayer',
    name: 'TestVideoPlayer',
    component: TestVideoPlayer,
  }
]

const router = new VueRouter({
  routes,
  mode: process.env.IS_ELECTRON ? 'hash' : 'history'
})

export default router
