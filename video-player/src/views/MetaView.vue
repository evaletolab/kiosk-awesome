<template>
  <div class="meta-view">
    <div class="row">
      <meta-view-button clipId="P" v-on:clickEvt="onClick('P')" />
      <meta-view-button clipId="A" v-on:clickEvt="onClick('A')" />
      <meta-view-button clipId="B" v-on:clickEvt="onClick('B')" />
      <meta-view-button clipId="M" v-on:clickEvt="onClick('M')" />
    </div>
    <div class="row">
      <meta-view-button clipId="C" v-on:clickEvt="onClick('C')" />
      <meta-view-button clipId="D" v-on:clickEvt="onClick('D')" />
      <meta-view-button clipId="E" v-on:clickEvt="onClick('E')" />
      <meta-view-button clipId="BNS" v-on:clickEvt="onClick('BNS')" />
    </div>
  </div>
</template>

<style scoped>
  .meta-view{
    /* display: flex;
    flex-direction: column; */
    overflow: hidden;
  }
  .row{
    display: flex;
    flex-direction: row;
  }

  img{
    -moz-user-select: none;
    -webkit-user-select: none;
    user-select: none;
  }
</style>


<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import { $config } from "@/services";
import MetaViewButton from "@/components/MetaViewButton.vue";

@Component({
  components: { MetaViewButton },
})
export default class MetaView extends Vue {

  debounceTimerId:number = -1;
  clickIsLocked:boolean = false;

  get config() {
    return $config.config;
  }

  mounted() {
    this.clickIsLocked = true;
    this.debounceTimerId = window.setTimeout(() =>{
      this.clickIsLocked = false;
    }, this.config.back_click_delay);
  }

  beforeDestroy() {
    window.clearTimeout(this.debounceTimerId);
  }

  onClick(playlistId: string){
    if(this.clickIsLocked) return;
    this.$router.push({path: "Playlist", query: {playlist: playlistId, isMetaViewContext: "true"}});
  }
}
</script>
