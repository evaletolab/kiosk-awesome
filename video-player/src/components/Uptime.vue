<template>
    <div class="uptime noselect" ref="uptime">
    </div>
    
</template>

<style lang="scss" scoped>
    .uptime{
        position: fixed;
        bottom: 10px;
        left: 10px;
        color: #ddd;
        z-index: 1000;
        touch-action: none;
        pointer-events: none;
    }

    .noselect {
      -webkit-touch-callout: none; /* iOS Safari */
      -webkit-user-select: none; /* Safari */
      -khtml-user-select: none; /* Konqueror HTML */
      -moz-user-select: none; /* Old versions of Firefox */
      -ms-user-select: none; /* Internet Explorer/Edge */
      user-select: none; /* Non-prefixed version, currently supported by Chrome, Edge, Opera and Firefox */
    }
</style>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import { $config  } from "@/services";

@Component({
  components: { },
})
export default class Uptime extends Vue {

  start!: Date;
  intervalId!: number;

  get config() {
    return $config.config;
  }

  get element() : HTMLElement {
    return this.$refs.uptime as HTMLElement;
  }

  mounted() {
    this.start = new Date();
    this.intervalId = window.setInterval(this.tick, 1000);
  }

  beforeDestroy() {
    clearInterval(this.intervalId);
  }


  tick(){
    const now = new Date();
    const elapsed = Math.floor((now.getTime() - this.start.getTime()) / 1000);

    const hours   = Math.floor(elapsed / 3600);
    const minutes = Math.floor((elapsed - (hours * 3600)) / 60);
    const seconds = elapsed - (hours * 3600) - (minutes * 60);
    
    
    const hoursStr = hours.toString().padStart(2, '0');
    const minStr = minutes.toString().padStart(2, '0');
    const secondsStr = seconds.toString().padStart(2, '0');

    const currentHours =  now.getHours().toString().padStart(2, '0');
    const currentMinutes =  now.getMinutes().toString().padStart(2, '0');
    
    const formattedTime = `(${currentHours}:${currentMinutes}) - ${hoursStr}:${minStr}:${secondsStr}`;

    this.element.innerText = formattedTime;

  }

}
</script>
