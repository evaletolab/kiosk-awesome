<template>
  <div id="app">
    <uptime v-if="showUptime"/>    
    <router-view/>
  </div>
</template>

<style lang="scss">
  @import "./App.scss";
</style>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import { $config,  } from "@/services";
import Uptime from '@/components/Uptime.vue';

@Component({
  components: { Uptime },
})
export default class App extends Vue {

  get config() {
    return $config.config;
  }

  get showUptime(){
    return this.config.show_uptime;
  }
}
</script>
